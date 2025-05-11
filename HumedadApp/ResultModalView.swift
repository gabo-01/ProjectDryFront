import SwiftUI
import MessageUI

struct ResultModalView: View {
    let result: PredictionResult
    var onDismiss: () -> Void

    @State private var showMailComposer = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Resultados de la Predicción")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            // Mostrar mensaje de error si existe
            if result.status.starts(with: "Error") {
                Text(result.status)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Mostrar las predicciones de regresión
                if let humedadPredicha = result.humedad_predicha {
                    Text("Humedad Predicha: \(String(format: "%.2f", humedadPredicha*100))%")
                        .font(.headline)
                        .padding(.bottom, 10)
                }

                // Mostrar las predicciones de clasificación
                VStack(alignment: .leading, spacing: 10) {
                    if let clasePredicha = result.clase_predicha {
                        HStack {
                            Text("Clasificación:")
                                .fontWeight(.semibold)
                            Text(result.etiqueta_clase ?? (clasePredicha == 0 ? "Humedad Baja" : "Humedad Alta"))
                                .foregroundColor(clasePredicha == 0 ? .blue : .orange)
                                .fontWeight(.bold)
                        }
                    }

                    if let probabilidad0 = result.probabilidad_0,
                       let probabilidad1 = result.probabilidad_1 {
                        
                        VStack(alignment: .leading) {
                            Text("Probabilidades:")
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("Humedad Baja:")
                                Text("\(String(format: "%.1f", probabilidad0 * 100))%")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Humedad Alta:")
                                Text("\(String(format: "%.1f", probabilidad1 * 100))%")
                                    .foregroundColor(.orange)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Mostrar confianza general con indicador visual
                    if let confianza = result.confianza {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Nivel de Confianza:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(String(format: "%.0f", confianza * 100))%")
                                    .fontWeight(.bold)
                            }
                            
                            // Barra de progreso para visualizar la confianza
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Fondo de la barra
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 10)
                                        .opacity(0.3)
                                        .foregroundColor(Color.gray)
                                        .cornerRadius(10)
                                    
                                    // Barra de progreso
                                    Rectangle()
                                        .frame(width: min(CGFloat(confianza) * geometry.size.width, geometry.size.width), height: 10)
                                        .foregroundColor(confianza > 0.7 ? Color.green :
                                                        (confianza > 0.5 ? Color.yellow : Color.red))
                                        .cornerRadius(10)
                                }
                            }
                            .frame(height: 10)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Mostrar resultado del análisis
                VStack(spacing: 15) {
                    if result.necesita_otro_ciclo  {
                        // Mostrar alerta solo si es humedad alta (clase 1)
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("HUMEDAD ALTA - Se recomienda otro ciclo de secado")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Botón de correo siempre habilitado cuando se necesita otro ciclo
                        Button(action: {
                            sendEmailRequest()
                            onDismiss()
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Enviar alerta por correo")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        // El botón siempre está habilitado cuando necesita_otro_ciclo es true
                        
                    } else {
                        // Mostrar mensaje de éxito para humedad baja (clase 0)
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("HUMEDAD BAJA - Secado finalizado correctamente")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Mostrar mensaje adicional del API si existe
                    if let mensaje = result.mensaje {
                        Text(mensaje)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }
                }
                .padding(.vertical)
            }
            
            Spacer()
            
            Button("Cerrar") {
                onDismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showMailComposer) {
            MailView(isShowing: $showMailComposer, result: result)
        }
    }
    func sendEmailRequest() {
        guard let url = URL(string: "http://192.168.100.68:5001/api/send_gemini_email") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "humedad_predicha": result.humedad_predicha ?? 0,
            "clase_predicha": result.clase_predicha ?? 0,
            "probabilidad_0": result.probabilidad_0 ?? 0,
            "probabilidad_1": result.probabilidad_1 ?? 0,
            "confianza": result.confianza ?? 0,
            "mensaje": result.mensaje ?? ""
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:", error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
            }

            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response body:", responseString ?? "No data")
            }
        }.resume()

    }   
}

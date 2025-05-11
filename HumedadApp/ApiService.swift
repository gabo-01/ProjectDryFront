import Foundation

struct PredictionInput: Codable {
    let id: Int
    let HumedadInicial_pct: Double
    let TemperaturaInicial_C: Double
    let DensidadMaterial_g_cm3: Double
    let PorosidadFiltro_μm: Double
    let ContenidoOrgánico_pct: Double
    let HoraInicio_ts: Int  // Usamos Int para timestamp simulado
    let DuracionCiclo_min: Double
    let EficienciaSecado_pct: Double
    let HumedadFinal_Clase: Int
    let NecesitaOtroCiclo: Bool
}

struct PredictionResult: Identifiable, Codable {
    let id = UUID()
    
    // Para el caso de regresión
    let humedad_predicha: Double?
    
    // Para el caso de clasificación
    let clase_predicha: Int?
    let etiqueta_clase: String?
    let probabilidad_0: Double?
    let probabilidad_1: Double?
    
    let confianza: Double?
    let necesita_otro_ciclo: Bool
    let status: String
    let mensaje: String?
}

class APIService {
    static let shared = APIService()
    private init() {}
    
    // URL base del servidor
    private let baseURL = "http://192.168.100.68:5001"

    func predict(input: PredictionInput, completion: @escaping (PredictionResult?) -> Void) {
        // Ahora usamos el endpoint combinado
        guard let url = URL(string: "\(baseURL)/predict_complete") else {
            completion(PredictionResult(
                humedad_predicha: nil,
                clase_predicha: nil,
                etiqueta_clase: nil,
                probabilidad_0: nil,
                probabilidad_1: nil,
                confianza: nil,
                necesita_otro_ciclo: false,
                status: "Error: URL inválida",
                mensaje: nil
            ))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(input)
            request.httpBody = jsonData
        } catch {
            print("Error codificando datos: \(error)")
            completion(PredictionResult(
                humedad_predicha: nil,
                clase_predicha: nil,
                etiqueta_clase: nil,
                probabilidad_0: nil,
                probabilidad_1: nil,
                confianza: nil,
                necesita_otro_ciclo: false,
                status: "Error: \(error.localizedDescription)",
                mensaje: nil
            ))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud: \(error)")
                DispatchQueue.main.async {
                    completion(PredictionResult(
                        humedad_predicha: nil,
                        clase_predicha: nil,
                        etiqueta_clase: nil,
                        probabilidad_0: nil,
                        probabilidad_1: nil,
                        confianza: nil,
                        necesita_otro_ciclo: false,
                        status: "Error: \(error.localizedDescription)",
                        mensaje: nil
                    ))
                }
                return
            }
            
            guard let data = data else {
                print("Sin datos en la respuesta")
                DispatchQueue.main.async {
                    completion(PredictionResult(
                        humedad_predicha: nil,
                        clase_predicha: nil,
                        etiqueta_clase: nil,
                        probabilidad_0: nil,
                        probabilidad_1: nil,
                        confianza: nil,
                        necesita_otro_ciclo: false,
                        status: "Error: Sin datos en la respuesta",
                        mensaje: nil
                    ))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Respuesta recibida: \(json)")
                    
                    // Verificar si hay error
                    if let errorMsg = json["error"] as? String {
                        print("Error desde API: \(errorMsg)")
                        DispatchQueue.main.async {
                            completion(PredictionResult(
                                humedad_predicha: nil,
                                clase_predicha: nil,
                                etiqueta_clase: nil,
                                probabilidad_0: nil,
                                probabilidad_1: nil,
                                confianza: nil,
                                necesita_otro_ciclo: false,
                                status: "Error: \(errorMsg)",
                                mensaje: nil
                            ))
                        }
                        return
                    }
                    
                    // Mapear los campos desde la respuesta del servidor
                    let humedadPredicha = json["prediction"] as? Double
                    let clasePredicha = json["prediction_class"] as? Int
                    let etiquetaClase = json["prediction_label"] as? String
                    let probabilidadBaja = json["probability_low"] as? Double
                    let probabilidadAlta = json["probability_high"] as? Double
                    let confianza = json["confidence"] as? Double
                    // Determinar si necesita_otro_ciclo basado en la clase predicha
                    // (Si la clase es 1 "Alta", entonces necesita otro ciclo)
                    let necesitaOtroCiclo = clasePredicha == 1
                    let mensaje = json["message"] as? String
                    
                    let resultado = PredictionResult(
                        humedad_predicha: humedadPredicha,
                        clase_predicha: clasePredicha,
                        etiqueta_clase: etiquetaClase,
                        probabilidad_0: probabilidadBaja,
                        probabilidad_1: probabilidadAlta,
                        confianza: confianza,
                        necesita_otro_ciclo: necesitaOtroCiclo,
                        status: "Predicción completada",
                        mensaje: mensaje
                    )
                    
                    print("Resultado final: \(resultado)")
                    DispatchQueue.main.async {
                        completion(resultado)
                    }
                }
            } catch {
                print("Error decodificando respuesta: \(error)")
                DispatchQueue.main.async {
                    completion(PredictionResult(
                        humedad_predicha: nil,
                        clase_predicha: nil,
                        etiqueta_clase: nil,
                        probabilidad_0: nil,
                        probabilidad_1: nil,
                        confianza: nil,
                        necesita_otro_ciclo: false,
                        status: "Error: \(error.localizedDescription)",
                        mensaje: nil
                    ))
                }
            }
        }.resume()
    }
}

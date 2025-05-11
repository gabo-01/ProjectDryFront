import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var predictionResult: PredictionResult?

    var body: some View {
        TabView(selection: $selectedTab) {
            SamplingView(predictionResult: $predictionResult)
                .tabItem {
                    Image(systemName: "flask")
                    Text("Muestreo")
                }
                .tag(0)

            Text("Historial")
                .foregroundColor(.white)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Historial")
                }
                .tag(1)

            Text("Ajustes")
                .foregroundColor(.white)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Ajustes")
                }
                .tag(2)
        }
        .accentColor(.white)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        }
    }
}

struct SamplingView: View {
    @Binding var predictionResult: PredictionResult?

    var body: some View {
        ZStack {
            Color(red: 23/255, green: 23/255, blue: 23/255)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Título con emoji
                Text("🧪 Filtro de laboratorio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Spacer()

                Button(action: {
                    simulateAndSend()
                }) {
                    Text("Empezar Muestreo")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .sheet(item: $predictionResult) { result in
            ResultModalView(result: result) {
                self.predictionResult = nil
            }
        }
    }

    func simulateAndSend() {
        let simulatedData = PredictionInput(
            id: Int.random(in: 1...100),
            HumedadInicial_pct: Double.random(in: 20.0...80.0),
            TemperaturaInicial_C: Double.random(in: 30.0...80.0),
            DensidadMaterial_g_cm3: Double.random(in: 0.5...1.5),
            PorosidadFiltro_μm: Double.random(in: 5.0...50.0),
            ContenidoOrgánico_pct: Double.random(in: 1.0...10.0),
            HoraInicio_ts: Int(Date().timeIntervalSince1970), // timestamp actual
            DuracionCiclo_min: Double.random(in: 10.0...60.0),
            EficienciaSecado_pct: Double.random(in: 50.0...95.0), // Nueva columna
            HumedadFinal_Clase: Int.random(in: 0...1), // Nueva columna, 0 o 1
            NecesitaOtroCiclo: Bool.random() // Nueva columna
        )

        APIService.shared.predict(input: simulatedData) { result in
            DispatchQueue.main.async {
                self.predictionResult = result
            }
        }
    }


}

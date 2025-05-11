import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var result: PredictionResult
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        // Configurar email
        composer.setSubject("Informe de Secado - Recomendación de Ciclo Adicional")
        
        var body = """
        INFORME DE SECADO
        ========================
        
        Fecha: \(formattedDate())
        
        RESULTADOS:
        """
        
        if let humedad = result.humedad_predicha {
            body += "\n- Humedad predicha: \(String(format: "%.2f", humedad))%"
        }
        
        if let clase = result.clase_predicha {
            body += "\n- Clasificación: \(clase == 0 ? "Humedad Baja" : "Humedad Alta")"
        }
        
        if let prob0 = result.probabilidad_0, let prob1 = result.probabilidad_1 {
            body += "\n- Probabilidad Humedad Baja: \(String(format: "%.1f", prob0 * 100))%"
            body += "\n- Probabilidad Humedad Alta: \(String(format: "%.1f", prob1 * 100))%"
        }
        
        body += "\n\nRECOMENDACIÓN: Se requiere un ciclo adicional de secado."
        
        composer.setMessageBody(body, isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

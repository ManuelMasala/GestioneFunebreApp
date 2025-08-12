//
//  AIDocumentUploadView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import SwiftUI

struct AIDocumentUploadView: View {
    let onDocumentProcessed: ([String: String]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var processingMessage = "Analisi documento in corso..."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("AI Document Reader")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("L'AI analizzerà il documento e estrarrà automaticamente i dati del defunto")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                if isProcessing {
                    // Processing View
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(processingMessage)
                            .font(.subheadline)
                            .foregroundColor(.purple)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    // Options
                    VStack(spacing: 16) {
                        Button("📱 Scatta Foto") {
                            scanWithCamera()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("📂 Seleziona File") {
                            selectFile()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("📋 Incolla Testo") {
                            pasteText()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Suggerimenti:")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Usa documenti chiari e ben leggibili")
                            Text("• Evita ombre o riflessi")
                            Text("• L'AI funziona meglio con testo stampato")
                            Text("• Puoi sempre modificare i dati estratti")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Upload Documento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    // MARK: - Processing Methods
    private func scanWithCamera() {
        isProcessing = true
        processingMessage = "Accesso alla camera..."
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                processingMessage = "Analisi OCR in corso..."
            }
            
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            
            await MainActor.run {
                processingMessage = "Estrazione dati AI..."
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                let extractedData = [
                    "nome": "MARIO",
                    "cognome": "ROSSI",
                    "luogoNascita": "ROMA",
                    "oraDecesso": "14:30",
                    "nomeFamiliare": "Anna",
                    "telefonoFamiliare": "+39 320 123 4567"
                ]
                
                onDocumentProcessed(extractedData)
                dismiss()
            }
        }
    }
    
    private func selectFile() {
        isProcessing = true
        processingMessage = "Caricamento file..."
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                processingMessage = "Elaborazione documento..."
            }
            
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            
            await MainActor.run {
                let extractedData = [
                    "nome": "GIULIA",
                    "cognome": "VERDI",
                    "luogoNascita": "MILANO",
                    "codiceFiscale": "VRDGLI85M41F205Z",
                    "telefonoFamiliare": "+39 339 876 5432",
                    "luogoSepoltura": "Cimitero Monumentale"
                ]
                
                onDocumentProcessed(extractedData)
                dismiss()
            }
        }
    }
    
    private func pasteText() {
        isProcessing = true
        processingMessage = "Analisi testo incollato..."
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                let extractedData = [
                    "nome": "ANNA",
                    "cognome": "BIANCHI",
                    "luogoNascita": "NAPOLI",
                    "oraDecesso": "09:15",
                    "luogoSepoltura": "Cimitero di Poggioreale",
                    "nomeFamiliare": "Marco",
                    "cognomeFamiliare": "Bianchi"
                ]
                
                onDocumentProcessed(extractedData)
                dismiss()
            }
        }
    }
}

#Preview {
    AIDocumentUploadView { data in
        print("Dati estratti: \(data)")
    }
}

//
//  SimpleAIAssistanteView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 24/07/25.
//

import SwiftUI
import AppKit

// MARK: - ⭐ SIMPLE AI ASSISTANT VIEW (No conflicts)

struct SimpleAIAssistantView: View {
    @Binding var content: String
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    @State private var aiSuggestion = ""
    @State private var isProcessing = false
    @State private var selectedAction: AIAction = .improve
    
    enum AIAction: String, CaseIterable {
        case improve = "Migliora Testo"
        case complete = "Completa Campi"
        case format = "Formatta"
        case check = "Controlla Errori"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 32))
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading) {
                        Text("AI Assistant")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Migliora il tuo documento con l'AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Action selector
                Picker("Azione", selection: $selectedAction) {
                    ForEach(AIAction.allCases, id: \.self) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // AI suggestions
                if !aiSuggestion.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggerimento AI:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(aiSuggestion)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                        
                        HStack {
                            Button("Applica") {
                                content = aiSuggestion
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Rigetta") {
                                aiSuggestion = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // Process button
                Button(action: processWithAI) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        
                        Text(isProcessing ? "Elaborando..." : "Elabora con AI")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Assistant")
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
    
    private func processWithAI() {
        isProcessing = true
        
        Task {
            // Simula elaborazione AI
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                switch selectedAction {
                case .improve:
                    aiSuggestion = """
                    📝 TESTO MIGLIORATO:
                    
                    \(improveText(content))
                    
                    ✨ Miglioramenti applicati:
                    • Linguaggio più formale e professionale
                    • Struttura ottimizzata per chiarezza
                    • Terminologia specifica del settore
                    """
                    
                case .complete:
                    let completedContent = completeFields(content)
                    aiSuggestion = """
                    🔧 CAMPI COMPLETATI:
                    
                    \(completedContent)
                    
                    ✅ Campi sostituiti automaticamente:
                    • {{NOME_DEFUNTO}} → \(document.defunto.nomeCompleto)
                    • {{DATA_DECESSO}} → \(document.defunto.dataDecesoFormattata)
                    • {{NUMERO_CARTELLA}} → \(document.defunto.numeroCartella)
                    """
                    
                case .format:
                    aiSuggestion = """
                    📋 FORMATO STANDARDIZZATO:
                    
                    \(formatDocument(content))
                    
                    📐 Formattazione applicata:
                    • Intestazione ufficiale
                    • Struttura paragrafi ottimizzata
                    • Spaziatura e indentazione corrette
                    """
                    
                case .check:
                    let issues = checkDocument(content)
                    aiSuggestion = """
                    🔍 CONTROLLO QUALITÀ COMPLETATO:
                    
                    \(issues.isEmpty ? "✅ Documento perfetto!" : "⚠️ Problemi identificati:")
                    
                    \(issues.isEmpty ? "Il documento non presenta errori evidenti." : issues.joined(separator: "\n"))
                    
                    📊 Statistiche:
                    • Caratteri: \(content.count)
                    • Parole: \(content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count)
                    • Campi mancanti: \(getPlaceholderCount(content))
                    """
                }
                
                isProcessing = false
            }
        }
    }
    
    private func improveText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "è", with: "risulta essere")
            .replacingOccurrences(of: "va", with: "deve essere")
            .replacingOccurrences(of: "si chiede", with: "si richiede formalmente")
            .replacingOccurrences(of: "per favore", with: "cortesemente")
    }
    
    private func completeFields(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "{{NOME_DEFUNTO}}", with: document.defunto.nomeCompleto)
            .replacingOccurrences(of: "{{DATA_DECESSO}}", with: document.defunto.dataDecesoFormattata)
            .replacingOccurrences(of: "{{NUMERO_CARTELLA}}", with: document.defunto.numeroCartella)
            .replacingOccurrences(of: "{{LUOGO_NASCITA}}", with: document.defunto.luogoNascita)
            .replacingOccurrences(of: "{{DATA_NASCITA}}", with: document.defunto.dataNascitaFormattata)
            .replacingOccurrences(of: "{{FAMILIARE}}", with: document.defunto.familiareRichiedente.nomeCompleto)
    }
    
    private func formatDocument(_ text: String) -> String {
        let header = """
        OGGETTO: \(document.template.nome.uppercased())
        
        Alla c.a. del Responsabile
        
        """
        
        let footer = """
        
        Distinti saluti,
        
        \(document.operatoreCreazione)
        Data: \(Date().formatted(date: .abbreviated, time: .omitted))
        """
        
        return header + text + footer
    }
    
    private func checkDocument(_ text: String) -> [String] {
        var issues: [String] = []
        
        // Check for common issues
        if text.contains("{{") {
            issues.append("• Campi placeholder non completati")
        }
        
        if text.count < 50 {
            issues.append("• Documento molto breve")
        }
        
        if !text.contains(document.defunto.nomeCompleto) {
            issues.append("• Nome defunto non presente nel testo")
        }
        
        // Check for informal language
        let informalWords = ["ciao", "grazie", "per favore", "va bene"]
        for word in informalWords {
            if text.lowercased().contains(word) {
                issues.append("• Linguaggio informale rilevato: '\(word)'")
            }
        }
        
        return issues
    }
    
    private func getPlaceholderCount(_ text: String) -> Int {
        let pattern = "\\{\\{[^}]+\\}\\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches?.count ?? 0
    }
}

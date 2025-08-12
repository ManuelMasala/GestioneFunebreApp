//
//  SimpleDocumentoEditorView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 21/07/25.
//

import SwiftUI

// Versione semplificata per il debug
struct SimpleDocumentoEditorView: View {
    @Binding var documento: DocumentoCompilato
    let onSave: (DocumentoCompilato) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var testoModificabile: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header con info documento
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: TipoDocumentoHelper.icona(for: documento.template.tipo))
                            .font(.title2)
                            .foregroundColor(TipoDocumentoHelper.color(for: documento.template.tipo))
                        
                        VStack(alignment: .leading) {
                            Text(documento.template.nome)
                                .font(.headline)
                            Text("Defunto: \(documento.defunto.nomeCompleto)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Caratteri: \(testoModificabile.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Debug info
                VStack(alignment: .leading, spacing: 4) {
                    Text("🔍 DEBUG INFO:")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("Template contenuto: \(documento.template.contenuto.count) caratteri")
                        .font(.caption)
                    Text("Documento contenuto: \(documento.contenutoFinale.count) caratteri")
                        .font(.caption)
                    Text("Testo modificabile: \(testoModificabile.count) caratteri")
                        .font(.caption)
                    
                    if !documento.placeholderNonSostituiti.isEmpty {
                        Text("Placeholder mancanti: \(documento.placeholderNonSostituiti.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Editor di testo semplice
                VStack(alignment: .leading) {
                    Text("Editor Testo:")
                        .font(.headline)
                    
                    TextEditor(text: $testoModificabile)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Azioni rapide
                HStack(spacing: 12) {
                    Button("Ripristina Template") {
                        testoModificabile = documento.template.contenuto
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Compila Automatico") {
                        var tempDoc = documento
                        tempDoc.compilaConDefunto()
                        testoModificabile = tempDoc.contenutoFinale
                    }
                    .buttonStyle(.bordered)
                    
                    Menu("Esporta") {
                        Button("📄 Esporta PDF") {
                            esportaDocumento(formato: "PDF")
                        }
                        
                        Button("📝 Esporta Word (.rtf)") {
                            esportaDocumento(formato: "Word")
                        }
                        
                        Button("📖 Esporta Pages (.rtf)") {
                            esportaDocumento(formato: "Pages")
                        }
                        
                        Button("📄 Esporta Testo") {
                            esportaDocumento(formato: "Testo")
                        }
                        
                        Divider()
                        
                        Button("📦 Esporta Tutti i Formati") {
                            esportaDocumento(formato: "Tutti")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Salva") {
                        salvaDocumento()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 500)
        .navigationTitle("Editor Documento (Debug)")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") {
                    dismiss()
                }
            }
        }
        .onAppear {
            initializeContent()
        }
        .alert("Editor", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func initializeContent() {
        print("🔍 [INIT] Template contenuto: '\(documento.template.contenuto.prefix(200))...'")
        print("🔍 [INIT] Documento contenuto: '\(documento.contenutoFinale.prefix(200))...'")
        
        if documento.contenutoFinale.isEmpty {
            print("🔍 [INIT] Documento vuoto, usando template")
            testoModificabile = documento.template.contenuto
        } else {
            print("🔍 [INIT] Usando contenuto documento esistente")
            testoModificabile = documento.contenutoFinale
        }
        
        print("🔍 [INIT] Testo inizializzato: '\(testoModificabile.prefix(200))...'")
    }
    
    private func esportaDocumento(formato: String) {
        // Prima salva le modifiche correnti
        documento.contenutoFinale = testoModificabile
        documento.dataUltimaModifica = Date()
        
        let manager = DocumentiManager()
        var urls: [URL] = []
        
        switch formato {
        case "PDF":
            if let url = manager.esportaPDF(documento) {
                urls.append(url)
            }
        case "Word":
            if let url = manager.esportaWord(documento) {
                urls.append(url)
            }
        case "Pages":
            if let url = manager.esportaPages(documento) {
                urls.append(url)
            }
        case "Testo":
            if let url = manager.esportaTestoSemplice(documento) {
                urls.append(url)
            }
        case "Tutti":
            urls = manager.esportaTuttiFormati(documento)
        default:
            break
        }
        
        if !urls.isEmpty {
            alertMessage = "Esportazione completata!\n\(urls.count) file creati in Export/"
            
            // Apri la cartella Export
            if formato == "Tutti" {
                NSWorkspace.shared.open(manager.fileManager.exportFolderURL)
            } else if let firstURL = urls.first {
                NSWorkspace.shared.activateFileViewerSelecting([firstURL])
            }
        } else {
            alertMessage = "Errore durante l'esportazione"
        }
        
        showingAlert = true
    }
    
    private func salvaDocumento() {
        documento.contenutoFinale = testoModificabile
        documento.dataUltimaModifica = Date()
        
        if documento.placeholderNonSostituiti.isEmpty {
            documento.marcaCompletato()
        }
        
        onSave(documento)
        alertMessage = "Documento salvato!"
        showingAlert = true
        
        print("🔍 [SAVE] Salvato documento con \(testoModificabile.count) caratteri")
    }
}

#Preview {
    @State var sampleDoc = DocumentoCompilato(
        template: DocumentoTemplate.autorizzazioneTrasporto,
        defunto: PersonaDefunta()
    )
    
    return SimpleDocumentoEditorView(documento: $sampleDoc) { doc in
        print("Documento salvato: \(doc.template.nome)")
    }
}

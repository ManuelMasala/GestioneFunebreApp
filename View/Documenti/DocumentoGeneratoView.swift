//
//  DocumentiGenarati.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI

struct DocumentoGeneretoView: View {
    @State var documento: DocumentoCompilato
    let onSave: (DocumentoCompilato) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSaveAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header semplificato
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: documento.template.tipo.icona)
                            .font(.title)
                            .foregroundColor(documento.template.tipo.color)
                        
                        VStack(alignment: .leading) {
                            Text(documento.template.nome)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Defunto: \(documento.defunto.nomeCompleto)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Tab selector
                Picker("Vista", selection: $selectedTab) {
                    Text("Anteprima").tag(0)
                    Text("Azioni").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content
                if selectedTab == 0 {
                    // Anteprima documento
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contenuto Documento:")
                                .font(.headline)
                            
                            Text(documento.contenutoFinale)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .textSelection(.enabled)
                        }
                        .padding()
                    }
                } else {
                    // Azioni
                    VStack(spacing: 20) {
                        Button(action: stampaDocumento) {
                            HStack {
                                Image(systemName: "printer.fill")
                                Text("Stampa Documento")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: copiaDocumento) {
                            HStack {
                                Image(systemName: "doc.on.doc.fill")
                                Text("Copia Testo")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: salvaDocumento) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Salva Documento")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Documento Generato")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
        .alert("Operazione Completata", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text("L'operazione è stata completata con successo!")
        }
    }
    
    // MARK: - Actions
    private func stampaDocumento() {
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        
        let printView = createPrintView()
        let printOperation = NSPrintOperation(view: printView)
        printOperation.printInfo = printInfo
        printOperation.showsPrintPanel = true
        printOperation.run()
        
        showingSaveAlert = true
    }
    
    private func copiaDocumento() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documento.contenutoFinale, forType: .string)
        
        showingSaveAlert = true
    }
    
    private func salvaDocumento() {
        documento.dataUltimaModifica = Date()
        onSave(documento)
        
        // Salva anche come file
        salvaComePDF()
        
        showingSaveAlert = true
    }
    
    private func createPrintView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 595, height: 842)) // A4 size
        
        let textView = NSTextView(frame: view.bounds.insetBy(dx: 20, dy: 20))
        textView.string = documento.contenutoFinale
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.isEditable = false
        textView.backgroundColor = NSColor.white
        
        view.addSubview(textView)
        return view
    }
    
    private func salvaComePDF() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "\(documento.template.nome) - \(documento.defunto.cognome).pdf"
        savePanel.title = "Salva Documento come PDF"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                creaPDF(url: url)
            }
        }
    }
    
    private func creaPDF(url: URL) {
        let pdfView = createPrintView()
        
        let pdfData = pdfView.dataWithPDF(inside: pdfView.bounds)
        
        do {
            try pdfData.write(to: url)
            print("PDF salvato in: \(url.path)")
        } catch {
            print("Errore nel salvare il PDF: \(error)")
        }
    }
}

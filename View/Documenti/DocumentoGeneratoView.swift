//
//  DocumentiGenarati.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI
import AppKit

struct DocumentoGeneretoView: View {
    @State var documento: DocumentoCompilato
    let onSave: (DocumentoCompilato) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSaveAlert = false
    @State private var selectedTab = 0
    @State private var showingSavePanel = false
    @State private var showingLocationChoice = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
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
                        // Stampa
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
                        
                        // Copia testo
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
                        
                        // Salva nell'app
                        Button(action: salvaDocumentoNellApp) {
                            HStack {
                                Image(systemName: "internaldrive.fill")
                                Text("Salva nell'App")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Esporta su computer
                        Button(action: esportaSuComputer) {
                            HStack {
                                Image(systemName: "externaldrive.fill")
                                Text("Esporta su Computer")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
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
        .frame(width: 900, height: 700)
        .alert(alertTitle, isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    
    private func stampaDocumento() {
        // Configurazione stampa migliorata
        let printInfo = NSPrintInfo.shared
        printInfo.orientation = .portrait
        printInfo.paperSize = NSMakeSize(595, 842) // A4
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        
        // Crea la view per la stampa
        let printView = createPrintView()
        
        // Operazione di stampa
        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.printInfo = printInfo
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.jobTitle = "\(documento.template.nome) - \(documento.defunto.cognome)"
        
        // Esegui stampa
        printOperation.run()
        
        mostraMessaggio(titolo: "Stampa", messaggio: "Documento inviato alla stampante!")
    }
    
    private func copiaDocumento() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documento.contenutoFinale, forType: .string)
        
        mostraMessaggio(titolo: "Copiato", messaggio: "Testo documento copiato negli appunti!")
    }
    
    private func salvaDocumentoNellApp() {
        // Salva il documento nel sistema interno dell'app
        documento.dataUltimaModifica = Date()
        onSave(documento)
        
        mostraMessaggio(titolo: "Salvato", messaggio: "Documento salvato nell'archivio dell'app!")
    }
    
    private func esportaSuComputer() {
        // Apri il pannello di salvataggio
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf, .plainText]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Esporta Documento"
        savePanel.message = "Scegli dove salvare il documento"
        savePanel.nameFieldLabel = "Nome file:"
        
        // Nome file suggerito
        let nomeFile = "\(documento.template.nome) - \(documento.defunto.cognome)"
        savePanel.nameFieldStringValue = nomeFile
        
        // Mostra il pannello
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                esportaDocumento(url: url)
            }
        }
    }
    
    private func esportaDocumento(url: URL) {
        do {
            let pathExtension = url.pathExtension.lowercased()
            
            switch pathExtension {
            case "pdf":
                try creaPDF(url: url)
                mostraMessaggio(titolo: "Esportato", messaggio: "Documento PDF salvato in:\n\(url.path)")
                
            case "txt":
                try documento.contenutoFinale.write(to: url, atomically: true, encoding: .utf8)
                mostraMessaggio(titolo: "Esportato", messaggio: "Documento TXT salvato in:\n\(url.path)")
                
            default:
                // Default a PDF se estensione non riconosciuta
                let pdfURL = url.appendingPathExtension("pdf")
                try creaPDF(url: pdfURL)
                mostraMessaggio(titolo: "Esportato", messaggio: "Documento PDF salvato in:\n\(pdfURL.path)")
            }
            
            // Salva anche nell'app dopo esportazione
            documento.dataUltimaModifica = Date()
            onSave(documento)
            
        } catch {
            mostraMessaggio(titolo: "Errore", messaggio: "Impossibile salvare il documento:\n\(error.localizedDescription)")
        }
    }
    
    private func createPrintView() -> NSView {
        let pageSize = NSMakeSize(595, 842) // A4 in punti
        let view = NSView(frame: NSRect(origin: .zero, size: pageSize))
        
        // Margini
        let margins = NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        let contentRect = NSRect(
            x: margins.left,
            y: margins.bottom,
            width: pageSize.width - margins.left - margins.right,
            height: pageSize.height - margins.top - margins.bottom
        )
        
        // TextView per il contenuto
        let textView = NSTextView(frame: contentRect)
        textView.string = documento.contenutoFinale
        textView.font = NSFont(name: "Times New Roman", size: 12) ?? NSFont.systemFont(ofSize: 12)
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = NSColor.white
        textView.textColor = NSColor.black
        textView.textContainer?.lineFragmentPadding = 0
        
        view.addSubview(textView)
        return view
    }
    
    private func creaPDF(url: URL) throws {
        let pdfData = NSMutableData()
        
        // Crea il contesto PDF
        guard let dataConsumer = CGDataConsumer(data: pdfData),
              let pdfContext = CGContext(consumer: dataConsumer, mediaBox: nil, nil) else {
            throw DocumentError.pdfCreationFailed
        }
        
        // Dimensioni pagina A4
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        
        // Inizia pagina
        pdfContext.beginPDFPage(nil)
        
        // Configura testo
        pdfContext.textMatrix = .identity
        pdfContext.translateBy(x: 50, y: 792) // Margine superiore
        
        // Disegna il contenuto
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Times New Roman", size: 12) ?? NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: documento.contenutoFinale, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        // Area di testo (con margini)
        let textRect = CGRect(x: 0, y: -742, width: 495, height: 742)
        let path = CGPath(rect: textRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        
        CTFrameDraw(frame, pdfContext)
        
        // Termina pagina e PDF
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        // Salva il file
        try pdfData.write(to: url)
    }
    
    private func mostraMessaggio(titolo: String, messaggio: String) {
        alertTitle = titolo
        alertMessage = messaggio
        showingSaveAlert = true
    }
}

// MARK: - Document Error
enum DocumentError: Error, LocalizedError {
    case pdfCreationFailed
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .pdfCreationFailed:
            return "Impossibile creare il file PDF"
        case .fileWriteFailed:
            return "Impossibile scrivere il file"
        }
    }
}

#Preview {
    DocumentoGeneretoView(
        documento: DocumentoCompilato(
            template: DocumentoTemplate.autorizzazioneTrasporto,
            defunto: PersonaDefunta()
        )
    ) { _ in
        print("Documento salvato")
    }
}

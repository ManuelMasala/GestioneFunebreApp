//
//  DocumentoPreviuwView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI
import AppKit

struct DocumentoPreviewView: View {
    let documento: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Contenuto del documento
                    contenutoSection
                    
                    // Info documento
                    if !documento.placeholderNonSostituiti.isEmpty {
                        placeholderSection
                    }
                    
                    // Informazioni aggiuntive
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Anteprima Documento")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Copia") {
                        copiaTesto()
                    }
                    
                    Button("Esporta") {
                        esportaDocumento()
                    }
                    
                    Button("Stampa") {
                        stampaDocumento()
                    }
                    
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 900, height: 700)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: documento.template.tipo.icona)
                    .font(.title)
                    .foregroundColor(documento.template.tipo.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(documento.template.nome)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Defunto: \(documento.defunto.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Cartella N° \(documento.defunto.numeroCartella)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(documento.isCompletato ? Color.green : Color.orange)
                            .frame(width: 12, height: 12)
                        
                        Text(documento.isCompletato ? "Completato" : "Bozza")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(documento.isCompletato ? .green : .orange)
                    }
                    
                    Text("Generato: \(documento.dataCreazione.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if documento.dataUltimaModifica != documento.dataCreazione {
                        Text("Modificato: \(documento.dataUltimaModifica.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
        }
    }
    
    // MARK: - Contenuto Section
    private var contenutoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Contenuto Documento")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Contatore caratteri
                Text("\(documento.contenutoFinale.count) caratteri")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                Text(documento.contenutoFinale)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 400)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Placeholder Section
    private var placeholderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Placeholder Non Sostituiti")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(documento.placeholderNonSostituiti.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(documento.placeholderNonSostituiti, id: \.self) { placeholder in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("{{\(placeholder)}}")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Informazioni Documento")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InfoCard(
                    titolo: "Template",
                    valore: documento.template.nome,
                    icona: "doc.text.fill",
                    colore: .blue
                )
                
                InfoCard(
                    titolo: "Tipo",
                    valore: documento.template.tipo.rawValue,
                    icona: documento.template.tipo.icona,
                    colore: documento.template.tipo.color
                )
                
                InfoCard(
                    titolo: "Campi Compilati",
                    valore: "\(documento.valoriCampi.count)/\(documento.template.campiCompilabili.count)",
                    icona: "list.bullet",
                    colore: .green
                )
                
                InfoCard(
                    titolo: "Stato",
                    valore: documento.isCompletato ? "Completato" : "Bozza",
                    icona: documento.isCompletato ? "checkmark.circle.fill" : "clock.fill",
                    colore: documento.isCompletato ? .green : .orange
                )
            }
            
            // Note se presenti
            if !documento.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.purple)
                        
                        Text("Note")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    
                    Text(documento.note)
                        .font(.body)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Actions MIGLIORATE
    
    private func copiaTesto() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documento.contenutoFinale, forType: .string)
        
        mostraAlert(titolo: "Copiato", messaggio: "Testo copiato negli appunti!")
    }
    
    private func esportaDocumento() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf, .plainText]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Esporta Documento"
        savePanel.message = "Scegli dove salvare il documento"
        
        // Nome file suggerito
        let nomeFile = "\(documento.template.nome) - \(documento.defunto.cognome)"
        savePanel.nameFieldStringValue = nomeFile
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                salvaDocumento(url: url)
            }
        }
    }
    
    private func salvaDocumento(url: URL) {
        do {
            let pathExtension = url.pathExtension.lowercased()
            
            switch pathExtension {
            case "pdf":
                try creaPDF(url: url)
                mostraAlert(titolo: "Esportato", messaggio: "PDF salvato in:\n\(url.path)")
                
            default:
                try documento.contenutoFinale.write(to: url, atomically: true, encoding: .utf8)
                mostraAlert(titolo: "Esportato", messaggio: "File salvato in:\n\(url.path)")
            }
        } catch {
            mostraAlert(titolo: "Errore", messaggio: "Impossibile salvare: \(error.localizedDescription)")
        }
    }
    
    private func stampaDocumento() {
        // Configurazione stampa migliorata
        let printInfo = NSPrintInfo.shared
        printInfo.orientation = .portrait
        printInfo.paperSize = NSMakeSize(595, 842) // A4
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        
        // Crea view per stampa
        let printView = createPrintView()
        
        // Operazione stampa
        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.jobTitle = "\(documento.template.nome) - \(documento.defunto.cognome)"
        
        printOperation.run()
        
        mostraAlert(titolo: "Stampa", messaggio: "Documento inviato alla stampante!")
    }
    
    private func createPrintView() -> NSView {
        let pageSize = NSMakeSize(595, 842) // A4
        let view = NSView(frame: NSRect(origin: .zero, size: pageSize))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        // Margini
        let contentRect = NSRect(x: 50, y: 50, width: 495, height: 742)
        
        // TextView
        let textView = NSTextView(frame: contentRect)
        textView.string = documento.contenutoFinale
        textView.font = NSFont(name: "Times New Roman", size: 12) ?? NSFont.systemFont(ofSize: 12)
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.black
        
        view.addSubview(textView)
        return view
    }
    
    private func creaPDF(url: URL) throws {
        let pdfData = NSMutableData()
        
        guard let dataConsumer = CGDataConsumer(data: pdfData),
              let pdfContext = CGContext(consumer: dataConsumer, mediaBox: nil, nil) else {
            throw DocumentError.pdfCreationFailed
        }
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        pdfContext.beginPDFPage(nil)
        
        // Disegna il testo
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Times New Roman", size: 12) ?? NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: documento.contenutoFinale, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let textRect = CGRect(x: 50, y: 50, width: 495, height: 742)
        let path = CGPath(rect: textRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        
        // Flip coordinate system for PDF
        pdfContext.textMatrix = .identity
        pdfContext.translateBy(x: 0, y: pageRect.height)
        pdfContext.scaleBy(x: 1, y: -1)
        
        CTFrameDraw(frame, pdfContext)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        try pdfData.write(to: url)
    }
    
    private func mostraAlert(titolo: String, messaggio: String) {
        alertTitle = titolo
        alertMessage = messaggio
        showingAlert = true
    }
}

// MARK: - Info Card (invariata)
struct InfoCard: View {
    let titolo: String
    let valore: String
    let icona: String
    let colore: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icona)
                .font(.title3)
                .foregroundColor(colore)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titolo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(valore)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

#Preview {
    DocumentoPreviewView(
        documento: DocumentoCompilato(
            template: DocumentoTemplate.autorizzazioneTrasporto,
            defunto: PersonaDefunta()
        )
    )
}

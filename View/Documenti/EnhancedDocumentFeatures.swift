//
//  EnhancedDocumentFeatures.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 22/07/25.
//
import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers

// MARK: - ⭐ ENHANCED DOCUMENT FEATURES - VERSIONE PULITA

// Estensione per gestione eliminazione documenti
extension DocumentiManager {
    // Elimina documento compilato (invariato)
    func eliminaDocumentoCompilato(_ documento: DocumentoCompilato) {
        documentiCompilati.removeAll { $0.id == documento.id }
    }
    
    // Elimina template (invariato)
    func eliminaTemplate(_ template: DocumentoTemplate) {
        templates.removeAll { $0.id == template.id }
    }
    
    // ⭐ CORREZIONE: Duplica documento senza usare init custom
    func duplicaDocumentoEnhanced(_ documento: DocumentoCompilato) -> DocumentoCompilato {
        // Crea nuovo template modificando solo il nome
        var nuovoTemplate = documento.template
        if !nuovoTemplate.nome.contains("(Copia)") {
            nuovoTemplate.nome += " (Copia)"
        }
        
        // ⭐ USA IL TUO METODO ESISTENTE invece di init custom
        var nuovoDocumento = creaDocumentoCompilato(template: nuovoTemplate, defunto: documento.defunto)
        
        // Copia il contenuto esistente se presente
        if !documento.contenutoFinale.isEmpty {
            nuovoDocumento.contenutoFinale = documento.contenutoFinale
        }
        
        // Copia le note aggiungendo info duplicazione
        nuovoDocumento.note = documento.note
        if !documento.note.isEmpty {
            nuovoDocumento.note += "\n\n"
        }
        nuovoDocumento.note += "[Duplicato da '\(documento.template.nome)' il \(Date().formatted(date: .abbreviated, time: .shortened))]"
        
        return nuovoDocumento
    }
}

// MARK: - ⭐ PDF READER ENHANCED

class EnhancedPDFReader {
    
    // Legge contenuto PDF
    static func extractTextFromPDF(url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("❌ Impossibile aprire PDF: \(url.path)")
            return nil
        }
        
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        print("📄 PDF ha \(pageCount) pagine")
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            if let pageText = page.string {
                let cleanedText = cleanExtractedText(pageText)
                fullText += "--- PAGINA \(pageIndex + 1) ---\n"
                fullText += cleanedText
                fullText += "\n\n"
            }
        }
        
        return fullText.isEmpty ? nil : fullText
    }
    
    // Pulisce il testo estratto dal PDF
    private static func cleanExtractedText(_ text: String) -> String {
        var cleaned = text
        
        // Rimuove caratteri di controllo eccessivi
        cleaned = cleaned.replacingOccurrences(of: "\r\n", with: "\n")
        cleaned = cleaned.replacingOccurrences(of: "\r", with: "\n")
        
        // Rimuove righe vuote multiple
        let lines = cleaned.components(separatedBy: .newlines)
        var processedLines: [String] = []
        var consecutiveEmptyLines = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty {
                consecutiveEmptyLines += 1
                if consecutiveEmptyLines <= 1 {
                    processedLines.append("")
                }
            } else {
                consecutiveEmptyLines = 0
                processedLines.append(trimmedLine)
            }
        }
        
        return processedLines.joined(separator: "\n")
    }
    
    // Estrae metadati dal PDF
    static func extractPDFMetadata(url: URL) -> [String: String] {
        guard let pdfDocument = PDFDocument(url: url) else { return [:] }
        
        var metadata: [String: String] = [:]
        
        if let title = pdfDocument.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
            metadata["Titolo"] = title
        }
        
        if let author = pdfDocument.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String {
            metadata["Autore"] = author
        }
        
        if let subject = pdfDocument.documentAttributes?[PDFDocumentAttribute.subjectAttribute] as? String {
            metadata["Oggetto"] = subject
        }
        
        metadata["Pagine"] = "\(pdfDocument.pageCount)"
        
        return metadata
    }
}

// MARK: - ⭐ ENHANCED FILE PROCESSOR

class EnhancedFileProcessor {
    
    // Processa file con AI
    static func processFileWithEnhancedAI(url: URL, aiManager: CompatibleAIManager) async -> DocumentoTemplate? {
        let filename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.lowercased()
        
        var contenuto = ""
        var tipo: TipoDocumento = .altro
        var metadata: [String: String] = [:]
        
        print("🔄 Elaborazione file: \(filename).\(ext)")
        
        switch ext {
        case "pdf":
            if let pdfText = EnhancedPDFReader.extractTextFromPDF(url: url) {
                contenuto = pdfText
                metadata = EnhancedPDFReader.extractPDFMetadata(url: url)
                tipo = determineTipoFromContent(contenuto)
                print("✅ PDF elaborato: \(contenuto.count) caratteri estratti")
            } else {
                contenuto = "⚠️ PDF importato: \(filename)\n[Impossibile estrarre il contenuto automaticamente]"
                print("⚠️ Impossibile estrarre testo dal PDF")
            }
            
        case "txt", "rtf":
            do {
                contenuto = try String(contentsOf: url, encoding: .utf8)
                tipo = determineTipoFromContent(contenuto)
                print("✅ File di testo elaborato: \(contenuto.count) caratteri")
            } catch {
                contenuto = "❌ Errore lettura file: \(error.localizedDescription)"
                print("❌ Errore lettura file di testo: \(error)")
            }
            
        case "doc", "docx":
            contenuto = "📄 Documento Word: \(filename)\n[Formato Word non ancora supportato per l'estrazione automatica]"
            tipo = .comunicazioneParrocchia
            
        default:
            contenuto = "📎 File importato: \(filename).\(ext)\n[Tipo file non riconosciuto per elaborazione automatica]"
        }
        
        // Crea template con metadati enhanced
        var template = DocumentoTemplate(
            nome: "AI-\(filename)",
            tipo: tipo,
            contenuto: generateEnhancedAIContent(originalContent: contenuto, metadata: metadata, filename: filename),
            operatoreCreazione: "AI Assistant Enhanced"
        )
        
        template.markAsAIGenerated(confidence: calculateConfidence(for: contenuto, ext: ext))
        
        return template
    }
    
    // Determina tipo documento dal contenuto
    private static func determineTipoFromContent(_ content: String) -> TipoDocumento {
        let contentLower = content.lowercased()
        
        if contentLower.contains("trasporto") || contentLower.contains("verbale") || contentLower.contains("cadavere") {
            return .autorizzazioneTrasporto
        } else if contentLower.contains("parrocchia") || contentLower.contains("funerale") || contentLower.contains("chiesa") {
            return .comunicazioneParrocchia
        } else if contentLower.contains("checklist") || contentLower.contains("lista") || contentLower.contains("controllo") {
            return .checklistFunerale
        } else if contentLower.contains("certificato") || contentLower.contains("morte") || contentLower.contains("decesso") {
            return .certificatoMorte
        } else if contentLower.contains("fattura") || contentLower.contains("pagamento") {
            return .fattura
        } else if contentLower.contains("contratto") || contentLower.contains("accordo") {
            return .contratto
        } else if contentLower.contains("ricevuta") || contentLower.contains("scontrino") {
            return .ricevuta
        } else {
            return .altro
        }
    }
    
    // Calcola confidence
    private static func calculateConfidence(for content: String, ext: String) -> Double {
        var confidence: Double = 0.5
        
        switch ext {
        case "pdf": confidence += 0.3
        case "txt", "rtf": confidence += 0.2
        case "doc", "docx": confidence += 0.1
        default: confidence += 0.0
        }
        
        if content.count > 100 { confidence += 0.1 }
        if content.count > 500 { confidence += 0.1 }
        
        if content.contains("❌") || content.contains("⚠️") {
            confidence -= 0.2
        }
        
        return max(0.1, min(1.0, confidence))
    }
    
    // Genera contenuto AI enhanced
    private static func generateEnhancedAIContent(originalContent: String, metadata: [String: String], filename: String) -> String {
        var aiContent = "🧠 Documento elaborato con AI Enhanced\n"
        aiContent += "📂 File: \(filename)\n"
        
        if !metadata.isEmpty {
            aiContent += "\n📋 METADATI:\n"
            for (key, value) in metadata {
                aiContent += "• \(key): \(value)\n"
            }
        }
        
        aiContent += "\n" + String(repeating: "=", count: 50) + "\n"
        aiContent += "CONTENUTO ESTRATTO:\n"
        aiContent += String(repeating: "=", count: 50) + "\n\n"
        aiContent += originalContent
        
        aiContent += "\n\n" + String(repeating: "-", count: 40)
        aiContent += "\n✨ Elaborato automaticamente da AI Assistant Enhanced"
        aiContent += "\n⏰ Data elaborazione: \(Date().formatted(date: .abbreviated, time: .shortened))"
        
        return aiContent
    }
}

// MARK: - ⭐ UTILITY CLASSE STATICA

class DocumentEnhancementUtils {
    
    // Import singolo file con AI
    static func importSingleFileWithAI(
        _ url: URL,
        aiManager: CompatibleAIManager,
        completion: @escaping (DocumentoTemplate?) -> Void
    ) {
        Task {
            let steps = ["Analisi file...", "Estrazione contenuto...", "Elaborazione AI...", "Finalizzazione..."]
            
            for step in steps {
                await aiManager.simulateAIProcess(task: step, duration: 800_000_000)
            }
            
            let template = await EnhancedFileProcessor.processFileWithEnhancedAI(url: url, aiManager: aiManager)
            
            await MainActor.run {
                completion(template)
            }
        }
    }
    
    // Import multipli file con AI
    static func importMultipleFilesWithAI(
        _ urls: [URL],
        aiManager: CompatibleAIManager,
        progressCallback: @escaping (Int, Int) -> Void,
        completion: @escaping (Int, Int) -> Void
    ) {
        Task {
            var successCount = 0
            var failCount = 0
            
            for (index, url) in urls.enumerated() {
                await aiManager.simulateAIProcess(task: "Elaborazione \(url.lastPathComponent)...", duration: 1_000_000_000)
                
                if let _ = await EnhancedFileProcessor.processFileWithEnhancedAI(url: url, aiManager: aiManager) {
                    successCount += 1
                } else {
                    failCount += 1
                }
                
                await MainActor.run {
                    progressCallback(index + 1, urls.count)
                }
            }
            
            await MainActor.run {
                completion(successCount, failCount)
            }
        }
    }
    
    // Conferma eliminazione documento
    static func showDeleteDocumentDialog(_ documento: DocumentoCompilato) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Conferma Eliminazione"
        alert.informativeText = "Sei sicuro di voler eliminare il documento '\(documento.template.nome)' per \(documento.defunto.nomeCompleto)?\n\n⚠️ Questa azione non può essere annullata."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Elimina")
        alert.addButton(withTitle: "Annulla")
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    // Conferma eliminazione template
    static func showDeleteTemplateDialog(_ template: DocumentoTemplate) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Conferma Eliminazione"
        alert.informativeText = "Sei sicuro di voler eliminare il template '\(template.nome)'?\n\n⚠️ Questa azione non può essere annullata."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Elimina")
        alert.addButton(withTitle: "Annulla")
        
        return alert.runModal() == .alertFirstButtonReturn
    }
}

// MARK: - ⭐ UI COMPONENTS

struct EnhancedDeleteConfirmation: View {
    let itemName: String
    let itemType: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("Conferma Eliminazione")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Sei sicuro di voler eliminare questo \(itemType)?")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("\"\(itemName)\"")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
            }
            
            Text("⚠️ Questa azione non può essere annullata")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            
            HStack(spacing: 16) {
                Button("Annulla") {
                    onCancel()
                }
                .keyboardShortcut(.escape)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                Button("Elimina") {
                    onConfirm()
                }
                .keyboardShortcut(.return)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

struct EnhancedImportProgress: View {
    let fileName: String
    let progress: Double
    let currentStep: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 40))
                .foregroundColor(.purple)
                .scaleEffect(progress > 0 ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            VStack(spacing: 8) {
                Text("Elaborazione AI in corso...")
                    .font(.headline)
                
                Text(fileName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(currentStep)
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .frame(width: 200)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

// MARK: - ⭐ REMOVED DUPLICATE STRUCTS
// EnhancedTemplateCard and EnhancedDocumentCard moved to appropriate files
// to avoid conflicts with other implementations

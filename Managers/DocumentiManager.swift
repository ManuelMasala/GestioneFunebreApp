//
//  DocumentiManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import Foundation
import SwiftUI

// MARK: - ⭐ DOCUMENTI MANAGER POTENZIATO CON ADOBE - VERSIONE FINALE

class DocumentiManager: ObservableObject {
    @Published var templates: [DocumentoTemplate] = []
    @Published var documentiCompilati: [DocumentoCompilato] = []
    
    let fileManager = FileManagerDocumenti()
    let adobeManager = AdobePDFManager.shared
    
    // ✅ RISULTATO ANALISI INTERNO PER EVITARE CONFLITTI
    struct AnalisiDocumento {
        let quality: Double
        let detectedType: TipoDocumento
        let suggestions: [String]
        let wordCount: Int
        let characterCount: Int
        let lineCount: Int
        
        var qualityDescription: String {
            if quality > 0.8 { return "Eccellente" }
            else if quality > 0.6 { return "Buona" }
            else if quality > 0.4 { return "Discreta" }
            else { return "Scarsa" }
        }
    }
    
    init() {
        caricaTemplatesPredefiniti()
        caricaTemplatePersonalizzati()
        caricaDocumentiSalvati()
    }
    
    // MARK: - ⭐ TEMPLATE MANAGEMENT (ESISTENTE + POTENZIATO)
    
    private func caricaTemplatesPredefiniti() {
        templates = [
            DocumentoTemplate.autorizzazioneTrasporto,
            DocumentoTemplate.comunicazioneParrocchia,
            DocumentoTemplate.checklistFunerale
        ]
    }
    
    // 🔥 NUOVO: Import template con Adobe OCR
    func importaTemplateConAdobe(da url: URL) async throws -> DocumentoTemplate {
        // Estrai testo con Adobe OCR
        let extractedText = try await adobeManager.extractTextFromPDF(fileURL: url)
        
        // Analizza con AI per rilevare tipo
        let adobeAnalysis = try await adobeManager.analyzeDocument(content: extractedText)
        
        // ✅ CORREZIONE: Conversione corretta Adobe → TipoDocumento
        let detectedType = self.convertAdobeToLocal(adobeAnalysis.detectedType)
        
        // Crea template
        let template = DocumentoTemplate(
            nome: "Template da \(url.lastPathComponent)",
            tipo: detectedType,
            contenuto: extractedText,
            campiCompilabili: estraiCampiDaContenuto(extractedText),
            isDefault: false,
            note: "Importato con Adobe OCR - Qualità: \(qualityFromDouble(adobeAnalysis.quality))",
            operatoreCreazione: "Adobe OCR Import"
        )
        
        templates.append(template)
        return template
    }
    
    // 🔥 NUOVO: Analizza template esistente
    func analizzaTemplate(_ template: DocumentoTemplate) async throws -> AnalisiDocumento {
        // ✅ CORREZIONE: Conversione da Adobe a tipo locale
        let adobeAnalysis = try await adobeManager.analyzeDocument(content: template.contenuto)
        
        let wordCount = template.contenuto.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let characterCount = template.contenuto.count
        let lineCount = template.contenuto.components(separatedBy: .newlines).count
        
        return AnalisiDocumento(
            quality: adobeAnalysis.quality,
            detectedType: self.convertAdobeToLocal(adobeAnalysis.detectedType),
            suggestions: adobeAnalysis.suggestions,
            wordCount: wordCount,
            characterCount: characterCount,
            lineCount: lineCount
        )
    }
    
    // MARK: - ⭐ DOCUMENTO CREATION (ESISTENTE)
    
    func creaDocumentoCompilato(template: DocumentoTemplate, defunto: PersonaDefunta) -> DocumentoCompilato {
        var documento = DocumentoCompilato(template: template, defunto: defunto)
        documento.compilaConDefunto()
        return documento
    }
    
    // MARK: - ⭐ SALVATAGGIO CON FILE SYSTEM (ESISTENTE)
    
    func salvaDocumentoCompilato(_ documento: DocumentoCompilato) {
        do {
            let fileURL = try fileManager.salvaDocumentoCompilato(documento)
            let _ = try fileManager.salvaDocumentoJSON(documento)
            
            if let index = documentiCompilati.firstIndex(where: { $0.id == documento.id }) {
                documentiCompilati[index] = documento
            } else {
                documentiCompilati.append(documento)
            }
            
            documentiCompilati.sort { $0.dataCreazione > $1.dataCreazione }
            print("✅ Documento salvato: \(fileURL.lastPathComponent)")
            
        } catch {
            print("❌ Errore salvataggio: \(error)")
        }
    }
    
    // 🔥 NUOVO: Salva documento con Adobe processing
    func salvaDocumentoConAdobe(_ documento: DocumentoCompilato, formato: FormatoEsportazione = .testoSemplice) async throws -> URL {
        
        switch formato {
        case .pdf:
            // Genera PDF con Adobe
            let pdfData = try documento.creaPDF()
            let fileName = "\(documento.nomeFileConsigliato).pdf"
            let pdfURL = fileManager.exportFolderURL.appendingPathComponent(fileName)
            try pdfData.write(to: pdfURL)
            return pdfURL
            
        case .testoSemplice:
            return try fileManager.salvaDocumentoCompilato(documento)
            
        case .json:
            return try fileManager.salvaDocumentoJSON(documento)
            
        case .csv:
            let csvContent = generaCSV(documento)
            let fileName = "\(documento.nomeFileConsigliato).csv"
            let csvURL = fileManager.exportFolderURL.appendingPathComponent(fileName)
            try csvContent.write(to: csvURL, atomically: true, encoding: .utf8)
            return csvURL
        }
    }
    
    // MARK: - ⭐ CARICAMENTO DA FILE SYSTEM (ESISTENTE)
    
    private func caricaDocumentiSalvati() {
        documentiCompilati = fileManager.caricaDocumentiSalvati()
        print("📁 Caricati \(documentiCompilati.count) documenti")
    }
    
    func ricaricaDocumenti() {
        caricaDocumentiSalvati()
    }
    
    // MARK: - ⭐ EXPORT FUNCTIONS (ESISTENTE + POTENZIATO)
    
    func esportaPDF(_ documento: DocumentoCompilato) -> URL? {
        do {
            return try fileManager.esportaPDF(documento)
        } catch {
            print("❌ Errore esportazione PDF: \(error)")
            return nil
        }
    }
    
    func esportaWord(_ documento: DocumentoCompilato) -> URL? {
        do {
            return try fileManager.esportaWord(documento)
        } catch {
            print("❌ Errore esportazione Word: \(error)")
            return nil
        }
    }
    
    func esportaPages(_ documento: DocumentoCompilato) -> URL? {
        do {
            return try fileManager.esportaPages(documento)
        } catch {
            print("❌ Errore esportazione Pages: \(error)")
            return nil
        }
    }
    
    func esportaTestoSemplice(_ documento: DocumentoCompilato) -> URL? {
        do {
            return try fileManager.salvaDocumentoCompilato(documento)
        } catch {
            print("❌ Errore esportazione testo: \(error)")
            return nil
        }
    }
    
    // 🔥 NUOVO: Export multiplo con Adobe
    func esportaTuttiFormatiConAdobe(_ documento: DocumentoCompilato) async throws -> [URL] {
        var urls: [URL] = []
        
        // Export in parallelo per performance migliori
        async let txtURL = salvaDocumentoConAdobe(documento, formato: .testoSemplice)
        async let pdfURL = salvaDocumentoConAdobe(documento, formato: .pdf)
        async let jsonURL = salvaDocumentoConAdobe(documento, formato: .json)
        async let csvURL = salvaDocumentoConAdobe(documento, formato: .csv)
        
        urls.append(try await txtURL)
        urls.append(try await pdfURL)
        urls.append(try await jsonURL)
        urls.append(try await csvURL)
        
        return urls
    }
    
    func esportaTuttiFormati(_ documento: DocumentoCompilato) -> [URL] {
        var urls: [URL] = []
        
        if let pdfURL = esportaPDF(documento) { urls.append(pdfURL) }
        if let wordURL = esportaWord(documento) { urls.append(wordURL) }
        if let pagesURL = esportaPages(documento) { urls.append(pagesURL) }
        if let txtURL = esportaTestoSemplice(documento) { urls.append(txtURL) }
        
        return urls
    }
    
    // MARK: - ⭐ FILE MANAGEMENT (ESISTENTE)
    
    func apriCartellaDocumenti() {
        fileManager.apriCartellaDocumenti()
    }
    
    func apriCartellaExport() {
        fileManager.apriCartellaExport()
    }
    
    func ottieniPathDocumenti() -> String {
        return fileManager.documentiCompilatiFolderURL.path
    }
    
    // MARK: - ⭐ BACKUP AND MAINTENANCE (ESISTENTE + POTENZIATO)
    
    func creaBackup() throws -> URL {
        let backupData = try JSONEncoder().encode(documentiCompilati)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dataStr = dateFormatter.string(from: Date())
        
        let nomeFile = "backup_completo_\(dataStr).json"
        let backupURL = fileManager.backupFolderURL.appendingPathComponent(nomeFile)
        
        try backupData.write(to: backupURL)
        
        print("💾 Backup completo creato: \(backupURL.lastPathComponent)")
        return backupURL
    }
    
    // 🔥 NUOVO: Backup con compressione e metadata
    func creaBackupCompleto() async throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dataStr = dateFormatter.string(from: Date())
        
        // Usa il metodo del FileManager esistente
        let backupURL = try fileManager.creaBackupCompleto(documentiCompilati, templates: templates)
        
        print("💾 Backup completo Adobe creato: \(backupURL.lastPathComponent)")
        return backupURL
    }
    
    func eliminaFileVecchi() {
        do {
            try fileManager.eliminaFileVecchi(giorniDiMantenimento: 30)
        } catch {
            print("❌ Errore eliminazione file vecchi: \(error)")
        }
    }
    
    // MARK: - ⭐ STATISTICS (ESISTENTE)
    
    func statisticheDocumenti() -> (documentiOggi: Int, documentiSettimana: Int, documentiMese: Int, totaleSalvati: Int) {
        let oggi = Calendar.current.startOfDay(for: Date())
        let settimanaFa = Calendar.current.date(byAdding: .day, value: -7, to: oggi)!
        let meseFa = Calendar.current.date(byAdding: .month, value: -1, to: oggi)!
        
        let documentiOggi = documentiCompilati.filter {
            Calendar.current.isDate($0.dataCreazione, inSameDayAs: Date())
        }.count
        
        let documentiSettimana = documentiCompilati.filter {
            $0.dataCreazione >= settimanaFa
        }.count
        
        let documentiMese = documentiCompilati.filter {
            $0.dataCreazione >= meseFa
        }.count
        
        return (documentiOggi, documentiSettimana, documentiMese, documentiCompilati.count)
    }
    
    func getStatisticheFiles() -> (totali: Int, dimensione: String) {
        return fileManager.getStatisticheFiles()
    }
    
    // 🔥 NUOVO: Statistiche Adobe
    @MainActor
    func getStatisticheAdobe() -> (elaborazioniOggi: Int, templatesImportati: Int, analisiEffettuate: Int) {
        let templatesImportati = templates.filter {
            $0.operatoreCreazione.contains("Adobe")
        }.count
        
        return (
            elaborazioniOggi: adobeManager.todayOperations,
            templatesImportati: templatesImportati,
            analisiEffettuate: adobeManager.totalOperations
        )
    }
    
    // MARK: - ⭐ SEARCH AND FILTER (ESISTENTE - CORRETTO)
    
    func cercaDocumenti(query: String) -> [DocumentoCompilato] {
        if query.isEmpty {
            return documentiCompilati
        }
        
        return documentiCompilati.filter { documento in
            // ✅ CORRETTO: Accesso diretto alle proprietà
            documento.defunto.nomeCompleto.localizedCaseInsensitiveContains(query) ||
            documento.template.nome.localizedCaseInsensitiveContains(query) ||
            documento.defunto.numeroCartella.contains(query) ||
            documento.contenutoFinale.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filtraPerTipo(_ tipo: TipoDocumento) -> [DocumentoCompilato] {
        return documentiCompilati.filter { $0.template.tipo == tipo }
    }
    
    func filtraPerStato(completati: Bool) -> [DocumentoCompilato] {
        return documentiCompilati.filter { $0.isCompletato == completati }
    }
    
    // 🔥 NUOVO: Ricerca avanzata con Adobe AI
    func cercaConAI(query: String) async throws -> [DocumentoCompilato] {
        var risultati: [DocumentoCompilato] = []
        
        for documento in documentiCompilati {
            let adobeAnalysis = try await adobeManager.analyzeDocument(content: documento.contenutoFinale)
            let detectedType = self.convertAdobeToLocal(adobeAnalysis.detectedType)
            
            // Logica di ricerca semantica semplificata
            if documento.contenutoFinale.localizedCaseInsensitiveContains(query) ||
               detectedType.rawValue.localizedCaseInsensitiveContains(query) {
                risultati.append(documento)
            }
        }
        
        return risultati
    }
    
    // MARK: - ⭐ DOCUMENT OPERATIONS (ESISTENTE)
    
    func duplicaDocumento(_ documento: DocumentoCompilato) -> DocumentoCompilato {
        var nuovoDocumento = documento
        nuovoDocumento = DocumentoCompilato(template: documento.template, defunto: documento.defunto)
        nuovoDocumento.contenutoFinale = documento.contenutoFinale
        nuovoDocumento.note = documento.note + "\n[Duplicato da documento del \(documento.dataCreazioneFormattata)]"
        
        return nuovoDocumento
    }
    
    func eliminaDocumento(_ documento: DocumentoCompilato) {
        documentiCompilati.removeAll { $0.id == documento.id }
        
        // 🔥 AGGIUNTO: Elimina anche i file fisici
        do {
            let fileName = "\(documento.nomeFileConsigliato).txt"
            let fileURL = fileManager.documentiCompilatiFolderURL.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ File eliminato: \(fileName)")
            }
        } catch {
            print("❌ Errore eliminazione file: \(error)")
        }
    }
    
    // MARK: - ⭐ TEMPLATE OPERATIONS (ESISTENTE + POTENZIATO)
    
    func aggiungiTemplate(_ template: DocumentoTemplate) {
        templates.append(template)
        
        // 🔥 AGGIUNTO: Salva automaticamente se personalizzato
        if !template.isDefault {
            do {
                let _ = try fileManager.salvaTemplate(template)
            } catch {
                print("❌ Errore salvataggio template: \(error)")
            }
        }
    }
    
    func rimuoviTemplate(_ template: DocumentoTemplate) {
        templates.removeAll { $0.id == template.id }
        
        // 🔥 AGGIUNTO: Elimina file template se esiste
        if !template.isDefault {
            do {
                try fileManager.eliminaTemplate(template)
            } catch {
                print("❌ Errore eliminazione template file: \(error)")
            }
        }
    }
    
    // MARK: - ⭐ IMPORT/EXPORT TEMPLATE (ESISTENTE)
    
    func importaTemplate(da url: URL) throws {
        let data = try Data(contentsOf: url)
        let template = try JSONDecoder().decode(DocumentoTemplate.self, from: data)
        
        if !templates.contains(where: { $0.nome == template.nome }) {
            templates.append(template)
            print("📥 Template importato: \(template.nome)")
        } else {
            print("⚠️ Template già esistente: \(template.nome)")
        }
    }
    
    func esportaTemplate(_ template: DocumentoTemplate) throws -> URL {
        return try fileManager.salvaTemplate(template)
    }
    
    func salvaTemplatePersonalizzati() throws {
        for template in templates {
            if !template.isDefault {
                let _ = try fileManager.salvaTemplate(template)
            }
        }
    }
    
    func caricaTemplatePersonalizzati() {
        let templatesCaricati = fileManager.caricaTemplates()
        
        for template in templatesCaricati {
            if !templates.contains(where: { $0.nome == template.nome }) {
                templates.append(template)
            }
        }
    }
    
    // MARK: - 🔥 FUNZIONI HELPER CORRETTE
    
    // ✅ Helper per qualità
    private func qualityFromDouble(_ quality: Double) -> String {
        if quality > 0.8 { return "Eccellente" }
        else if quality > 0.6 { return "Buona" }
        else if quality > 0.4 { return "Discreta" }
        else { return "Scarsa" }
    }
    
    private func estraiCampiDaContenuto(_ contenuto: String) -> [CampoDocumento] {
        var campi: [CampoDocumento] = []
        let pattern = "\\{\\{([A-Z_]+)\\}\\}"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: contenuto, range: NSRange(contenuto.startIndex..., in: contenuto))
            
            var foundFields = Set<String>()
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: contenuto) {
                    let fieldName = String(contenuto[range])
                    
                    if !foundFields.contains(fieldName) {
                        foundFields.insert(fieldName)
                        
                        let campo = CampoDocumento(
                            nome: fieldName.replacingOccurrences(of: "_", with: " ").capitalized,
                            chiave: fieldName,
                            tipo: inferTipoCampo(from: fieldName),
                            obbligatorio: isCampoObbligatorio(fieldName)
                        )
                        
                        campi.append(campo)
                    }
                }
            }
        } catch {
            print("Errore estrazione campi: \(error)")
        }
        
        return campi.sorted { $0.nome < $1.nome }
    }
    
    private func inferTipoCampo(from fieldName: String) -> TipoCampoDocumento {
        let name = fieldName.lowercased()
        
        if name.contains("data") || name.contains("date") {
            return .data
        } else if name.contains("ora") || name.contains("time") {
            return .ora
        } else if name.contains("email") {
            return .email
        } else if name.contains("telefono") || name.contains("phone") {
            return .telefono
        } else if name.contains("note") || name.contains("descrizione") {
            return .testoLungo
        } else {
            return .testo
        }
    }
    
    private func isCampoObbligatorio(_ fieldName: String) -> Bool {
        let campiObbligatori = [
            "NOME_DEFUNTO", "COGNOME_DEFUNTO", "DATA_DECESSO",
            "LUOGO_DECESSO", "NOME_RICHIEDENTE", "DATA_NASCITA"
        ]
        return campiObbligatori.contains(fieldName)
    }
    
    private func generaCSV(_ documento: DocumentoCompilato) -> String {
        let header = "Template,Defunto,Cartella,Data Creazione,Data Completamento,Stato,Operatore"
        let dataCompletamento = documento.dataCompletamentoFormattata ?? "N/A"
        let stato = documento.isCompletato ? "Completato" : "In Elaborazione"
        
        let row = "\(documento.template.nome),\(documento.defunto.nomeCompleto),\(documento.defunto.numeroCartella),\(documento.dataCreazioneFormattata),\(dataCompletamento),\(stato),\(documento.operatoreCreazione)"
        
        return "\(header)\n\(row)"
    }
    
    // MARK: - 🔥 FUNZIONI DI CONVERSIONE PRIVATE
    
    private func convertAdobeToLocal(_ adobeType: AdobeTipoDocumento) -> TipoDocumento {
        switch adobeType {
        case .autorizzazioneTrasporto:
            return .autorizzazioneTrasporto
        case .comunicazioneParrocchia:
            return .comunicazioneParrocchia
        case .fattura:
            return .fattura
        case .contratto:
            return .contratto
        case .certificatoMorte:
            return .certificatoMorte
        case .visitaNecroscopica:
            return .certificatoMorte // Mappato a certificato morte
        case .altro:
            return .altro
        }
    }
}

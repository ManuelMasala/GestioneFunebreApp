//
//  DocumentiManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import Foundation
import SwiftUI

class DocumentiManager: ObservableObject {
    @Published var templates: [DocumentoTemplate] = []
    @Published var documentiCompilati: [DocumentoCompilato] = []
    
    private let documentsDirectory: URL
    private let templatesDirectory: URL
    private let documentiDirectory: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsDirectory = documentsPath.appendingPathComponent("FunerApp")
        templatesDirectory = documentsDirectory.appendingPathComponent("Templates")
        documentiDirectory = documentsDirectory.appendingPathComponent("Documenti")
        
        creaDirectorySeNecessario()
        caricaTemplateDefault()
        caricaDatiSalvati()
    }
    
    // MARK: - Setup Directories
    private func creaDirectorySeNecessario() {
        let fileManager = FileManager.default
        
        for directory in [documentsDirectory, templatesDirectory, documentiDirectory] {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                print("📁 Directory creata: \(directory.lastPathComponent)")
            } catch {
                print("❌ Errore creazione directory \(directory.lastPathComponent): \(error)")
            }
        }
    }
    
    // MARK: - Caricamento Template Default
    private func caricaTemplateDefault() {
        let templateDefault = [
            DocumentoTemplate.autorizzazioneTrasporto,
            DocumentoTemplate.comunicazioneParrocchia,
            DocumentoTemplate.checklistFunerale
        ]
        
        for template in templateDefault {
            if !templates.contains(where: { $0.nome == template.nome }) {
                templates.append(template)
            }
        }
    }
    
    // MARK: - Gestione Template
    func aggiungiTemplate(_ template: DocumentoTemplate) {
        templates.append(template)
        salvaTemplate(template)
        print("📄 Template aggiunto: \(template.nome)")
    }
    
    func rimuoviTemplate(_ template: DocumentoTemplate) {
        templates.removeAll { $0.id == template.id }
        eliminaTemplateFile(template)
        print("🗑️ Template rimosso: \(template.nome)")
    }
    
    func aggiornaTemplate(_ template: DocumentoTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            var templateAggiornato = template
            templateAggiornato.dataUltimaModifica = Date()
            templates[index] = templateAggiornato
            salvaTemplate(templateAggiornato)
            print("✏️ Template aggiornato: \(template.nome)")
        }
    }
    
    func duplicaTemplate(_ template: DocumentoTemplate) -> DocumentoTemplate {
        var nuovoTemplate = template
        // Crea nuovo ID invece di assegnare
        let nuovoID = UUID()
        nuovoTemplate = DocumentoTemplate(
            nome: template.nome + " (Copia)",
            tipo: template.tipo,
            contenuto: template.contenuto,
            campiCompilabili: template.campiCompilabili,
            isDefault: false,
            note: template.note,
            operatoreCreazione: template.operatoreCreazione,
            versione: template.versione
        )
        
        aggiungiTemplate(nuovoTemplate)
        return nuovoTemplate
    }
    
    // MARK: - Gestione Documenti Compilati
    func creaDocumentoCompilato(template: DocumentoTemplate, defunto: PersonaDefunta) -> DocumentoCompilato {
        var documento = DocumentoCompilato(template: template, defunto: defunto)
        documento.compilaConDefunto()
        return documento
    }
    
    func salvaDocumentoCompilato(_ documento: DocumentoCompilato) {
        if let index = documentiCompilati.firstIndex(where: { $0.id == documento.id }) {
            documentiCompilati[index] = documento
            print("✏️ Documento aggiornato: \(documento.template.nome)")
        } else {
            documentiCompilati.append(documento)
            print("💾 Documento salvato: \(documento.template.nome)")
        }
        salvaDocumento(documento)
    }
    
    func rimuoviDocumentoCompilato(_ documento: DocumentoCompilato) {
        documentiCompilati.removeAll { $0.id == documento.id }
        eliminaDocumentoFile(documento)
        print("🗑️ Documento rimosso: \(documento.template.nome)")
    }
    
    // MARK: - Import/Export Template
    func importaTemplate(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let templateImportato = try decoder.decode(DocumentoTemplate.self, from: data)
        
        // Crea nuovo template invece di modificare l'ID
        var nuovoTemplate = DocumentoTemplate(
            nome: templateImportato.nome,
            tipo: templateImportato.tipo,
            contenuto: templateImportato.contenuto,
            campiCompilabili: templateImportato.campiCompilabili,
            isDefault: false,
            note: templateImportato.note,
            operatoreCreazione: templateImportato.operatoreCreazione,
            versione: templateImportato.versione
        )
        
        // Verifica nomi duplicati
        if templates.contains(where: { $0.nome == nuovoTemplate.nome }) {
            nuovoTemplate = DocumentoTemplate(
                nome: templateImportato.nome + " (Importato)",
                tipo: templateImportato.tipo,
                contenuto: templateImportato.contenuto,
                campiCompilabili: templateImportato.campiCompilabili,
                isDefault: false,
                note: templateImportato.note,
                operatoreCreazione: templateImportato.operatoreCreazione,
                versione: templateImportato.versione
            )
        }
        
        aggiungiTemplate(nuovoTemplate)
        print("📥 Template importato: \(nuovoTemplate.nome)")
    }
    
    func esportaTemplate(_ template: DocumentoTemplate) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(template)
    }
    
    func esportaTemplate(_ template: DocumentoTemplate, to url: URL) throws {
        let data = try esportaTemplate(template)
        try data.write(to: url)
        print("📤 Template esportato: \(template.nome)")
    }
    
    // MARK: - Salvataggio/Caricamento File
    private func salvaTemplate(_ template: DocumentoTemplate) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(template)
            let fileName = "\(template.id.uuidString).json"
            let fileURL = templatesDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
        } catch {
            print("❌ Errore salvataggio template: \(error)")
        }
    }
    
    private func salvaDocumento(_ documento: DocumentoCompilato) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(documento)
            let fileName = "\(documento.id.uuidString).json"
            let fileURL = documentiDirectory.appendingPathComponent(fileName)
            
            try data.write(to: fileURL)
        } catch {
            print("❌ Errore salvataggio documento: \(error)")
        }
    }
    
    private func eliminaTemplateFile(_ template: DocumentoTemplate) {
        let fileName = "\(template.id.uuidString).json"
        let fileURL = templatesDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("❌ Errore eliminazione template file: \(error)")
        }
    }
    
    private func eliminaDocumentoFile(_ documento: DocumentoCompilato) {
        let fileName = "\(documento.id.uuidString).json"
        let fileURL = documentiDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("❌ Errore eliminazione documento file: \(error)")
        }
    }
    
    private func caricaDatiSalvati() {
        caricaTemplatesSalvati()
        caricaDocumentiSalvati()
    }
    
    private func caricaTemplatesSalvati() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: templatesDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let template = try decoder.decode(DocumentoTemplate.self, from: data)
                    
                    if !templates.contains(where: { $0.id == template.id }) {
                        templates.append(template)
                    }
                } catch {
                    print("❌ Errore caricamento template \(fileURL.lastPathComponent): \(error)")
                }
            }
            
            print("📄 Caricati \(jsonFiles.count) template personalizzati")
        } catch {
            print("❌ Errore lettura directory templates: \(error)")
        }
    }
    
    private func caricaDocumentiSalvati() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentiDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = fileURLs.filter { $0.pathExtension == "json" }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for fileURL in jsonFiles {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let documento = try decoder.decode(DocumentoCompilato.self, from: data)
                    documentiCompilati.append(documento)
                } catch {
                    print("❌ Errore caricamento documento \(fileURL.lastPathComponent): \(error)")
                }
            }
            
            documentiCompilati.sort { $0.dataCreazione > $1.dataCreazione }
            
            print("📄 Caricati \(jsonFiles.count) documenti salvati")
        } catch {
            print("❌ Errore lettura directory documenti: \(error)")
        }
    }
    
    // MARK: - Ricerca e Filtri
    func cercaTemplates(query: String) -> [DocumentoTemplate] {
        if query.isEmpty {
            return templates
        }
        
        return templates.filter { template in
            template.nome.localizedCaseInsensitiveContains(query) ||
            template.tipo.rawValue.localizedCaseInsensitiveContains(query) ||
            template.note.localizedCaseInsensitiveContains(query)
        }
    }
    
    func cercaDocumenti(query: String) -> [DocumentoCompilato] {
        if query.isEmpty {
            return documentiCompilati
        }
        
        return documentiCompilati.filter { documento in
            documento.template.nome.localizedCaseInsensitiveContains(query) ||
            documento.defunto.nomeCompleto.localizedCaseInsensitiveContains(query) ||
            documento.defunto.numeroCartella.localizedCaseInsensitiveContains(query)
        }
    }
    
    func templatesPerTipo(_ tipo: TipoDocumento) -> [DocumentoTemplate] {
        return templates.filter { $0.tipo == tipo }
    }
    
    func documentiPerTemplate(_ template: DocumentoTemplate) -> [DocumentoCompilato] {
        return documentiCompilati.filter { $0.template.id == template.id }
    }
    
    func templatesPersonalizzati() -> [DocumentoTemplate] {
        return templates.filter { !$0.isDefault }
    }
    
    func templatesDefault() -> [DocumentoTemplate] {
        return templates.filter { $0.isDefault }
    }
    
    // MARK: - Statistiche
    func statisticheDocumenti() -> StatisticheDocumenti {
        let oggi = Calendar.current.startOfDay(for: Date())
        let settimanaFa = Calendar.current.date(byAdding: .day, value: -7, to: oggi)!
        let meseFa = Calendar.current.date(byAdding: .month, value: -1, to: oggi)!
        
        let documentiOggi = documentiCompilati.filter {
            Calendar.current.isDate($0.dataCreazione, inSameDayAs: oggi)
        }
        
        let documentiSettimana = documentiCompilati.filter {
            $0.dataCreazione >= settimanaFa
        }
        
        let documentiMese = documentiCompilati.filter {
            $0.dataCreazione >= meseFa
        }
        
        return StatisticheDocumenti(
            totaleDocumenti: documentiCompilati.count,
            totaleTemplate: templates.count,
            templatePersonalizzati: templatesPersonalizzati().count,
            documentiOggi: documentiOggi.count,
            documentiSettimana: documentiSettimana.count,
            documentiMese: documentiMese.count,
            templatePiuUsati: templatePiuUtilizzati()
        )
    }
    
    private func templatePiuUtilizzati() -> [DocumentoTemplate] {
        let conteggi = Dictionary(grouping: documentiCompilati, by: { $0.template.id })
            .mapValues { $0.count }
        
        return templates
            .sorted { template1, template2 in
                let count1 = conteggi[template1.id] ?? 0
                let count2 = conteggi[template2.id] ?? 0
                return count1 > count2
            }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Backup e Restore
    func creaBackup() throws -> URL {
        let backupData = BackupData(
            dataCreazione: Date(),
            versione: "1.4.0",
            templates: templates,
            documentiCompilati: documentiCompilati
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(backupData)
        
        let fileName = "FunerApp_Backup_\(DateFormatter.backupDateFormatter.string(from: Date())).json"
        let backupURL = documentsDirectory.appendingPathComponent(fileName)
        
        try data.write(to: backupURL)
        print("💾 Backup creato: \(backupURL.lastPathComponent)")
        return backupURL
    }
    
    func ripristinaBackup(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backupData = try decoder.decode(BackupData.self, from: data)
        
        let backupAttuale = try creaBackup()
        print("🔄 Backup attuale salvato in: \(backupAttuale.lastPathComponent)")
        
        templates = backupData.templates
        documentiCompilati = backupData.documentiCompilati
        
        for template in templates.filter({ !$0.isDefault }) {
            salvaTemplate(template)
        }
        
        for documento in documentiCompilati {
            salvaDocumento(documento)
        }
        
        print("🔄 Backup ripristinato da: \(url.lastPathComponent)")
    }
    
    // MARK: - Utilità
    func validaTemplate(_ template: DocumentoTemplate) -> [String] {
        var errori: [String] = []
        
        if template.nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il nome del template è obbligatorio")
        }
        
        if template.contenuto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il contenuto del template è obbligatorio")
        }
        
        if templates.contains(where: { $0.nome == template.nome && $0.id != template.id }) {
            errori.append("Esiste già un template con questo nome")
        }
        
        return errori
    }
    
    func ottieniPathDocumenti() -> String {
        return documentsDirectory.path
    }
    
    func pulisciCache() {
        let cutoffDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        
        let documentiVecchi = documentiCompilati.filter { $0.dataCreazione < cutoffDate }
        
        for documento in documentiVecchi {
            rimuoviDocumentoCompilato(documento)
        }
        
        print("🧹 Puliti \(documentiVecchi.count) documenti obsoleti")
    }
}

// MARK: - Strutture di Supporto
struct StatisticheDocumenti {
    let totaleDocumenti: Int
    let totaleTemplate: Int
    let templatePersonalizzati: Int
    let documentiOggi: Int
    let documentiSettimana: Int
    let documentiMese: Int
    let templatePiuUsati: [DocumentoTemplate]
}

struct BackupData: Codable {
    let dataCreazione: Date
    let versione: String
    let templates: [DocumentoTemplate]
    let documentiCompilati: [DocumentoCompilato]
}

// MARK: - Estensioni DateFormatter
extension DateFormatter {
    static let backupDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

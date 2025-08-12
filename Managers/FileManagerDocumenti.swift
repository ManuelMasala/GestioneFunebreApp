//
//  FileManagerDocumenti.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 21/07/25.
//

import Foundation
import SwiftUI

// MARK: - ⭐ FILE MANAGER DOCUMENTI COMPLETO E CORRETTO

class FileManagerDocumenti: ObservableObject {
    
    // MARK: - Proprietà
    let fileManager = FileManager.default
    
    // Percorsi base
    var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var appBaseURL: URL {
        documentsURL.appendingPathComponent("GestioneFunebre")
    }
    
    // Cartelle specifiche
    var documentiCompilatiFolderURL: URL {
        appBaseURL.appendingPathComponent("Documenti")
    }
    
    var templatesFolderURL: URL {
        appBaseURL.appendingPathComponent("Templates")
    }
    
    var backupFolderURL: URL {
        appBaseURL.appendingPathComponent("Backup")
    }
    
    var exportFolderURL: URL {
        appBaseURL.appendingPathComponent("Export")
    }
    
    // MARK: - Inizializzazione
    init() {
        createDirectoryStructure()
    }
    
    // MARK: - Creazione struttura cartelle
    private func createDirectoryStructure() {
        let folders = [
            appBaseURL,
            documentiCompilatiFolderURL,
            templatesFolderURL,
            backupFolderURL,
            exportFolderURL,
            // Sottocartelle per tipo documento
            documentiCompilatiFolderURL.appendingPathComponent("Autorizzazioni"),
            documentiCompilatiFolderURL.appendingPathComponent("Comunicazioni"),
            documentiCompilatiFolderURL.appendingPathComponent("Certificati"),
            documentiCompilatiFolderURL.appendingPathComponent("Fatture"),
            documentiCompilatiFolderURL.appendingPathComponent("Altro")
        ]
        
        for folder in folders {
            do {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
                print("📁 Creata cartella: \(folder.lastPathComponent)")
            } catch {
                print("❌ Errore creazione cartella \(folder): \(error)")
            }
        }
    }
    
    // MARK: - Salvataggio Documenti
    func salvaDocumentoCompilato(_ documento: DocumentoCompilato) throws -> URL {
        // Determina la sottocartella in base al tipo
        let sottocartella = getSottocartellaPerTipo(documento.template.tipo)
        let folderURL = documentiCompilatiFolderURL.appendingPathComponent(sottocartella)
        
        // Nome file: data_template_defunto.txt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dataStr = dateFormatter.string(from: documento.dataCreazione)
        
        let nomeDefunto = documento.defunto.cognome.replacingOccurrences(of: " ", with: "_")
        let nomeTemplate = documento.template.nome.replacingOccurrences(of: " ", with: "_")
        
        let nomeFile = "\(dataStr)_\(nomeTemplate)_\(nomeDefunto).txt"
        let fileURL = folderURL.appendingPathComponent(nomeFile)
        
        // Crea il contenuto da salvare
        let contenuto = creaContenutoFile(documento)
        
        // Salva il file
        try contenuto.write(to: fileURL, atomically: true, encoding: .utf8)
        
        print("💾 Documento salvato: \(fileURL.path)")
        return fileURL
    }
    
    // MARK: - Salvataggio JSON (per backup completo)
    func salvaDocumentoJSON(_ documento: DocumentoCompilato) throws -> URL {
        let jsonData = try JSONEncoder().encode(documento)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dataStr = dateFormatter.string(from: documento.dataCreazione)
        
        let nomeFile = "\(dataStr)_\(documento.defunto.cognome)_backup.json"
        let fileURL = backupFolderURL.appendingPathComponent(nomeFile)
        
        try jsonData.write(to: fileURL)
        
        print("💾 Backup JSON salvato: \(fileURL.path)")
        return fileURL
    }
    
    // MARK: - Esportazione PDF
    func esportaPDF(_ documento: DocumentoCompilato) throws -> URL {
        let pdfData = try documento.creaPDF()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dataStr = dateFormatter.string(from: documento.dataCreazione)
        
        let nomeFile = "\(dataStr)_\(documento.template.nome)_\(documento.defunto.cognome).pdf"
        let fileURL = exportFolderURL.appendingPathComponent(nomeFile)
        
        try pdfData.write(to: fileURL)
        
        print("📄 PDF esportato: \(fileURL.path)")
        return fileURL
    }
    
    // MARK: - Esportazione Word (.docx)
    func esportaWord(_ documento: DocumentoCompilato) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dataStr = dateFormatter.string(from: documento.dataCreazione)
        
        let nomeFile = "\(dataStr)_\(documento.template.nome)_\(documento.defunto.cognome).docx"
        let fileURL = exportFolderURL.appendingPathComponent(nomeFile)
        
        // Crea il contenuto Word formattato
        let wordContent = creaContenutoWord(documento)
        
        // Per ora salviamo come RTF che è compatibile con Word
        let rtfFile = fileURL.appendingPathExtension("rtf")
        try wordContent.write(to: rtfFile, atomically: true, encoding: .utf8)
        
        print("📝 Word/RTF esportato: \(rtfFile.path)")
        return rtfFile
    }
    
    // MARK: - Esportazione Pages
    func esportaPages(_ documento: DocumentoCompilato) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dataStr = dateFormatter.string(from: documento.dataCreazione)
        
        let nomeFile = "\(dataStr)_\(documento.template.nome)_\(documento.defunto.cognome).rtf"
        let fileURL = exportFolderURL.appendingPathComponent(nomeFile)
        
        // RTF è compatibile con Pages
        let rtfContent = creaContenutoRTF(documento)
        try rtfContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        print("📖 Pages/RTF esportato: \(fileURL.path)")
        return fileURL
    }
    
    private func creaContenutoWord(_ documento: DocumentoCompilato) -> String {
        return """
        {\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}
        \\f0\\fs24
        
        {\\b\\fs28 \(documento.template.nome.replacingOccurrences(of: " ", with: "\\ "))}\\par
        \\par
        {\\b Defunto:} \(documento.defunto.nomeCompleto.replacingOccurrences(of: " ", with: "\\ "))\\par
        {\\b Cartella N°:} \(documento.defunto.numeroCartella)\\par
        {\\b Data:} \(documento.dataCreazioneFormattata.replacingOccurrences(of: " ", with: "\\ "))\\par
        \\par
        \\line
        \\par
        \(documento.contenutoFinale.replacingOccurrences(of: "\n", with: "\\par ").replacingOccurrences(of: " ", with: "\\ "))
        \\par
        \\par
        \\line
        \\par
        {\\i Documento generato il \(Date().formatted(date: .complete, time: .shortened))}
        }
        """
    }
    
    private func creaContenutoRTF(_ documento: DocumentoCompilato) -> String {
        return """
        {\\rtf1\\ansi\\deff0
        {\\fonttbl
        {\\f0\\froman\\fcharset0 Times New Roman;}
        {\\f1\\fswiss\\fcharset0 Arial;}
        }
        
        {\\header \\pard\\qc {\\f1\\fs20 \(documento.template.tipo.rawValue)} \\par}
        
        \\pard\\qc {\\f0\\fs32\\b \(documento.template.nome)} \\par\\par
        
        \\pard\\ql
        {\\f0\\fs24\\b Informazioni Documento:}\\par
        \\tab Defunto: {\\b \(documento.defunto.nomeCompleto)}\\par
        \\tab Cartella: \(documento.defunto.numeroCartella)\\par
        \\tab Data Creazione: \(documento.dataCreazioneFormattata)\\par
        \\tab Operatore: \(documento.operatoreCreazione)\\par\\par
        
        \\line\\par
        
        {\\f0\\fs24\\b Contenuto:}\\par
        {\\f0\\fs22 \(documento.contenutoFinale.replacingOccurrences(of: "\n", with: "\\par "))}\\par\\par
        
        \\line\\par
        
        {\\f0\\fs20\\i Generato automaticamente dal Sistema Gestione Funebre}\\par
        {\\f0\\fs18\\i Data: \(Date().formatted(date: .complete, time: .shortened))}
        }
        """
    }
    
    // MARK: - Caricamento Documenti
    func caricaDocumentiSalvati() -> [DocumentoCompilato] {
        var documenti: [DocumentoCompilato] = []
        
        do {
            let jsonFiles = try fileManager.contentsOfDirectory(at: backupFolderURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" }
            
            for file in jsonFiles {
                do {
                    let data = try Data(contentsOf: file)
                    let documento = try JSONDecoder().decode(DocumentoCompilato.self, from: data)
                    documenti.append(documento)
                } catch {
                    print("❌ Errore caricamento \(file.lastPathComponent): \(error)")
                }
            }
        } catch {
            print("❌ Errore lettura cartella backup: \(error)")
        }
        
        return documenti.sorted { $0.dataCreazione > $1.dataCreazione }
    }
    
    // MARK: - Utilities
    private func getSottocartellaPerTipo(_ tipo: TipoDocumento) -> String {
        switch tipo {
        case .autorizzazioneTrasporto, .autorizzazioneSepoltura:
            return "Autorizzazioni"
        case .comunicazioneParrocchia, .comunicazioneCimitero:
            return "Comunicazioni"
        case .certificatoMorte, .dichiarazioneFamiliare:
            return "Certificati"
        case .fattura, .ricevuta, .contratto:
            return "Fatture"
        default:
            return "Altro"
        }
    }
    
    private func creaContenutoFile(_ documento: DocumentoCompilato) -> String {
        let separatore = String(repeating: "=", count: 50)
        
        return """
        \(separatore)
        DOCUMENTO FUNEBRE
        \(separatore)
        
        Template: \(documento.template.nome)
        Tipo: \(documento.template.tipo.rawValue)
        Defunto: \(PersonaDefuntaHelperAdobe.nomeCompleto(for: documento.defunto))
        Cartella N°: \(documento.defunto.numeroCartella)
        
        Data Creazione: \(documento.dataCreazioneFormattata)
        Data Modifica: \(documento.dataModificaFormattata)
        Operatore: \(documento.operatoreCreazione)
        Stato: \(documento.isCompletato ? "Completato" : "In lavorazione")
        
        \(separatore)
        CONTENUTO DOCUMENTO
        \(separatore)
        
        \(documento.contenutoFinale)
        
        \(separatore)
        DATI DEFUNTO
        \(separatore)
        
        Nome Completo: \(PersonaDefuntaHelperAdobe.nomeCompleto(for: documento.defunto))
        Data Nascita: \(PersonaDefuntaHelperAdobe.dataNascitaFormattata(for: documento.defunto))
        Luogo Nascita: \(documento.defunto.luogoNascita)
        Data Decesso: \(PersonaDefuntaHelperAdobe.dataDecesoFormattata(for: documento.defunto))
        Ora Decesso: \(documento.defunto.oraDecesso)
        
        \(separatore)
        FAMILIARE RESPONSABILE
        \(separatore)
        
        Nome: \(documento.defunto.familiareRichiedente.nomeCompleto)
        Parentela: \(documento.defunto.familiareRichiedente.parentela.rawValue)
        Telefono: \(documento.defunto.familiareRichiedente.telefono)
        Email: \(documento.defunto.familiareRichiedente.email ?? "Non specificata")
        Indirizzo: \(FamiliareResponsabileHelperAdobe.indirizzoCompleto(for: documento.defunto.familiareRichiedente))
        
        \(documento.note.isEmpty ? "" : "\n\(separatore)\nNOTE\n\(separatore)\n\n\(documento.note)")
        
        \(separatore)
        Fine Documento
        \(separatore)
        """
    }
    
    // MARK: - Gestione Cartelle
    func apriCartellaDocumenti() {
        NSWorkspace.shared.open(documentiCompilatiFolderURL)
    }
    
    func apriCartellaExport() {
        NSWorkspace.shared.open(exportFolderURL)
    }
    
    func apriCartellaBackup() {
        NSWorkspace.shared.open(backupFolderURL)
    }
    
    // MARK: - Pulizia e Manutenzione
    func eliminaFileVecchi(giorniDiMantenimento: Int = 30) throws {
        let dataLimite = Calendar.current.date(byAdding: .day, value: -giorniDiMantenimento, to: Date())!
        
        let cartelle = [documentiCompilatiFolderURL, backupFolderURL, exportFolderURL]
        
        for cartella in cartelle {
            let files = try fileManager.contentsOfDirectory(at: cartella, includingPropertiesForKeys: [.creationDateKey])
            
            for file in files {
                let attributes = try file.resourceValues(forKeys: [.creationDateKey])
                if let dataCreazione = attributes.creationDate, dataCreazione < dataLimite {
                    try fileManager.removeItem(at: file)
                    print("🗑️ Eliminato file vecchio: \(file.lastPathComponent)")
                }
            }
        }
    }
    
    // MARK: - Statistiche
    func getStatisticheFiles() -> (totali: Int, dimensione: String) {
        var totaleFiles = 0
        var dimensioneTotale: Int64 = 0
        
        let cartelle = [documentiCompilatiFolderURL, backupFolderURL, exportFolderURL]
        
        for cartella in cartelle {
            do {
                let files = try fileManager.contentsOfDirectory(at: cartella, includingPropertiesForKeys: [.fileSizeKey])
                totaleFiles += files.count
                
                for file in files {
                    let attributes = try file.resourceValues(forKeys: [.fileSizeKey])
                    dimensioneTotale += Int64(attributes.fileSize ?? 0)
                }
            } catch {
                print("❌ Errore lettura cartella \(cartella): \(error)")
            }
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        
        return (totaleFiles, formatter.string(fromByteCount: dimensioneTotale))
    }
}

// MARK: - ⭐ ESTENSIONI ADOBE (dalla versione precedente)

extension FileManagerDocumenti {
    
    // MARK: - ⭐ METODI AGGIUNTIVI PER ADOBE INTEGRATION
    
    // ⭐ SALVATAGGIO TEMPLATE PERSONALIZZATI
    func salvaTemplate(_ template: DocumentoTemplate) throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let templateData = try encoder.encode(template)
        
        let nomeFile = "\(template.nome.replacingOccurrences(of: " ", with: "_")).json"
        let fileURL = templatesFolderURL.appendingPathComponent(nomeFile)
        
        try templateData.write(to: fileURL)
        
        print("📄 Template salvato: \(fileURL.lastPathComponent)")
        return fileURL
    }
    
    // ⭐ CARICAMENTO TEMPLATE PERSONALIZZATI
    func caricaTemplates() -> [DocumentoTemplate] {
        var templates: [DocumentoTemplate] = []
        
        do {
            let jsonFiles = try fileManager.contentsOfDirectory(at: templatesFolderURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for file in jsonFiles {
                do {
                    let data = try Data(contentsOf: file)
                    let template = try decoder.decode(DocumentoTemplate.self, from: data)
                    templates.append(template)
                    print("📄 Template caricato: \(template.nome)")
                } catch {
                    print("❌ Errore caricamento template \(file.lastPathComponent): \(error)")
                }
            }
        } catch {
            print("❌ Errore lettura cartella templates: \(error)")
        }
        
        return templates.sorted { $0.nome < $1.nome }
    }
    
    // ⭐ ELIMINA TEMPLATE
    func eliminaTemplate(_ template: DocumentoTemplate) throws {
        let nomeFile = "\(template.nome.replacingOccurrences(of: " ", with: "_")).json"
        let fileURL = templatesFolderURL.appendingPathComponent(nomeFile)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🗑️ Template eliminato: \(template.nome)")
        }
    }
    
    // ⭐ BACKUP COMPLETO CON ADOBE METADATA
    func creaBackupCompleto(_ documenti: [DocumentoCompilato], templates: [DocumentoTemplate]) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dataStr = dateFormatter.string(from: Date())
        
        // Struttura backup completa
        let backupData = BackupCompleto(
            versione: "2.0-Adobe",
            dataCreazione: Date(),
            documenti: documenti,
            templates: templates,
            metadati: [
                "total_documents": "\(documenti.count)",
                "total_templates": "\(templates.count)",
                "adobe_enabled": "true",
                "app_version": "2.0"
            ]
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(backupData)
        
        let nomeFile = "backup_completo_adobe_\(dataStr).json"
        let backupURL = backupFolderURL.appendingPathComponent(nomeFile)
        
        try jsonData.write(to: backupURL)
        
        print("💾 Backup completo Adobe creato: \(backupURL.lastPathComponent)")
        return backupURL
    }
    
    // ⭐ RESTORE DA BACKUP
    func ripristinaBackup(da url: URL) throws -> (documenti: [DocumentoCompilato], templates: [DocumentoTemplate]) {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let backup = try decoder.decode(BackupCompleto.self, from: data)
        
        print("📥 Backup ripristinato: \(backup.documenti.count) documenti, \(backup.templates.count) templates")
        
        return (backup.documenti, backup.templates)
    }
    
    // ⭐ EXPORT MULTIPLO FORMATO
    func esportaDocumentoMultiFormato(_ documento: DocumentoCompilato) throws -> [URL] {
        var urls: [URL] = []
        
        // TXT
        let txtURL = try salvaDocumentoCompilato(documento)
        urls.append(txtURL)
        
        // JSON
        let jsonURL = try salvaDocumentoJSON(documento)
        urls.append(jsonURL)
        
        // PDF
        let pdfURL = try esportaPDF(documento)
        urls.append(pdfURL)
        
        // Word/RTF
        let wordURL = try esportaWord(documento)
        urls.append(wordURL)
        
        print("📦 Export multi-formato completato: \(urls.count) file")
        return urls
    }
    
    // ⭐ STATISTICHE AVANZATE
    func getStatisticheAvanzate() -> StatisticheFiles {
        var statistiche = StatisticheFiles()
        
        let cartelle = [
            ("Documenti", documentiCompilatiFolderURL),
            ("Templates", templatesFolderURL),
            ("Backup", backupFolderURL),
            ("Export", exportFolderURL)
        ]
        
        for (nome, url) in cartelle {
            do {
                let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
                
                var dimensioneCartella: Int64 = 0
                var fileOggi = 0
                
                let oggi = Calendar.current.startOfDay(for: Date())
                
                for file in files {
                    let attributes = try file.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                    
                    if let size = attributes.fileSize {
                        dimensioneCartella += Int64(size)
                    }
                    
                    if let dataCreazione = attributes.creationDate,
                       Calendar.current.isDate(dataCreazione, inSameDayAs: oggi) {
                        fileOggi += 1
                    }
                }
                
                statistiche.cartelle[nome] = CartellaStats(
                    numeroFile: files.count,
                    dimensione: dimensioneCartella,
                    fileOggi: fileOggi
                )
                
                statistiche.totaleFile += files.count
                statistiche.dimensioneTotale += dimensioneCartella
                
            } catch {
                print("❌ Errore statistiche cartella \(nome): \(error)")
            }
        }
        
        return statistiche
    }
    
    // ⭐ PULIZIA CACHE ADOBE
    func pulisciCacheAdobe() throws {
        let cacheURL = appBaseURL.appendingPathComponent("Cache")
        
        if fileManager.fileExists(atPath: cacheURL.path) {
            try fileManager.removeItem(at: cacheURL)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
            print("🧹 Cache Adobe pulita")
        }
    }
    
    // ⭐ VERIFICA INTEGRITÀ FILES
    func verificaIntegritaFiles() -> VerificaIntegrità {
        var verifica = VerificaIntegrità()
        
        // Verifica documenti JSON
        do {
            let jsonFiles = try fileManager.contentsOfDirectory(at: backupFolderURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "json" }
            
            for file in jsonFiles {
                do {
                    let data = try Data(contentsOf: file)
                    let _ = try JSONDecoder().decode(DocumentoCompilato.self, from: data)
                    verifica.fileValidi += 1
                } catch {
                    verifica.fileCorretti += 1
                    verifica.errori.append("File corrotto: \(file.lastPathComponent)")
                }
            }
        } catch {
            verifica.errori.append("Errore lettura backup: \(error.localizedDescription)")
        }
        
        return verifica
    }
}

// MARK: - ⭐ STRUTTURE DATI DI SUPPORTO

struct BackupCompleto: Codable {
    let versione: String
    let dataCreazione: Date
    let documenti: [DocumentoCompilato]
    let templates: [DocumentoTemplate]
    let metadati: [String: String]
}

struct StatisticheFiles {
    var totaleFile: Int = 0
    var dimensioneTotale: Int64 = 0
    var cartelle: [String: CartellaStats] = [:]
    
    var dimensioneTotaleFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: dimensioneTotale)
    }
}

struct CartellaStats {
    let numeroFile: Int
    let dimensione: Int64
    let fileOggi: Int
    
    var dimensioneFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: dimensione)
    }
}

struct VerificaIntegrità {
    var fileValidi: Int = 0
    var fileCorretti: Int = 0
    var errori: [String] = []
    
    var percentualeIntegrità: Double {
        let totale = fileValidi + fileCorretti
        guard totale > 0 else { return 100.0 }
        return Double(fileValidi) / Double(totale) * 100.0
    }
}

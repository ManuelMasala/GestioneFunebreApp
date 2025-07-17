//
//  ExportUtilities.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 11/07/25.
//

import Foundation
import SwiftUI

// MARK: - Export Utilities
struct ExportUtilities {
    
    // MARK: - CSV Export
    static func exportToCSV(defunti: [PersonaDefunta]) -> String {
        var csvString = ""
        
        // Header CSV
        let headers = [
            "Numero Cartella", "Nome", "Cognome", "Codice Fiscale",
            "Data Nascita", "Luogo Nascita", "Data Decesso", "Ora Decesso",
            "Età", "Sesso", "Stato Civile", "Nome Coniuge", "Paternità", "Maternità",
            "Luogo Decesso", "Nome Ospedale", "Tipo Documento", "Numero Documento",
            "Ente Rilascio", "Tipo Sepoltura", "Luogo Sepoltura", "Dettagli Sepoltura",
            "Nome Familiare", "Cognome Familiare", "Parentela", "Telefono Familiare",
            "Email Familiare", "Operatore", "Data Creazione", "Data Ultima Modifica"
        ]
        
        csvString += headers.joined(separator: ",") + "\n"
        
        // Dati
        for defunto in defunti {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            let row = [
                escapeCSV(defunto.numeroCartella),
                escapeCSV(defunto.nome),
                escapeCSV(defunto.cognome),
                escapeCSV(defunto.codiceFiscale),
                escapeCSV(defunto.dataNascitaFormattata),
                escapeCSV(defunto.luogoNascita),
                escapeCSV(defunto.dataDecesoFormattata),
                escapeCSV(defunto.oraDecesso),
                "\(defunto.eta)",
                escapeCSV(defunto.sesso.descrizione),
                escapeCSV(defunto.statoCivile.rawValue),
                escapeCSV(defunto.nomeConiuge ?? ""),
                escapeCSV(defunto.paternita),
                escapeCSV(defunto.maternita),
                escapeCSV(defunto.luogoDecesso.rawValue),
                escapeCSV(defunto.nomeOspedale ?? ""),
                escapeCSV(defunto.documentoRiconoscimento.tipo.rawValue),
                escapeCSV(defunto.documentoRiconoscimento.numero),
                escapeCSV(defunto.documentoRiconoscimento.enteRilascio),
                escapeCSV(defunto.tipoSepoltura.rawValue),
                escapeCSV(defunto.luogoSepoltura),
                escapeCSV(defunto.dettagliSepoltura ?? ""),
                escapeCSV(defunto.familiareRichiedente.nome),
                escapeCSV(defunto.familiareRichiedente.cognome),
                escapeCSV(defunto.familiareRichiedente.parentela.rawValue),
                escapeCSV(defunto.familiareRichiedente.telefono),
                escapeCSV(defunto.familiareRichiedente.email ?? ""),
                escapeCSV(defunto.operatoreCreazione),
                escapeCSV(defunto.dataCreazioneFormattata),
                escapeCSV(dateFormatter.string(from: defunto.dataUltimaModifica))
            ]
            
            csvString += row.joined(separator: ",") + "\n"
        }
        
        return csvString
    }
    
    // MARK: - TXT Export
    static func exportToTXT(defunti: [PersonaDefunta]) -> String {
        var txtContent = ""
        
        // Header
        txtContent += generateTextHeader()
        txtContent += "\n"
        txtContent += String(repeating: "=", count: 80) + "\n\n"
        
        // Statistiche
        txtContent += generateStatistics(defunti: defunti)
        txtContent += "\n" + String(repeating: "-", count: 80) + "\n\n"
        
        // Lista defunti
        for (index, defunto) in defunti.enumerated() {
            txtContent += generateDefuntoText(defunto: defunto, numero: index + 1)
            txtContent += "\n"
        }
        
        // Footer
        txtContent += String(repeating: "=", count: 80) + "\n"
        txtContent += generateTextFooter()
        
        return txtContent
    }
    
    // MARK: - JSON Export
    static func exportToJSON(defunti: [PersonaDefunta]) -> String? {
        let exportData = JSONExportData(
            exportDate: Date(),
            appVersion: "1.0.0", // Fisso invece di AppConfiguration.version
            totalDefunti: defunti.count,
            defunti: defunti
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let jsonData = try encoder.encode(exportData)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Errore nell'export JSON: \(error)")
            return nil
        }
    }
    
    // MARK: - HTML Export
    static func generateHTMLForPDF(defunto: PersonaDefunta) -> String {
        return """
        <!DOCTYPE html>
        <html lang="it">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Scheda Defunto - \(defunto.nomeCompleto)</title>
            <style>
                \(getHTMLStyles())
            </style>
        </head>
        <body>
            \(generateHTMLHeader())
            \(generateHTMLBody(defunto: defunto))
            \(generateHTMLFooter())
        </body>
        </html>
        """
    }
    
    // MARK: - File Utilities
    static func saveToFile(content: String, filename: String, format: ExportFormat) -> URL? {
        let fileManager = FileManager.default
        
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let exportFolder = documentsPath
            .appendingPathComponent("GestioneFunebre")
            .appendingPathComponent("Export")
        
        // Crea la cartella se non esiste
        try? fileManager.createDirectory(at: exportFolder, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let finalFilename = "\(filename)_\(timestamp).\(format.fileExtension)"
        let fileURL = exportFolder.appendingPathComponent(finalFilename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Errore nel salvataggio del file: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Helper Methods
    
    private static func escapeCSV(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
    
    private static func generateTextHeader() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "it_IT")
        
        return """
        AGENZIA FUNEBRE PARADISO
        Via Palabanda n. 21 - 09123 Cagliari
        Tel: 070/684679 - Cell: 348 9511328
        Email: info@agenziaparadiso.it
        
        ELENCO DEFUNTI
        Generato il: \(dateFormatter.string(from: Date()))
        Versione App: 1.0.0
        """
    }
    
    private static func generateStatistics(defunti: [PersonaDefunta]) -> String {
        let stats = calculateStatistics(defunti: defunti)
        
        return """
        STATISTICHE GENERALI:
        • Totale defunti: \(stats.totale)
        • Maschi: \(stats.maschi) (\(String(format: "%.1f", stats.percentualeMaschi))%)
        • Femmine: \(stats.femmine) (\(String(format: "%.1f", stats.percentualeFemmine))%)
        • Età media: \(String(format: "%.1f", stats.etaMedia)) anni
        • Tumulazioni: \(stats.tumulazioni)
        • Inumazioni: \(stats.inumazioni)
        • Cremazioni: \(stats.cremazioni)
        """
    }
    
    private static func generateDefuntoText(defunto: PersonaDefunta, numero: Int) -> String {
        return """
        \(numero). \(defunto.nomeCompleto)
           Cartella: \(defunto.numeroCartella) | CF: \(defunto.codiceFiscale)
           Nato: \(defunto.dataNascitaFormattata) a \(defunto.luogoNascita)
           Deceduto: \(defunto.dataDecesoFormattata) alle \(defunto.oraDecesso)
           Età: \(defunto.eta) anni | Sesso: \(defunto.sesso.descrizione)
           Stato civile: \(defunto.statoCivile.rawValue)
           Sepoltura: \(defunto.tipoSepoltura.descrizione) - \(defunto.luogoSepoltura)
           Familiare: \(defunto.familiareRichiedente.nomeCompleto) (\(defunto.familiareRichiedente.parentela.rawValue))
           Operatore: \(defunto.operatoreCreazione) | Creato: \(defunto.dataCreazioneFormattata)
        """
    }
    
    private static func generateTextFooter() -> String {
        let year = Calendar.current.component(.year, from: Date())
        return """
        Report generato automaticamente da Gestione Funebre
        © \(year) Agenzia Funebre Paradiso. Tutti i diritti riservati.
        """
    }
    
    private static func calculateStatistics(defunti: [PersonaDefunta]) -> StatisticheDefunti {
        let totale = defunti.count
        let maschi = defunti.filter { $0.sesso == .maschio }.count
        let femmine = defunti.filter { $0.sesso == .femmina }.count
        let etaMedia = totale > 0 ? Double(defunti.reduce(0) { $0 + $1.eta }) / Double(totale) : 0
        
        let tumulazioni = defunti.filter { $0.tipoSepoltura == .tumulazione }.count
        let inumazioni = defunti.filter { $0.tipoSepoltura == .inumazione }.count
        let cremazioni = defunti.filter { $0.tipoSepoltura == .cremazione }.count
        
        let percentualeMaschi = totale > 0 ? (Double(maschi) / Double(totale)) * 100 : 0
        let percentualeFemmine = totale > 0 ? (Double(femmine) / Double(totale)) * 100 : 0
        
        return StatisticheDefunti(
            totale: totale,
            maschi: maschi,
            femmine: femmine,
            etaMedia: etaMedia,
            tumulazioni: tumulazioni,
            inumazioni: inumazioni,
            cremazioni: cremazioni,
            percentualeMaschi: percentualeMaschi,
            percentualeFemmine: percentualeFemmine
        )
    }
    
    private static func getHTMLStyles() -> String {
        return """
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            margin: 40px;
            line-height: 1.6;
            color: #333;
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
            border-bottom: 2px solid #007AFF;
            padding-bottom: 20px;
        }
        .company-info {
            text-align: center;
            margin-bottom: 30px;
            font-size: 12px;
            color: #666;
        }
        .section {
            margin-bottom: 25px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #007AFF;
        }
        .section-title {
            font-size: 18px;
            font-weight: bold;
            color: #007AFF;
            margin-bottom: 10px;
        }
        .label {
            font-weight: bold;
            display: inline-block;
            min-width: 150px;
        }
        .value {
            margin-left: 10px;
        }
        .row {
            margin-bottom: 8px;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 10px;
            color: #999;
        }
        """
    }
    
    private static func generateHTMLHeader() -> String {
        return """
        <div class="company-info">
            <strong>Agenzia Funebre Paradiso</strong><br>
            Via Palabanda n. 21 - 09123 Cagliari<br>
            Tel: 070/684679 - Cell: 348 9511328<br>
            Email: info@agenziaparadiso.it
        </div>
        """
    }
    
    private static func generateHTMLBody(defunto: PersonaDefunta) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "it_IT")
        
        return """
        <div class="header">
            <h1>Scheda Defunto</h1>
            <h2>\(defunto.nomeCompleto)</h2>
            <p>Cartella n. \(defunto.numeroCartella)</p>
        </div>
        
        <div class="section">
            <div class="section-title">Dati Anagrafici</div>
            <div class="row"><span class="label">Nome:</span><span class="value">\(defunto.nome)</span></div>
            <div class="row"><span class="label">Cognome:</span><span class="value">\(defunto.cognome)</span></div>
            <div class="row"><span class="label">Codice Fiscale:</span><span class="value">\(defunto.codiceFiscale)</span></div>
            <div class="row"><span class="label">Sesso:</span><span class="value">\(defunto.sesso.descrizione)</span></div>
            <div class="row"><span class="label">Data di Nascita:</span><span class="value">\(defunto.dataNascitaFormattata)</span></div>
            <div class="row"><span class="label">Luogo di Nascita:</span><span class="value">\(defunto.luogoNascita)</span></div>
            <div class="row"><span class="label">Età:</span><span class="value">\(defunto.eta) anni</span></div>
        </div>
        
        <div class="section">
            <div class="section-title">Decesso</div>
            <div class="row"><span class="label">Data:</span><span class="value">\(defunto.dataDecesoFormattata)</span></div>
            <div class="row"><span class="label">Ora:</span><span class="value">\(defunto.oraDecesso)</span></div>
            <div class="row"><span class="label">Luogo:</span><span class="value">\(defunto.luogoDecesso.rawValue)</span></div>
        </div>
        
        <div class="section">
            <div class="section-title">Sepoltura</div>
            <div class="row"><span class="label">Tipo:</span><span class="value">\(defunto.tipoSepoltura.descrizione)</span></div>
            <div class="row"><span class="label">Luogo:</span><span class="value">\(defunto.luogoSepoltura)</span></div>
        </div>
        """
    }
    
    private static func generateHTMLFooter() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "it_IT")
        
        let year = Calendar.current.component(.year, from: Date())
        
        return """
        <div class="footer">
            <p>Documento generato il \(dateFormatter.string(from: Date()))</p>
            <p>© \(year) Agenzia Funebre Paradiso. Tutti i diritti riservati.</p>
        </div>
        """
    }
}

// MARK: - Supporting Structures
struct JSONExportData: Codable {
    let exportDate: Date
    let appVersion: String
    let totalDefunti: Int
    let defunti: [PersonaDefunta]
}

struct StatisticheDefunti {
    let totale: Int
    let maschi: Int
    let femmine: Int
    let etaMedia: Double
    let tumulazioni: Int
    let inumazioni: Int
    let cremazioni: Int
    let percentualeMaschi: Double
    let percentualeFemmine: Double
}

// MARK: - Export Format (local to ExportUtilities)
enum ExportFormat: String, CaseIterable, Identifiable {
    case csv = "CSV"
    case pdf = "PDF"
    case txt = "TXT"
    case json = "JSON"
    
    var id: String { rawValue }
    
    var fileExtension: String {
        switch self {
        case .csv: return "csv"
        case .pdf: return "pdf"
        case .txt: return "txt"
        case .json: return "json"
        }
    }
}

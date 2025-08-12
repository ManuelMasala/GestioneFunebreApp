//
//  DocumentoCompilato.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//
import Foundation
import SwiftUI

// MARK: - Documento Compilato
struct DocumentoCompilato: Identifiable, Codable, Hashable {
    let id = UUID()
    var template: DocumentoTemplate
    var defunto: PersonaDefunta
    var valoriCampi: [String: String] = [:]
    var contenutoFinale: String
    var dataCreazione: Date
    var dataUltimaModifica: Date
    var dataCompletamento: Date? // AGGIUNTO - Proprietà mancante
    var isCompletato: Bool
    var note: String
    var operatoreCreazione: String
    
    init(template: DocumentoTemplate, defunto: PersonaDefunta, operatoreCreazione: String = "Sistema") {
        self.template = template
        self.defunto = defunto
        self.contenutoFinale = template.contenuto
        self.dataCreazione = Date()
        self.dataUltimaModifica = Date()
        self.dataCompletamento = nil // AGGIUNTO
        self.isCompletato = false
        self.note = ""
        self.operatoreCreazione = operatoreCreazione
    }
    
    // MARK: - Computed Properties
    var dataCreazioneFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCreazione)
    }
    
    var dataModificaFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataUltimaModifica)
    }
    
    // AGGIUNTO - Formattazione data completamento
    var dataCompletamentoFormattata: String? {
        guard let dataCompletamento = dataCompletamento else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCompletamento)
    }
    
    var nomeFileConsigliato: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dataStr = dateFormatter.string(from: dataCreazione)
        
        let cognome = defunto.cognome.replacingOccurrences(of: " ", with: "_")
        let templateNome = template.nome.replacingOccurrences(of: " ", with: "_")
        
        return "\(dataStr)_\(templateNome)_\(cognome)"
    }
    
    var placeholderNonSostituiti: [String] {
        let pattern = "\\{\\{([A-Z_]+)\\}\\}"
        var placeholder: [String] = []
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: contenutoFinale, range: NSRange(contenutoFinale.startIndex..., in: contenutoFinale))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: contenutoFinale) {
                    let placeholderTrovato = String(contenutoFinale[range])
                    if !placeholder.contains(placeholderTrovato) {
                        placeholder.append(placeholderTrovato)
                    }
                }
            }
        } catch {
            print("Errore nella ricerca placeholder: \(error)")
        }
        
        return placeholder.sorted()
    }
    
    var percentualeCompletamento: Double {
        let totalePlaceholder = template.numeroPlaceholder
        if totalePlaceholder == 0 { return 100.0 }
        
        let placeholderRimasti = placeholderNonSostituiti.count
        return Double(totalePlaceholder - placeholderRimasti) / Double(totalePlaceholder) * 100.0
    }
    
    // MARK: - Methods
    mutating func compilaConDefunto() {
        let sostituzioni = [
            "NOME_DEFUNTO": defunto.nome,
            "COGNOME_DEFUNTO": defunto.cognome,
            "LUOGO_NASCITA_DEFUNTO": defunto.luogoNascita,
            "DATA_NASCITA_DEFUNTO": defunto.dataNascitaFormattata,
            "DATA_DECESSO": defunto.dataDecesoFormattata,
            "ORA_DECESSO": defunto.oraDecesso,
            "LUOGO_DECESSO": defunto.luogoDecesso.rawValue,
            "TIPO_SEPOLTURA": defunto.tipoSepoltura.rawValue,
            "LUOGO_SEPOLTURA": defunto.luogoSepoltura,
            "NOME_FAMILIARE": defunto.familiareRichiedente.nome,
            "COGNOME_FAMILIARE": defunto.familiareRichiedente.cognome,
            "TELEFONO_FAMILIARE": defunto.familiareRichiedente.telefono,
            "COMUNE_DECESSO": estraiComune(da: defunto.luogoDecesso.rawValue),
            "NUMERO_CARTELLA": defunto.numeroCartella
        ]
        
        for (chiave, valore) in sostituzioni {
            aggiornaCampo(chiave: chiave, valore: valore)
        }
        
        dataUltimaModifica = Date()
    }
    
    mutating func aggiornaCampo(chiave: String, valore: String) {
        valoriCampi[chiave] = valore
        let placeholder = "{{\(chiave)}}"
        contenutoFinale = contenutoFinale.replacingOccurrences(of: placeholder, with: valore)
        dataUltimaModifica = Date()
    }
    
    mutating func aggiungiNota(_ nota: String) {
        if note.isEmpty {
            note = nota
        } else {
            note += "\n\(nota)"
        }
        dataUltimaModifica = Date()
    }
    
    mutating func marcaCompletato() {
        isCompletato = true
        dataCompletamento = Date() // AGGIUNTO - Imposta data completamento
        dataUltimaModifica = Date()
    }
    
    func validaCompletezza() -> [String] {
        var errori: [String] = []
        
        let placeholderMancanti = placeholderNonSostituiti
        if !placeholderMancanti.isEmpty {
            errori.append("Ci sono ancora \(placeholderMancanti.count) placeholder non sostituiti")
        }
        
        for campo in template.campiObbligatori {
            if let valore = valoriCampi[campo.chiave], valore.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errori.append("Il campo '\(campo.nome)' è obbligatorio")
            }
        }
        
        return errori
    }
    
    func esportaComeTestoSemplice() -> String {
        var output = ""
        output += "=== \(template.nome) ===\n\n"
        output += "Defunto: \(defunto.nomeCompleto)\n"
        output += "Cartella N°: \(defunto.numeroCartella)\n"
        output += "Data Generazione: \(dataCreazioneFormattata)\n"
        if let dataCompl = dataCompletamentoFormattata {
            output += "Data Completamento: \(dataCompl)\n"
        }
        output += "Operatore: \(operatoreCreazione)\n\n"
        output += "--- CONTENUTO DOCUMENTO ---\n\n"
        output += contenutoFinale
        
        if !note.isEmpty {
            output += "\n\n--- NOTE ---\n"
            output += note
        }
        
        return output
    }
    
    func esportaComeJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    func salvaSuFile(url: URL, formato: FormatoEsportazione = .testoSemplice) throws {
        let contenuto: Data
        
        switch formato {
        case .testoSemplice:
            contenuto = esportaComeTestoSemplice().data(using: .utf8) ?? Data()
        case .json:
            contenuto = try esportaComeJSON()
        case .csv:
            let csvContent = "Template,Defunto,Cartella,Data\n\(template.nome),\(defunto.nomeCompleto),\(defunto.numeroCartella),\(dataCreazioneFormattata)"
            contenuto = csvContent.data(using: .utf8) ?? Data()
        case .pdf:
            throw DocumentoError.formatoNonSupportato
        }
        
        try contenuto.write(to: url)
    }
    
    func creaPDF() throws -> Data {
        let pdfData = NSMutableData()
        
        guard let dataConsumer = CGDataConsumer(data: pdfData),
              let pdfContext = CGContext(consumer: dataConsumer, mediaBox: nil, nil) else {
            throw DocumentoError.pdfCreationFailed
        }
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        pdfContext.beginPDFPage(nil)
        
        let headerText = "\(template.nome)\nDefunto: \(defunto.nomeCompleto)\nData: \(dataCreazioneFormattata)\n\n"
        let fullText = headerText + contenutoFinale
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Times New Roman", size: 12) ?? NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: fullText, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let textRect = CGRect(x: 50, y: 50, width: 495, height: 742)
        let path = CGPath(rect: textRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        
        pdfContext.textMatrix = .identity
        pdfContext.translateBy(x: 0, y: pageRect.height)
        pdfContext.scaleBy(x: 1, y: -1)
        
        CTFrameDraw(frame, pdfContext)
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return pdfData as Data
    }
    
    // MARK: - Funzioni helper
    func estraiComune(da luogo: String) -> String {
        if luogo.contains("Ospedale") && luogo.contains("Cagliari") {
            return "Cagliari"
        } else if luogo.contains("Quartu") {
            return "Quartu Sant'Elena"
        } else if luogo.contains("Assemini") {
            return "Assemini"
        } else if luogo.contains("Pula") {
            return "Pula"
        }
        return "Cagliari"
    }
    
    // MARK: - Conformità Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DocumentoCompilato, rhs: DocumentoCompilato) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Estensioni per DocumentoCompilato
extension DocumentoCompilato {
    mutating func aggiungiDatiMezzo(_ mezzo: Mezzo) {
        let campiMezzo = [
            "MEZZO_TARGA": mezzo.targa,
            "MEZZO_MARCA": mezzo.marca,
            "MEZZO_MODELLO": mezzo.modello,
            "MEZZO_KM": mezzo.km,
            "AUTISTA": "Marco Lecca",
            "ORARIO_PARTENZA": "ore da definire",
            "LUOGO_PARTENZA": "da definire"
        ]
        
        for (chiave, valore) in campiMezzo {
            aggiornaCampo(chiave: chiave, valore: valore)
        }
    }
    
    mutating func aggiungiSezioneTrasporto(_ testoTrasporto: String) {
        let pattern = "Dichiara la salma verrà trasportata.*?in data.*?\\."
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            let range = NSRange(contenutoFinale.startIndex..., in: contenutoFinale)
            
            if let match = regex.firstMatch(in: contenutoFinale, range: range) {
                if let swiftRange = Range(match.range, in: contenutoFinale) {
                    contenutoFinale = contenutoFinale.replacingCharacters(in: swiftRange, with: testoTrasporto)
                }
            } else {
                contenutoFinale += "\n\n" + testoTrasporto
            }
        } catch {
            contenutoFinale += "\n\n" + testoTrasporto
        }
        
        dataUltimaModifica = Date()
    }
    
    func estraiDatiTrasporto() -> DatiTrasporto? {
        var dati = DatiTrasporto()
        
        let patterns = [
            ("mezzoETarga", "mezzo auto ([^\\s]+(?:\\s+[^\\s]+)*) condotta"),
            ("nomeAutista", "condotta da ([^\\s]+(?:\\s+[^\\s]+)*) con partenza"),
            ("orarioPartenza", "alle ore ([^\\s]+) da"),
            ("nomeViaOspedale", "da ([^\\s]+(?:\\s+[^\\s]+)*) al"),
            ("nomeParrocchia", "al ([^\\s]+(?:\\s+[^\\s]+)*) per la funzione"),
            ("luogoDestinazione", "successivamente al ([^\\s]+(?:\\s+[^\\s]+)*) per la")
        ]
        
        for (campo, pattern) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(contenutoFinale.startIndex..., in: contenutoFinale)
                
                if let match = regex.firstMatch(in: contenutoFinale, range: range),
                   let swiftRange = Range(match.range(at: 1), in: contenutoFinale) {
                    let valore = String(contenutoFinale[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    switch campo {
                    case "mezzoETarga": dati.mezzoETarga = valore
                    case "nomeAutista": dati.nomeAutista = valore
                    case "orarioPartenza": dati.orarioPartenza = valore
                    case "nomeViaOspedale": dati.nomeViaOspedale = valore
                    case "nomeParrocchia": dati.nomeParrocchia = valore
                    case "luogoDestinazione": dati.luogoDestinazione = valore
                    default: break
                    }
                }
            } catch {
                print("Errore nell'estrazione del campo \(campo): \(error)")
            }
        }
        
        return dati
    }
}

// MARK: - Formato Esportazione
enum FormatoEsportazione: String, CaseIterable {
    case testoSemplice = "Testo Semplice (.txt)"
    case json = "JSON (.json)"
    case csv = "CSV (.csv)"
    case pdf = "PDF (.pdf)"
    
    var estensione: String {
        switch self {
        case .testoSemplice: return "txt"
        case .json: return "json"
        case .csv: return "csv"
        case .pdf: return "pdf"
        }
    }
}

// MARK: - Document Error
enum DocumentoError: Error, LocalizedError {
    case pdfCreationFailed
    case fileWriteFailed
    case formatoNonSupportato
    case datiMancanti
    
    var errorDescription: String? {
        switch self {
        case .pdfCreationFailed:
            return "Impossibile creare il file PDF"
        case .fileWriteFailed:
            return "Impossibile scrivere il file"
        case .formatoNonSupportato:
            return "Formato di esportazione non supportato"
        case .datiMancanti:
            return "Dati del documento incompleti"
        }
    }
}

// MARK: - Dati Trasporto
struct DatiTrasporto: Codable {
    var mezzoETarga: String = ""
    var nomeAutista: String = "Marco Lecca"
    var orarioPartenza: String = ""
    var nomeViaOspedale: String = ""
    var nomeParrocchia: String = ""
    var luogoDestinazione: String = ""
    var tipoSepoltura: String = "tumulazione"
    var dataTrasporto: Date = Date()
    var dettagliCremazione: String = ""
    
    func generaTesto() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        
        let dataStr = formatter.string(from: dataTrasporto)
        
        var testo = """
        Dichiara la salma verrà trasportata a mezzo auto \(mezzoETarga) condotta da \(nomeAutista) con partenza alle ore \(orarioPartenza) da \(nomeViaOspedale) al \(nomeParrocchia) per la funzione religiosa e successivamente al \(luogoDestinazione) per la \(tipoSepoltura) in data \(dataStr).
        """
        
        if !dettagliCremazione.isEmpty {
            testo += " \(dettagliCremazione)"
        }
        
        return testo
    }
}

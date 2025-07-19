//
//  DocumentoCompilato.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import Foundation

// MARK: - Documento Compilato
struct DocumentoCompilato: Identifiable, Codable, Hashable {
    let id = UUID()
    var template: DocumentoTemplate
    var defunto: PersonaDefunta
    var valoriCampi: [String: String] = [:]
    var contenutoFinale: String
    var dataCreazione: Date
    var dataUltimaModifica: Date
    var isCompletato: Bool
    var note: String
    var operatoreCreazione: String
    
    init(template: DocumentoTemplate, defunto: PersonaDefunta, operatoreCreazione: String = "Sistema") {
        self.template = template
        self.defunto = defunto
        self.contenutoFinale = template.contenuto
        self.dataCreazione = Date()
        self.dataUltimaModifica = Date()
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
    
    // MARK: - Methods
    mutating func compilaConDefunto() {
        // Sostituisce i placeholder con i dati del defunto
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
            "COMUNE_DECESSO": estraiComune(da: defunto.luogoDecesso.rawValue)
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
        dataUltimaModifica = Date()
    }
    
    func validaCompletezza() -> [String] {
        var errori: [String] = []
        
        let placeholderMancanti = placeholderNonSostituiti
        if !placeholderMancanti.isEmpty {
            errori.append("Ci sono ancora \(placeholderMancanti.count) placeholder non sostituiti")
        }
        
        // Verifica campi obbligatori del template
        for campo in template.campiObbligatori {
            if let valore = valoriCampi[campo.chiave], valore.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errori.append("Il campo '\(campo.nome)' è obbligatorio")
            }
        }
        
        return errori
    }
    
    private func estraiComune(da luogo: String) -> String {
        // Estrae il comune dal luogo di decesso
        if luogo.contains("Ospedale") && luogo.contains("Cagliari") {
            return "Cagliari"
        }
        // Aggiungi altre logiche di estrazione se necessarie
        return "Cagliari" // Default
    }
    
    // MARK: - Conformità Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DocumentoCompilato, rhs: DocumentoCompilato) -> Bool {
        return lhs.id == rhs.id
    }
}

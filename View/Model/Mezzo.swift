//
//  Mezzo.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import Foundation
import SwiftUI

// MARK: - Enum per Stati e Tipi
enum StatoMezzo: String, CaseIterable, Identifiable, Codable {
    case disponibile = "Disponibile"
    case inUso = "In Uso"
    case manutenzione = "Manutenzione"
    case fuoriServizio = "Fuori Servizio"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .disponibile: return .green
        case .inUso: return .blue
        case .manutenzione: return .orange
        case .fuoriServizio: return .red
        }
    }
}

enum TipoProprietaMezzo: String, CaseIterable, Identifiable, Codable {
    case proprio = "Proprio"
    case noleggio = "Noleggio"
    
    var id: String { self.rawValue }
}

enum TipoManutenzione: String, CaseIterable, Identifiable, Codable {
    case ordinaria = "Ordinaria"
    case straordinaria = "Straordinaria"
    case revisione = "Revisione"
    case riparazione = "Riparazione"
    case tagliando = "Tagliando"
    
    var id: String { self.rawValue }
}

// MARK: - Strutture Dati
struct Manutenzione: Identifiable, Codable {
    let id = UUID()
    var data: Date
    var tipo: TipoManutenzione
    var descrizione: String
    var costo: Double
    var officina: String
    var note: String
    var dataCreazione: Date
    
    init(data: Date, tipo: TipoManutenzione, descrizione: String, costo: Double = 0.0, officina: String = "", note: String = "") {
        self.data = data
        self.tipo = tipo
        self.descrizione = descrizione
        self.costo = costo
        self.officina = officina
        self.note = note
        self.dataCreazione = Date()
    }
}

struct Mezzo: Identifiable, Codable {
    let id = UUID()
    var targa: String
    var modello: String
    var marca: String
    var stato: StatoMezzo
    var km: String
    var dataRevisione: Date
    var tipoProprietà: TipoProprietaMezzo
    var dataAcquisto: Date?
    var dataScadenzaNoleggio: Date?
    var costoNoleggio: Double?
    var note: String
    var manutenzioni: [Manutenzione]
    var dataCreazione: Date
    
    init(targa: String, modello: String, marca: String, stato: StatoMezzo = .disponibile, km: String = "0", dataRevisione: Date, tipoProprietà: TipoProprietaMezzo = .proprio) {
        self.targa = targa
        self.modello = modello
        self.marca = marca
        self.stato = stato
        self.km = km
        self.dataRevisione = dataRevisione
        self.tipoProprietà = tipoProprietà
        self.note = ""
        self.manutenzioni = []
        self.dataCreazione = Date()
    }
    
    // Computed properties
    var ultimaManutenzione: Manutenzione? {
        manutenzioni.sorted { $0.data > $1.data }.first
    }
    
    var costoTotaleManutenzioni: Double {
        manutenzioni.reduce(0) { $0 + $1.costo }
    }
    
    var isScadutoNoleggio: Bool {
        guard tipoProprietà == .noleggio,
              let scadenza = dataScadenzaNoleggio else { return false }
        return scadenza < Date()
    }
    
    var isRevisioneScaduta: Bool {
        dataRevisione < Date()
    }
}
// MARK: - AI Integration Extension per Mezzo
// AGGIUNGI QUESTA EXTENSION AL TUO FILE Mezzo.swift

extension Mezzo {
    
    /// Proprietà computed per compatibilità AI
    var kilometraggio: Int {
        // Converte la stringa km in intero per compatibilità AI
        return Int(km.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")) ?? 0
    }
    
    /// Indica se il mezzo è raccomandato dall'AI
    var isAIRecommended: Bool {
        return stato == .disponibile &&
               !isRevisioneScaduta &&
               kilometraggio < 150000 // Sotto 150k km
    }
    
    /// Score qualità per AI (0-100)
    var aiQualityScore: Int {
        var score = 50 // Base score
        
        // Stato del mezzo
        switch stato {
        case .disponibile: score += 30
        case .inUso: score += 20
        case .manutenzione: score += 10
        case .fuoriServizio: score -= 20
        }
        
        // Chilometraggio
        switch kilometraggio {
        case 0..<50000: score += 20
        case 50000..<100000: score += 15
        case 100000..<150000: score += 10
        case 150000..<200000: score += 5
        default: score -= 10
        }
        
        // Revisione
        if !isRevisioneScaduta {
            score += 15
        } else {
            score -= 15
        }
        
        // Manutenzioni recenti
        if let ultimaManutenzione = ultimaManutenzione {
            let giorniDallUltimaManutenzione = Calendar.current.dateComponents([.day], from: ultimaManutenzione.data, to: Date()).day ?? 0
            if giorniDallUltimaManutenzione < 90 {
                score += 10
            }
        }
        
        return max(0, min(100, score))
    }
    
    /// Descrizione stato per AI
    var aiStatusDescription: String {
        var description = stato.rawValue
        
        if isRevisioneScaduta {
            description += " (Revisione scaduta)"
        }
        
        if tipoProprietà == .noleggio && isScadutoNoleggio {
            description += " (Noleggio scaduto)"
        }
        
        return description
    }
    
    /// Suggerimenti AI per il mezzo
    var aiSuggestions: [String] {
        var suggestions: [String] = []
        
        if isRevisioneScaduta {
            suggestions.append("Revisione scaduta - programmare urgentemente")
        }
        
        if kilometraggio > 200000 {
            suggestions.append("Alto chilometraggio - considerare sostituzione")
        }
        
        if stato == .manutenzione {
            suggestions.append("In manutenzione - verificare tempi di rientro")
        }
        
        if tipoProprietà == .noleggio && isScadutoNoleggio {
            suggestions.append("Noleggio scaduto - rinnovare contratto")
        }
        
        if manutenzioni.isEmpty {
            suggestions.append("Nessuna manutenzione registrata - aggiornare storico")
        }
        
        if let ultimaManutenzione = ultimaManutenzione {
            let giorniDallUltima = Calendar.current.dateComponents([.day], from: ultimaManutenzione.data, to: Date()).day ?? 0
            if giorniDallUltima > 180 {
                suggestions.append("Ultima manutenzione oltre 6 mesi fa")
            }
        }
        
        return suggestions
    }
    
    /// Formattazione chilometraggio per display
    var kmFormatted: String {
        if let kmInt = Int(km.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            return (formatter.string(from: NSNumber(value: kmInt)) ?? km) + " km"
        }
        return km + " km"
    }
}

// MARK: - Metodi AI per Manager
extension Mezzo {
    
    /// Aggiorna chilometraggio da stringa
    mutating func updateKilometraggio(_ newKm: String) {
        self.km = newKm.replacingOccurrences(of: " km", with: "")
    }
    
    /// Aggiorna chilometraggio da intero
    mutating func updateKilometraggio(_ newKm: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        self.km = formatter.string(from: NSNumber(value: newKm)) ?? "\(newKm)"
    }
    
    /// Verifica se il mezzo necessita manutenzione
    func needsMaintenance() -> Bool {
        // Logica per determinare se serve manutenzione
        if let ultimaManutenzione = ultimaManutenzione {
            let giorniDallUltima = Calendar.current.dateComponents([.day], from: ultimaManutenzione.data, to: Date()).day ?? 0
            return giorniDallUltima > 90 // Ogni 3 mesi
        }
        return true // Se non ha mai fatto manutenzione
    }
    
    /// Prossima data manutenzione suggerita
    func nextMaintenanceDate() -> Date {
        if let ultimaManutenzione = ultimaManutenzione {
            return Calendar.current.date(byAdding: .day, value: 90, to: ultimaManutenzione.data) ?? Date()
        }
        return Date() // Subito se non ha mai fatto manutenzione
    }
}

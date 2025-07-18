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

//
//  TipoDocumentoHelper.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import SwiftUI
import Foundation

// MARK: - TipoDocumentoHelper
struct TipoDocumentoHelper {
    
    // MARK: - Icon and Color Methods
    static func icona(for tipo: TipoDocumento) -> String {
        return tipo.icona
    }
    
    static func color(for tipo: TipoDocumento) -> Color {
        return tipo.color
    }
    
    static func descrizione(for tipo: TipoDocumento) -> String {
        return tipo.descrizione
    }
    
    // MARK: - Display Helpers
    static func nomeBreve(for tipo: TipoDocumento) -> String {
        switch tipo {
        case .autorizzazioneTrasporto: return "Trasporto"
        case .comunicazioneParrocchia: return "Parrocchia"
        case .checklistFunerale: return "Checklist"
        case .certificatoMorte: return "Certificato"
        case .dichiarazioneFamiliare: return "Dichiarazione"
        case .autorizzazioneSepoltura: return "Sepoltura"
        case .comunicazioneCimitero: return "Cimitero"
        case .fattura: return "Fattura"
        case .ricevuta: return "Ricevuta"
        case .contratto: return "Contratto"
        case .altro: return "Altro"
        }
    }
    
    static func categoria(for tipo: TipoDocumento) -> String {
        switch tipo {
        case .autorizzazioneTrasporto, .autorizzazioneSepoltura:
            return "Autorizzazioni"
        case .comunicazioneParrocchia, .comunicazioneCimitero:
            return "Comunicazioni"
        case .checklistFunerale:
            return "Organizzazione"
        case .certificatoMorte, .dichiarazioneFamiliare:
            return "Documenti Ufficiali"
        case .fattura, .ricevuta, .contratto:
            return "Amministrazione"
        case .altro:
            return "Varie"
        }
    }
    
    static func priorita(for tipo: TipoDocumento) -> Int {
        switch tipo {
        case .certificatoMorte: return 1
        case .autorizzazioneTrasporto: return 2
        case .autorizzazioneSepoltura: return 3
        case .dichiarazioneFamiliare: return 4
        case .checklistFunerale: return 5
        case .comunicazioneParrocchia: return 6
        case .comunicazioneCimitero: return 7
        case .contratto: return 8
        case .fattura: return 9
        case .ricevuta: return 10
        case .altro: return 11
        }
    }
}

//
//  HelperUtilities.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//
import Foundation
import SwiftUI

// MARK: - ⭐ HELPER UTILITIES PULITO (SENZA DUPLICAZIONI)

// MARK: - PersonaDefuntaHelperAdobe (per Adobe system)
struct PersonaDefuntaHelperAdobe {
    
    static func nomeCompleto(for persona: PersonaDefunta) -> String {
        return "\(persona.nome) \(persona.cognome)"
    }
    
    static func eta(for persona: PersonaDefunta) -> Int {
        return Calendar.current.dateComponents([.year], from: persona.dataNascita, to: persona.dataDecesso).year ?? 0
    }
    
    static func dataNascitaFormattata(for persona: PersonaDefunta) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: persona.dataNascita)
    }
    
    static func dataDecesoFormattata(for persona: PersonaDefunta) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: persona.dataDecesso)
    }
    
    static func dataCreazioneFormattata(for persona: PersonaDefunta) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: persona.dataCreazione)
    }
    
    static func indirizzoCompleto(for persona: PersonaDefunta) -> String {
        var componenti: [String] = []
        
        if !persona.indirizzoResidenza.isEmpty {
            componenti.append(persona.indirizzoResidenza)
        }
        
        if !persona.cittaResidenza.isEmpty {
            componenti.append(persona.cittaResidenza)
        }
        
        if !persona.capResidenza.isEmpty && persona.capResidenza != "00000" {
            componenti.append(persona.capResidenza)
        }
        
        return componenti.isEmpty ? persona.luogoNascita : componenti.joined(separator: ", ")
    }
}

// MARK: - FamiliareResponsabileHelperAdobe (per Adobe system)
struct FamiliareResponsabileHelperAdobe {
    
    static func nomeCompleto(for familiare: FamiliareResponsabile) -> String {
        return "\(familiare.nome.uppercased()) \(familiare.cognome.uppercased())"
    }
    
    static func eta(for familiare: FamiliareResponsabile) -> Int {
        return Calendar.current.dateComponents([.year], from: familiare.dataNascita, to: Date()).year ?? 0
    }
    
    static func indirizzoCompleto(for familiare: FamiliareResponsabile) -> String {
        var componenti: [String] = []
        
        if !familiare.indirizzo.isEmpty {
            componenti.append(familiare.indirizzo)
        }
        
        if !familiare.citta.isEmpty {
            componenti.append(familiare.citta)
        }
        
        if !familiare.cap.isEmpty && familiare.cap != "00000" {
            componenti.append(familiare.cap)
        }
        
        return componenti.joined(separator: ", ")
    }
}

// MARK: - SessoPersonaHelper
struct SessoPersonaHelper {
    
    static func simbolo(for sesso: SessoPersona) -> String {
        switch sesso {
        case .maschio: return "♂"
        case .femmina: return "♀"
        }
    }
    
    static func descrizione(for sesso: SessoPersona) -> String {
        switch sesso {
        case .maschio: return "Maschio"
        case .femmina: return "Femmina"
        }
    }
    
    static func colore(for sesso: SessoPersona) -> Color {
        switch sesso {
        case .maschio: return .blue
        case .femmina: return .pink
        }
    }
    
    static func icona(for sesso: SessoPersona) -> String {
        switch sesso {
        case .maschio: return "person.fill"
        case .femmina: return "person.fill"
        }
    }
}

// MARK: - TipologiaSepoltureaHelper
struct TipologiaSepoltureaHelper {
    
    static func icona(for tipo: TipologiaSepoltura) -> String {
        switch tipo {
        case .tumulazione: return "building.columns"
        case .inumazione: return "leaf"
        case .cremazione: return "flame"
        }
    }
    
    static func colore(for tipo: TipologiaSepoltura) -> Color {
        switch tipo {
        case .tumulazione: return .gray
        case .inumazione: return .green
        case .cremazione: return .orange
        }
    }
    
    static func descrizione(for tipo: TipologiaSepoltura) -> String {
        switch tipo {
        case .tumulazione: return "Deposizione in loculo/tomba di famiglia"
        case .inumazione: return "Sepoltura in terra"
        case .cremazione: return "Cremazione del corpo"
        }
    }
}

// MARK: - ValidationHelper
struct ValidationHelper {
    
    static func validaCodiceFiscale(_ codiceFiscale: String) -> Bool {
        let pattern = "^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: codiceFiscale.count)
        return regex?.firstMatch(in: codiceFiscale, options: [], range: range) != nil
    }
    
    static func validaEmail(_ email: String?) -> Bool {
        guard let email = email, !email.isEmpty else { return true } // Email è opzionale
        
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validaTelefono(_ telefono: String) -> Bool {
        let cleanPhone = telefono.replacingOccurrences(of: " ", with: "")
                                  .replacingOccurrences(of: "-", with: "")
                                  .replacingOccurrences(of: "+", with: "")
        
        return cleanPhone.count >= 8 && cleanPhone.count <= 15 && cleanPhone.allSatisfy { $0.isNumber }
    }
    
    static func validaCAP(_ cap: String) -> Bool {
        return cap.count == 5 && cap.allSatisfy { $0.isNumber }
    }
}

// MARK: - FormatHelper
struct FormatHelper {
    
    static func formattaCodiceFiscale(_ codiceFiscale: String) -> String {
        return codiceFiscale.uppercased()
    }
    
    static func formattaTelefono(_ telefono: String) -> String {
        let cleanPhone = telefono.replacingOccurrences(of: " ", with: "")
                                  .replacingOccurrences(of: "-", with: "")
        
        // Formatta come XXX XXX XXXX per numeri italiani
        if cleanPhone.hasPrefix("39") || cleanPhone.hasPrefix("+39") {
            let number = cleanPhone.replacingOccurrences(of: "+39", with: "")
                                   .replacingOccurrences(of: "39", with: "")
            
            if number.count == 10 {
                let start = number.startIndex
                let part1 = String(number[start..<number.index(start, offsetBy: 3)])
                let part2 = String(number[number.index(start, offsetBy: 3)..<number.index(start, offsetBy: 6)])
                let part3 = String(number[number.index(start, offsetBy: 6)...])
                
                return "\(part1) \(part2) \(part3)"
            }
        }
        
        return cleanPhone
    }
    
    static func formattaCAP(_ cap: String) -> String {
        return String(cap.prefix(5))
    }
    
    static func formattaNome(_ nome: String) -> String {
        return nome.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - DocumentHelper (per documenti Adobe - rinominato per evitare conflitti)
struct DocumentHelper {
    
    // Icon and Color Methods
    static func icona(for tipo: TipoDocumento) -> String {
        return tipo.icona
    }
    
    static func color(for tipo: TipoDocumento) -> Color {
        return tipo.color
    }
    
    static func descrizione(for tipo: TipoDocumento) -> String {
        return tipo.descrizione
    }
    
    // Display Helpers
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

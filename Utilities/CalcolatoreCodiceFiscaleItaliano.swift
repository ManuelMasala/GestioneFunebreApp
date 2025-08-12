//
//  CalcolatoreCodiceFiscaleItaliano.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation

// MARK: - Calcolo Codice Fiscale Italiano (UNICA DEFINIZIONE)
struct CalcolatoreCodiceFiscaleItaliano {
    static func calcola(nome: String, cognome: String, dataNascita: Date, luogoNascita: String, sesso: SessoPersona) -> String {
        // Implementazione semplificata per demo
        // Sostituisci con la tua implementazione completa
        
        let consonants = "BCDFGHJKLMNPQRSTVWXYZ"
        let vowels = "AEIOU"
        
        func getConsonants(_ str: String) -> String {
            return String(str.uppercased().filter { consonants.contains($0) }.prefix(3))
                .padding(toLength: 3, withPad: "X", startingAt: 0)
        }
        
        func getVowels(_ str: String) -> String {
            return String(str.uppercased().filter { vowels.contains($0) }.prefix(3))
                .padding(toLength: 3, withPad: "X", startingAt: 0)
        }
        
        let cognomeCode = (getConsonants(cognome) + getVowels(cognome)).prefix(3)
        let nomeCode = (getConsonants(nome) + getVowels(nome)).prefix(3)
        
        let year = String(Calendar.current.component(.year, from: dataNascita)).suffix(2)
        let month = ["A", "B", "C", "D", "E", "H", "L", "M", "P", "R", "S", "T"][Calendar.current.component(.month, from: dataNascita) - 1]
        
        var day = Calendar.current.component(.day, from: dataNascita)
        if sesso == .femmina {
            day += 40
        }
        
        let dayCode = String(format: "%02d", day)
        
        return "\(cognomeCode)\(nomeCode)\(year)\(month)\(dayCode)H501X"
    }
}

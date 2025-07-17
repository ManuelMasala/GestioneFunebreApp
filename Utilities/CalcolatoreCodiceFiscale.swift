//
//  CalcolatoreCodiceFiscale.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 10/07/25.
//

import Foundation

// MARK: - CalcolatoreCodiceFiscaleItaliano
struct CalcolatoreCodiceFiscaleItaliano {
    static func calcola(nome: String, cognome: String, dataNascita: Date, luogoNascita: String, sesso: SessoPersona) -> String {
        // Implementazione semplificata del calcolo del codice fiscale
        let cognomeCode = calcolaCognome(cognome)
        let nomeCode = calcolaNome(nome)
        let dataCode = calcolaData(dataNascita, sesso: sesso)
        let luogoCode = calcolaLuogo(luogoNascita)
        
        let parziale = cognomeCode + nomeCode + dataCode + luogoCode
        let carattereControllo = calcolaCarattereControllo(parziale)
        
        return parziale + carattereControllo
    }
    
    private static func calcolaCognome(_ cognome: String) -> String {
        let consonanti = estraiConsonanti(cognome)
        let vocali = estraiVocali(cognome)
        
        var result = consonanti + vocali + "XXX"
        return String(result.prefix(3))
    }
    
    private static func calcolaNome(_ nome: String) -> String {
        let consonanti = estraiConsonanti(nome)
        let vocali = estraiVocali(nome)
        
        // Se ci sono 4 o più consonanti, si prendono la 1ª, 3ª e 4ª
        if consonanti.count >= 4 {
            let indici = [0, 2, 3]
            let selected: [String] = indici.compactMap { index in
                guard index < consonanti.count else { return nil }
                let stringIndex = consonanti.index(consonanti.startIndex, offsetBy: index)
                return String(consonanti[stringIndex])
            }
            return selected.joined()
        }
        
        var result = consonanti + vocali + "XXX"
        return String(result.prefix(3))
    }
    
    private static func calcolaData(_ data: Date, sesso: SessoPersona) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: data)
        
        let anno = String(components.year! % 100).padding(toLength: 2, withPad: "0", startingAt: 0)
        let mese = ["A", "B", "C", "D", "E", "H", "L", "M", "P", "R", "S", "T"][components.month! - 1]
        var giorno = components.day!
        
        if sesso == .femmina {
            giorno += 40
        }
        
        let giornoStr = String(giorno).padding(toLength: 2, withPad: "0", startingAt: 0)
        
        return anno + mese + giornoStr
    }
    
    private static func calcolaLuogo(_ luogo: String) -> String {
        // Codici catastali semplificati per alcune città italiane
        let codiciCatastali = [
            "ROMA": "H501",
            "MILANO": "F205",
            "NAPOLI": "F839",
            "TORINO": "L219",
            "CAGLIARI": "B354",
            "PALERMO": "G273",
            "FIRENZE": "D612",
            "BOLOGNA": "A944",
            "BARI": "A662",
            "GENOVA": "D969"
        ]
        
        return codiciCatastali[luogo.uppercased()] ?? "Z000"
    }
    
    private static func calcolaCarattereControllo(_ codice: String) -> String {
        let caratteriPari = "BAFHJNPRTVCESULDGIMOQKWZYX"
        let caratteriDispari = "BAKPLCQDREVOSFTGUHMINJWZYX"
        
        var somma = 0
        
        for (index, char) in codice.enumerated() {
            let posizione = index + 1
            
            if let valore = Int(String(char)) {
                // È un numero
                if posizione % 2 == 0 {
                    somma += valore
                } else {
                    let valoriDispari = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21]
                    somma += valoriDispari[valore]
                }
            } else {
                // È una lettera
                let asciiValue = Int(char.asciiValue!) - 65
                if posizione % 2 == 0 {
                    somma += asciiValue
                } else {
                    let valoriDispari = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20, 11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]
                    somma += valoriDispari[asciiValue]
                }
            }
        }
        
        let resto = somma % 26
        return String(caratteriPari[caratteriPari.index(caratteriPari.startIndex, offsetBy: resto)])
    }
    
    private static func estraiConsonanti(_ stringa: String) -> String {
        let consonanti = "BCDFGHJKLMNPQRSTVWXYZ"
        return String(stringa.uppercased().filter { consonanti.contains($0) })
    }
    
    private static func estraiVocali(_ stringa: String) -> String {
        let vocali = "AEIOU"
        return String(stringa.uppercased().filter { vocali.contains($0) })
    }
}

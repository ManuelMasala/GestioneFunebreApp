//
//  FamiliareUtilities.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 16/07/25.
//

import Foundation
import SwiftUI

// MARK: - Validatori
struct ValidatoreFamiliare {
    static func validaCodiceFiscale(_ codiceFiscale: String) -> Bool {
        return codiceFiscale.count == 16
    }
    
    static func validaTelefono(_ telefono: String) -> Bool {
        let cleaned = telefono.replacingOccurrences(of: " ", with: "")
        return cleaned.count >= 8 && cleaned.count <= 15
    }
    
    static func validaEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    static func validaCAP(_ cap: String) -> Bool {
        return cap.count == 5 && cap.allSatisfy { $0.isNumber }
    }
}

// MARK: - Manager per la gestione avanzata
extension ManagerGestioneDefunti {
    func validaDefuntoCompleto(_ defunto: PersonaDefunta) -> [String] {
        var errori = validaDefunto(defunto)
        
        // Validazione familiare
        let erroriFamiliare = defunto.familiareRichiedente.validate()
        errori.append(contentsOf: erroriFamiliare)
        
        // Validazioni aggiuntive
        if !ValidatoreFamiliare.validaCodiceFiscale(defunto.familiareRichiedente.codiceFiscale) {
            errori.append("Codice fiscale del familiare non valido")
        }
        
        if !ValidatoreFamiliare.validaTelefono(defunto.familiareRichiedente.telefono) {
            errori.append("Numero di telefono del familiare non valido")
        }
        
        if let email = defunto.familiareRichiedente.email, !email.isEmpty {
            if !ValidatoreFamiliare.validaEmail(email) {
                errori.append("Email del familiare non valida")
            }
        }
        
        if !ValidatoreFamiliare.validaCAP(defunto.familiareRichiedente.cap) {
            errori.append("CAP del familiare non valido")
        }
        
        return errori
    }
    
    // Genera statistiche avanzate sui familiari
    func statisticheFamiliari() -> StatisticheFamiliari {
        let familiari = defunti.map { $0.familiareRichiedente }
        
        let parentele = Dictionary(grouping: familiari, by: { $0.parentela })
        let parenteleCount = parentele.mapValues { $0.count }
        
        let etaMedia = familiari.reduce(0) { $0 + $1.eta } / max(familiari.count, 1)
        
        return StatisticheFamiliari(
            totale: familiari.count,
            parenteleCount: parenteleCount,
            etaMedia: Double(etaMedia),
            conEmail: familiari.filter { $0.email != nil }.count,
            conCellulare: familiari.filter { $0.cellulare != nil }.count
        )
    }
}

// MARK: - Struttura per statistiche familiari
struct StatisticheFamiliari {
    let totale: Int
    let parenteleCount: [FamiliareResponsabile.GradoParentela: Int]
    let etaMedia: Double
    let conEmail: Int
    let conCellulare: Int
}

// MARK: - Creatore di cartelle automatico
struct CreatoreCartelle {
    static func creaCartellaDefunto(_ defunto: PersonaDefunta) -> URL? {
        let fileManager = FileManager.default
        
        // Percorso base documenti
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Cartella principale
        let basePath = documentsPath
            .appendingPathComponent("GestioneFunebre")
            .appendingPathComponent("Defunti")
        
        // Nome cartella: "0001 - MARIO ROSSI"
        let nomeCartella = "\(defunto.numeroCartella) - \(defunto.nomeCompleto)"
        let cartellaDefunto = basePath.appendingPathComponent(nomeCartella)
        
        // Crea la struttura delle cartelle
        let sottocartelle = [
            "Documenti",
            "Moduli",
            "Corrispondenza",
            "Foto",
            "Note"
        ]
        
        do {
            // Crea cartella principale
            try fileManager.createDirectory(at: cartellaDefunto, withIntermediateDirectories: true)
            
            // Crea sottocartelle
            for sottocartella in sottocartelle {
                let path = cartellaDefunto.appendingPathComponent(sottocartella)
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
            }
            
            // Crea file README
            let readmeContent = """
            CARTELLA DEFUNTO: \(defunto.nomeCompleto)
            =====================================
            
            Numero Cartella: \(defunto.numeroCartella)
            Data Creazione: \(defunto.dataCreazioneFormattata)
            Operatore: \(defunto.operatoreCreazione)
            
            STRUTTURA CARTELLA:
            - Documenti: Documenti originali e copie
            - Moduli: Moduli compilati (Decreto, Richiesta Parrocchia, etc.)
            - Corrispondenza: Email e comunicazioni
            - Foto: Fotografie del defunto
            - Note: Appunti e annotazioni
            
            DATI DEFUNTO:
            Nome: \(defunto.nomeCompleto)
            Nato: \(defunto.dataNascitaFormattata) a \(defunto.luogoNascita)
            Deceduto: \(defunto.dataDecesoFormattata) alle \(defunto.oraDecesso)
            
            FAMILIARE RESPONSABILE:
            \(defunto.familiareRichiedente.nomeCompleto)
            Parentela: \(defunto.familiareRichiedente.parentela.rawValue)
            Telefono: \(defunto.familiareRichiedente.telefono)
            """
            
            let readmeURL = cartellaDefunto.appendingPathComponent("README.txt")
            try readmeContent.write(to: readmeURL, atomically: true, encoding: .utf8)
            
            return cartellaDefunto
            
        } catch {
            print("Errore nella creazione della cartella: \(error)")
            return nil
        }
    }
}

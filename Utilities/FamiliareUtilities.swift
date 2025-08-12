//
//  FamiliareUtilities.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 16/07/25.
//

import Foundation
import SwiftUI

// MARK: - ⭐ FAMILIARE UTILITIES CORRETTO

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
        // ✅ CORRETTO: Usa PersonaDefuntaHelperAdobe dal tuo HelperUtilities.swift
        var errori: [String] = []
        
        // Validazioni di base del defunto
        if defunto.nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il nome è obbligatorio")
        }
        
        if defunto.cognome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il cognome è obbligatorio")
        }
        
        if defunto.luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il luogo di nascita è obbligatorio")
        }
        
        if defunto.dataNascita >= defunto.dataDecesso {
            errori.append("La data di nascita deve essere precedente alla data di decesso")
        }
        
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
    
    // ✅ AGGIUNTO: Metodi di utilità aggiuntivi
    func defuntiPerParentela(_ parentela: FamiliareResponsabile.GradoParentela) -> [PersonaDefunta] {
        return defunti.filter { $0.familiareRichiedente.parentela == parentela }
    }
    
    func defuntiConEmailFamiliare() -> [PersonaDefunta] {
        return defunti.filter { $0.familiareRichiedente.email != nil && !$0.familiareRichiedente.email!.isEmpty }
    }
    
    func familiarConTelefonoIncompleto() -> [PersonaDefunta] {
        return defunti.filter { !ValidatoreFamiliare.validaTelefono($0.familiareRichiedente.telefono) }
    }
    
    func generaRapportoValidazione() -> RapportoValidazione {
        var totaleDefunti = 0
        var defuntiValidi = 0
        var erroriComuni: [String: Int] = [:]
        
        for defunto in defunti {
            totaleDefunti += 1
            let errori = validaDefuntoCompleto(defunto)
            
            if errori.isEmpty {
                defuntiValidi += 1
            } else {
                for errore in errori {
                    erroriComuni[errore, default: 0] += 1
                }
            }
        }
        
        return RapportoValidazione(
            totaleDefunti: totaleDefunti,
            defuntiValidi: defuntiValidi,
            defuntiConErrori: totaleDefunti - defuntiValidi,
            erroriComuni: erroriComuni,
            percentualeValidita: totaleDefunti > 0 ? Double(defuntiValidi) / Double(totaleDefunti) * 100 : 0
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
    
    var parentelaPiuComune: FamiliareResponsabile.GradoParentela? {
        parenteleCount.max(by: { $0.value < $1.value })?.key
    }
    
    var percentualeConEmail: Double {
        totale > 0 ? Double(conEmail) / Double(totale) * 100 : 0
    }
    
    var percentualeConCellulare: Double {
        totale > 0 ? Double(conCellulare) / Double(totale) * 100 : 0
    }
}

// MARK: - ✅ AGGIUNTO: Struttura rapporto validazione
struct RapportoValidazione {
    let totaleDefunti: Int
    let defuntiValidi: Int
    let defuntiConErrori: Int
    let erroriComuni: [String: Int]
    let percentualeValidita: Double
    
    var erroriOrdinatiPerFrequenza: [(errore: String, count: Int)] {
        erroriComuni.sorted { $0.value > $1.value }.map { (errore: $0.key, count: $0.value) }
    }
    
    var erroresPiuComune: String? {
        erroriOrdinatiPerFrequenza.first?.errore
    }
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
            let readmeContent = creaContenutoReadme(defunto)
            let readmeURL = cartellaDefunto.appendingPathComponent("README.txt")
            try readmeContent.write(to: readmeURL, atomically: true, encoding: .utf8)
            
            // ✅ AGGIUNTO: Crea file JSON con dati defunto
            let jsonData = try JSONEncoder().encode(defunto)
            let jsonURL = cartellaDefunto.appendingPathComponent("dati_defunto.json")
            try jsonData.write(to: jsonURL)
            
            print("✅ Cartella creata: \(cartellaDefunto.path)")
            return cartellaDefunto
            
        } catch {
            print("❌ Errore nella creazione della cartella: \(error)")
            return nil
        }
    }
    
    // ✅ AGGIUNTO: Metodo separato per contenuto README
    private static func creaContenutoReadme(_ defunto: PersonaDefunta) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "it_IT")
        
        return """
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
        Luogo Decesso: \(defunto.luogoDecesso.rawValue)
        Tipo Sepoltura: \(defunto.tipoSepoltura.rawValue)
        
        FAMILIARE RESPONSABILE:
        \(defunto.familiareRichiedente.nomeCompleto)
        Parentela: \(defunto.familiareRichiedente.parentela.rawValue)
        Telefono: \(defunto.familiareRichiedente.telefono)
        Email: \(defunto.familiareRichiedente.email ?? "Non specificata")
        Indirizzo: \(defunto.familiareRichiedente.indirizzoCompleto)
        
        \(defunto.note?.isEmpty == false ? "\nNOTE:\n\(defunto.note!)" : "")
        
        =====================================
        Generato automaticamente da FunerApp
        Data: \(Date().formatted(.dateTime))
        =====================================
        """
    }
    
    // ✅ AGGIUNTO: Apri cartella nel Finder
    static func apriCartellaDefunto(_ defunto: PersonaDefunta) -> Bool {
        guard let cartellaURL = trovaCartellaDefunto(defunto) else {
            return false
        }
        
        NSWorkspace.shared.open(cartellaURL)
        return true
    }
    
    // ✅ AGGIUNTO: Trova cartella esistente
    static func trovaCartellaDefunto(_ defunto: PersonaDefunta) -> URL? {
        let fileManager = FileManager.default
        
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let basePath = documentsPath
            .appendingPathComponent("GestioneFunebre")
            .appendingPathComponent("Defunti")
        
        let nomeCartella = "\(defunto.numeroCartella) - \(defunto.nomeCompleto)"
        let cartellaDefunto = basePath.appendingPathComponent(nomeCartella)
        
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: cartellaDefunto.path, isDirectory: &isDirectory) && isDirectory.boolValue {
            return cartellaDefunto
        }
        
        return nil
    }
    
    // ✅ AGGIUNTO: Verifica se cartella esiste
    static func cartellaEsiste(_ defunto: PersonaDefunta) -> Bool {
        return trovaCartellaDefunto(defunto) != nil
    }
}

// MARK: - ✅ Utilities per export dati
struct FamiliareExportUtilities {
    
    static func esportaCSVFamiliari(_ familiari: [FamiliareResponsabile]) -> String {
        let header = "Nome,Cognome,Parentela,Telefono,Email,Città,CAP,Età"
        
        let rows = familiari.map { familiare in
            let nome = familiare.nome.replacingOccurrences(of: ",", with: ";")
            let cognome = familiare.cognome.replacingOccurrences(of: ",", with: ";")
            let parentela = familiare.parentela.rawValue.replacingOccurrences(of: ",", with: ";")
            let telefono = familiare.telefono
            let email = familiare.email ?? ""
            let citta = familiare.citta.replacingOccurrences(of: ",", with: ";")
            let cap = familiare.cap
            let eta = String(familiare.eta)
            
            return "\(nome),\(cognome),\(parentela),\(telefono),\(email),\(citta),\(cap),\(eta)"
        }
        
        return ([header] + rows).joined(separator: "\n")
    }
    
    static func esportaRapportoValidazione(_ rapporto: RapportoValidazione) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "it_IT")
        
        var contenuto = """
        RAPPORTO VALIDAZIONE DEFUNTI
        ============================
        
        Data Generazione: \(dateFormatter.string(from: Date()))
        
        STATISTICHE GENERALI:
        - Totale Defunti: \(rapporto.totaleDefunti)
        - Defunti Validi: \(rapporto.defuntiValidi)
        - Defunti con Errori: \(rapporto.defuntiConErrori)
        - Percentuale Validità: \(String(format: "%.1f", rapporto.percentualeValidita))%
        
        """
        
        if !rapporto.erroriComuni.isEmpty {
            contenuto += """
            ERRORI PIÙ COMUNI:
            """
            
            for (errore, count) in rapporto.erroriOrdinatiPerFrequenza.prefix(10) {
                let percentuale = Double(count) / Double(rapporto.totaleDefunti) * 100
                contenuto += """
                \n- \(errore): \(count) casi (\(String(format: "%.1f", percentuale))%)
                """
            }
        }
        
        contenuto += """
        
        ============================
        Generato da FunerApp
        ============================
        """
        
        return contenuto
    }
}

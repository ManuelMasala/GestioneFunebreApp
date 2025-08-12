//
//  MokaDataHelper.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 21/07/25.
//

import SwiftUI
import Foundation

// MARK: - Mock Data Helper
struct MockDataHelper {
    
    // MARK: - Populate Manager with Sample Data
    static func populateManagerIfEmpty(_ manager: ManagerGestioneDefunti) {
        // Se il manager è vuoto, aggiungi dati di esempio
        if manager.defunti.isEmpty {
            let sampleDefunti = createSampleDefunti()
            sampleDefunti.forEach { defunto in
                manager.aggiungiDefunto(defunto)
            }
        }
    }
    
    // MARK: - Create Sample Defunti
    private static func createSampleDefunti() -> [PersonaDefunta] {
        var defunti: [PersonaDefunta] = []
        
        // Defunto 1 - Mario Rossi
        var defunto1 = PersonaDefunta(
            numeroCartella: "001/2024",
            nome: "MARIO",
            cognome: "ROSSI",
            sesso: .maschio,
            dataNascita: Calendar.current.date(byAdding: .year, value: -75, to: Date()) ?? Date(),
            luogoNascita: "CAGLIARI",
            indirizzoResidenza: "Via Roma, 123",
            cittaResidenza: "CAGLIARI",
            capResidenza: "09100",
            statoCivile: .coniugato,
            paternita: "GIUSEPPE ROSSI",
            maternita: "MARIA BIANCHI",
            dataDecesso: Date(),
            oraDecesso: "14:30",
            luogoDecesso: .ospedale,
            tipoSepoltura: .tumulazione,
            luogoSepoltura: "CIMITERO SAN MICHELE",
            operatoreCorrente: "Sistema Demo"
        )
        
        // Setup familiare
        defunto1.familiareRichiedente.nome = "GIULIA"
        defunto1.familiareRichiedente.cognome = "ROSSI"
        defunto1.familiareRichiedente.parentela = .figlio
        defunto1.familiareRichiedente.telefono = "070 123456"
        defunto1.familiareRichiedente.email = "giulia.rossi@email.com"
        defunto1.familiareRichiedente.indirizzo = "Via Roma, 123"
        defunto1.familiareRichiedente.citta = "CAGLIARI"
        defunto1.familiareRichiedente.cap = "09100"
        defunto1.codiceFiscale = "RSSMRA49A01B354X"
        defunto1.nomeConiuge = "ANNA VERDI"
        defunto1.nomeOspedale = "Ospedale Brotzu"
        
        defunti.append(defunto1)
        
        // Defunto 2 - Anna Bianchi
        var defunto2 = PersonaDefunta(
            numeroCartella: "002/2024",
            nome: "ANNA",
            cognome: "BIANCHI",
            sesso: .femmina,
            dataNascita: Calendar.current.date(byAdding: .year, value: -82, to: Date()) ?? Date(),
            luogoNascita: "QUARTU SANT'ELENA",
            indirizzoResidenza: "Via Dante, 45",
            cittaResidenza: "QUARTU SANT'ELENA",
            capResidenza: "09045",
            statoCivile: .vedovo,
            paternita: "ANTONIO BIANCHI",
            maternita: "FRANCESCA SERRA",
            dataDecesso: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            oraDecesso: "08:15",
            luogoDecesso: .abitazione,
            tipoSepoltura: .cremazione,
            luogoSepoltura: "CREMATORIO COMUNALE",
            operatoreCorrente: "Sistema Demo"
        )
        
        defunto2.familiareRichiedente.nome = "MARCO"
        defunto2.familiareRichiedente.cognome = "BIANCHI"
        defunto2.familiareRichiedente.parentela = .figlio
        defunto2.familiareRichiedente.telefono = "070 987654"
        defunto2.familiareRichiedente.email = "marco.bianchi@email.com"
        defunto2.familiareRichiedente.indirizzo = "Via Nazionale, 78"
        defunto2.familiareRichiedente.citta = "CAGLIARI"
        defunto2.familiareRichiedente.cap = "09100"
        defunto2.codiceFiscale = "BNCNNA42B41G149Y"
        defunto2.nomeConiuge = "PIETRO LAI"
        
        defunti.append(defunto2)
        
        // Defunto 3 - Francesco Verdi
        var defunto3 = PersonaDefunta(
            numeroCartella: "003/2024",
            nome: "FRANCESCO",
            cognome: "VERDI",
            sesso: .maschio,
            dataNascita: Calendar.current.date(byAdding: .year, value: -68, to: Date()) ?? Date(),
            luogoNascita: "ASSEMINI",
            indirizzoResidenza: "Via Gramsci, 12",
            cittaResidenza: "ASSEMINI",
            capResidenza: "09032",
            statoCivile: .celibe,
            paternita: "LUIGI VERDI",
            maternita: "ROSA MELIS",
            dataDecesso: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            oraDecesso: "22:45",
            luogoDecesso: .rsa,
            tipoSepoltura: .tumulazione,
            luogoSepoltura: "CIMITERO COMUNALE ASSEMINI",
            operatoreCorrente: "Sistema Demo"
        )
        
        defunto3.familiareRichiedente.nome = "SARA"
        defunto3.familiareRichiedente.cognome = "VERDI"
        defunto3.familiareRichiedente.parentela = .fratello
        defunto3.familiareRichiedente.telefono = "070 456789"
        defunto3.familiareRichiedente.indirizzo = "Via Sardegna, 234"
        defunto3.familiareRichiedente.citta = "CAGLIARI"
        defunto3.familiareRichiedente.cap = "09100"
        defunto3.codiceFiscale = "VRDFNC56C12A326W"
        defunto3.nomeOspedale = "Casa di Cura Santa Barbara"
        
        defunti.append(defunto3)
        
        // Defunto 4 - Maria Carta
        var defunto4 = PersonaDefunta(
            numeroCartella: "004/2024",
            nome: "MARIA",
            cognome: "CARTA",
            sesso: .femmina,
            dataNascita: Calendar.current.date(byAdding: .year, value: -89, to: Date()) ?? Date(),
            luogoNascita: "SELARGIUS",
            indirizzoResidenza: "Via Piave, 67",
            cittaResidenza: "SELARGIUS",
            capResidenza: "09047",
            statoCivile: .vedovo,
            paternita: "GIOVANNI CARTA",
            maternita: "ANTONIETTA MURGIA",
            dataDecesso: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            oraDecesso: "16:20",
            luogoDecesso: .ospedale,
            tipoSepoltura: .inumazione,
            luogoSepoltura: "CIMITERO SELARGIUS",
            operatoreCorrente: "Sistema Demo"
        )
        
        defunto4.familiareRichiedente.nome = "PAOLO"
        defunto4.familiareRichiedente.cognome = "CARTA"
        defunto4.familiareRichiedente.parentela = .figlio
        defunto4.familiareRichiedente.telefono = "070 321654"
        defunto4.familiareRichiedente.email = "paolo.carta@email.com"
        defunto4.familiareRichiedente.indirizzo = "Via Trieste, 89"
        defunto4.familiareRichiedente.citta = "CAGLIARI"
        defunto4.familiareRichiedente.cap = "09100"
        defunto4.codiceFiscale = "CRTMRA35D62H856Z"
        defunto4.nomeConiuge = "SALVATORE PINNA"
        defunto4.nomeOspedale = "Ospedale Santissima Trinità"
        
        defunti.append(defunto4)
        
        // Defunto 5 - Giuseppe Piras
        var defunto5 = PersonaDefunta(
            numeroCartella: "005/2024",
            nome: "GIUSEPPE",
            cognome: "PIRAS",
            sesso: .maschio,
            dataNascita: Calendar.current.date(byAdding: .year, value: -91, to: Date()) ?? Date(),
            luogoNascita: "MONSERRATO",
            indirizzoResidenza: "Via Kennedy, 156",
            cittaResidenza: "MONSERRATO",
            capResidenza: "09042",
            statoCivile: .coniugato,
            paternita: "EFISIO PIRAS",
            maternita: "GIUSEPPINA LOI",
            dataDecesso: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            oraDecesso: "05:30",
            luogoDecesso: .abitazione,
            tipoSepoltura: .cremazione,
            luogoSepoltura: "CREMATORIO COMUNALE",
            operatoreCorrente: "Sistema Demo"
        )
        
        defunto5.familiareRichiedente.nome = "DANIELA"
        defunto5.familiareRichiedente.cognome = "PIRAS"
        defunto5.familiareRichiedente.parentela = .coniuge
        defunto5.familiareRichiedente.telefono = "070 789123"
        defunto5.familiareRichiedente.email = "daniela.piras@email.com"
        defunto5.familiareRichiedente.indirizzo = "Via Kennedy, 156"
        defunto5.familiareRichiedente.citta = "MONSERRATO"
        defunto5.familiareRichiedente.cap = "09042"
        defunto5.codiceFiscale = "PRSGPP33E15F979A"
        defunto5.nomeConiuge = "DANIELA ORRÙ"
        
        defunti.append(defunto5)
        
        return defunti
    }
}

// MARK: - Extension per Manager
extension ManagerGestioneDefunti {
    func loadSampleDataIfEmpty() {
        MockDataHelper.populateManagerIfEmpty(self)
    }
}

//
//  ManagerGestioneDefunti.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 10/07/25.
//

import SwiftUI
import Foundation

// MARK: - Manager per la Gestione Defunti
@MainActor
class ManagerGestioneDefunti: ObservableObject {
    @Published var defunti: [PersonaDefunta] = []
    @Published var prossimoNumero: Int = 1
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let defuntiKey = "defunti_salvati_v4"
    private let prossimoNumeroKey = "prossimo_numero_cartella_v4"
    
    init() {
        caricaDefunti()
        aggiornaProssimoNumero()
    }
    
    var defuntiFiltrati: [PersonaDefunta] {
        if searchText.isEmpty {
            return defunti.sorted { $0.dataCreazione > $1.dataCreazione }
        }
        
        return defunti.filter { defunto in
            defunto.nome.localizedCaseInsensitiveContains(searchText) ||
            defunto.cognome.localizedCaseInsensitiveContains(searchText) ||
            defunto.numeroCartella.contains(searchText) ||
            defunto.codiceFiscale.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.dataCreazione > $1.dataCreazione }
    }
    
    func generaNuovoNumeroCartella() -> String {
        let numero = String(format: "%04d", prossimoNumero)
        prossimoNumero += 1
        salvaProssimoNumero()
        return numero
    }
    
    func aggiungiDefunto(_ defunto: PersonaDefunta) {
        defunti.append(defunto)
        salvaDefunti()
        errorMessage = nil
    }
    
    func aggiornaDefunto(_ defunto: PersonaDefunta) {
        if let index = defunti.firstIndex(where: { $0.id == defunto.id }) {
            var defuntoAggiornato = defunto
            defuntoAggiornato.dataUltimaModifica = Date()
            defunti[index] = defuntoAggiornato
            salvaDefunti()
        }
    }
    
    func eliminaDefunto(_ defunto: PersonaDefunta) {
        defunti.removeAll { $0.id == defunto.id }
        salvaDefunti()
    }
    
    func defunto(conId id: UUID) -> PersonaDefunta? {
        return defunti.first { $0.id == id }
    }
    
    // MARK: - Statistiche
    
    func getStatistiche() -> (totale: Int, questoMese: Int, maschi: Int, femmine: Int) {
        let calendario = Calendar.current
        let ora = Date()
        
        let questoMese = defunti.filter { defunto in
            calendario.isDate(defunto.dataCreazione, equalTo: ora, toGranularity: .month)
        }.count
        
        let maschi = defunti.filter { $0.sesso == .maschio }.count
        let femmine = defunti.filter { $0.sesso == .femmina }.count
        
        return (defunti.count, questoMese, maschi, femmine)
    }
    
    func getDefuntiPerMese() -> [String: Int] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        let grouped = Dictionary(grouping: defunti) { defunto in
            formatter.string(from: defunto.dataDecesso)
        }
        
        return grouped.mapValues { $0.count }
    }
    
    func getEtaMedia() -> Double {
        guard !defunti.isEmpty else { return 0 }
        let totaleEta = defunti.reduce(0) { $0 + $1.eta }
        return Double(totaleEta) / Double(defunti.count)
    }
    
    // MARK: - Persistenza
    
    private func caricaDefunti() {
        if let data = userDefaults.data(forKey: defuntiKey),
           let defuntiCaricati = try? JSONDecoder().decode([PersonaDefunta].self, from: data) {
            self.defunti = defuntiCaricati
        }
    }
    
    private func salvaDefunti() {
        do {
            let data = try JSONEncoder().encode(defunti)
            userDefaults.set(data, forKey: defuntiKey)
        } catch {
            errorMessage = "Errore nel salvataggio: \(error.localizedDescription)"
        }
    }
    
    private func aggiornaProssimoNumero() {
        let numeroSalvato = userDefaults.integer(forKey: prossimoNumeroKey)
        if numeroSalvato > 0 {
            prossimoNumero = numeroSalvato
        } else if let ultimoNumero = defunti.compactMap({ Int($0.numeroCartella) }).max() {
            prossimoNumero = ultimoNumero + 1
        }
    }
    
    private func salvaProssimoNumero() {
        userDefaults.set(prossimoNumero, forKey: prossimoNumeroKey)
    }
    
    // MARK: - Utilità per l'export
    
    func esportaCSV() -> String {
        return ExportUtilities.exportToCSV(defunti: defunti)
    }
    
    func esportaTXT() -> String {
        return ExportUtilities.exportToTXT(defunti: defunti)
    }
    
    // MARK: - Validazione
    
    func validaDefunto(_ defunto: PersonaDefunta) -> [String] {
        var errori: [String] = []
        
        if defunto.nome.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il nome è obbligatorio")
        }
        
        if defunto.cognome.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il cognome è obbligatorio")
        }
        
        if defunto.luogoNascita.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il luogo di nascita è obbligatorio")
        }
        
        if defunto.oraDecesso.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("L'ora del decesso è obbligatoria")
        }
        
        if defunto.documentoRiconoscimento.numero.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il numero del documento è obbligatorio")
        }
        
        if defunto.luogoSepoltura.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il luogo di sepoltura è obbligatorio")
        }
        
        if defunto.familiareRichiedente.nome.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il nome del familiare responsabile è obbligatorio")
        }
        
        if defunto.familiareRichiedente.telefono.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            errori.append("Il telefono del familiare responsabile è obbligatorio")
        }
        
        return errori
    }
    
    func esisteNumeroCartella(_ numero: String) -> Bool {
        return defunti.contains { $0.numeroCartella == numero }
    }
}

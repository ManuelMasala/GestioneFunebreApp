//
//  ManagerGestioneDefunti.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 10/07/25.
//

import Foundation
import SwiftUI

class ManagerGestioneDefunti: ObservableObject {
    @Published var defunti: [PersonaDefunta] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    var defuntiFiltrati: [PersonaDefunta] {
        if searchText.isEmpty {
            return defunti.sorted { $0.dataCreazione > $1.dataCreazione }
        } else {
            return defunti.filter { defunto in
                defunto.nome.localizedCaseInsensitiveContains(searchText) ||
                defunto.cognome.localizedCaseInsensitiveContains(searchText) ||
                defunto.numeroCartella.localizedCaseInsensitiveContains(searchText) ||
                defunto.codiceFiscale.localizedCaseInsensitiveContains(searchText) ||
                defunto.luogoNascita.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dataCreazione > $1.dataCreazione }
        }
    }
    
    init() {
        loadDefunti()
        // Genera dati di esempio se vuoto
        if defunti.isEmpty {
            generateSampleData()
        }
    }
    
    // MARK: - Core Functions
    
    func generaNuovoNumeroCartella() -> String {
        let year = Calendar.current.component(.year, from: Date())
        let nextNumber = (defunti.count + 1)
        return "\(year)-\(String(format: "%04d", nextNumber))"
    }
    
    func aggiungiDefunto(_ defunto: PersonaDefunta) {
        var nuovoDefunto = defunto
        if nuovoDefunto.numeroCartella.isEmpty {
            nuovoDefunto.numeroCartella = generaNuovoNumeroCartella()
        }
        defunti.append(nuovoDefunto)
        saveDefunti()
    }
    
    func eliminaDefunto(_ defunto: PersonaDefunta) {
        defunti.removeAll { $0.id == defunto.id }
        saveDefunti()
    }
    
    func aggiornaDefunto(_ defunto: PersonaDefunta) {
        if let index = defunti.firstIndex(where: { $0.id == defunto.id }) {
            var defuntoAggiornato = defunto
            defuntoAggiornato.dataUltimaModifica = Date()
            defunti[index] = defuntoAggiornato
            saveDefunti()
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveDefunti() {
        isLoading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 0.5)
            
            DispatchQueue.main.async {
                self?.isLoading = false
                print("💾 Salvati \(self?.defunti.count ?? 0) defunti")
            }
        }
    }
    
    private func loadDefunti() {
        isLoading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            Thread.sleep(forTimeInterval: 0.3)
            
            DispatchQueue.main.async {
                self?.isLoading = false
                print("📂 Caricati \(self?.defunti.count ?? 0) defunti")
            }
        }
    }
    
    // MARK: - Search and Filter
    
    func cercaDefunti(termine: String) {
        searchText = termine
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func filtroDefuntiPerData(da: Date, a: Date) -> [PersonaDefunta] {
        return defunti.filter { defunto in
            defunto.dataDecesso >= da && defunto.dataDecesso <= a
        }
    }
    
    func filtroDefuntiPerTipoSepoltura(_ tipo: TipologiaSepoltura) -> [PersonaDefunta] {
        return defunti.filter { $0.tipoSepoltura == tipo }
    }
    
    // MARK: - Export Functions
    
    func esportaCSV() throws -> URL {
        let fileName = "defunti_export_\(Date().timeIntervalSince1970).csv"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        var csvContent = "Nome,Cognome,Codice Fiscale,Data Nascita,Data Decesso,Luogo Nascita,Tipo Sepoltura,Telefono Familiare\n"
        
        for defunto in defunti {
            let row = [
                defunto.nome,
                defunto.cognome,
                defunto.codiceFiscale,
                defunto.dataNascitaFormattata,
                defunto.dataDecesoFormattata,
                defunto.luogoNascita,
                defunto.tipoSepoltura.rawValue,
                defunto.familiareRichiedente.telefono
            ].joined(separator: ",")
            
            csvContent += row + "\n"
        }
        
        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    // MARK: - Sample Data Generation
    
    private func generateSampleData() {
        let sampleDefunti: [PersonaDefunta] = [
            createSampleDefunto(nome: "Mario", cognome: "Rossi", eta: 75),
            createSampleDefunto(nome: "Anna", cognome: "Verdi", eta: 68),
            createSampleDefunto(nome: "Giuseppe", cognome: "Bianchi", eta: 82),
            createSampleDefunto(nome: "Maria", cognome: "Neri", eta: 71),
            createSampleDefunto(nome: "Francesco", cognome: "Ferrari", eta: 79)
        ]
        
        defunti.append(contentsOf: sampleDefunti)
    }
    
    private func createSampleDefunto(nome: String, cognome: String, eta: Int) -> PersonaDefunta {
        let birthDate = Calendar.current.date(byAdding: .year, value: -eta, to: Date())!
        let deathDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...30), to: Date())!
        
        var defunto = PersonaDefunta(
            numeroCartella: generaNuovoNumeroCartella(),
            nome: nome,
            cognome: cognome,
            operatoreCorrente: "Sistema"
        )
        
        defunto.dataNascita = birthDate
        defunto.dataDecesso = deathDate
        defunto.luogoNascita = ["Roma", "Milano", "Napoli", "Torino", "Palermo"].randomElement()!
        defunto.sesso = Bool.random() ? .maschio : .femmina
        
        // Usa il CalcolatoreCodiceFiscaleItaliano esterno (definito nel file separato)
        defunto.codiceFiscale = CalcolatoreCodiceFiscaleItaliano.calcola(
            nome: nome,
            cognome: cognome,
            dataNascita: birthDate,
            luogoNascita: defunto.luogoNascita,
            sesso: defunto.sesso
        )
        
        defunto.oraDecesso = String(format: "%02d:%02d", Int.random(in: 0...23), Int.random(in: 0...59))
        defunto.tipoSepoltura = TipologiaSepoltura.allCases.randomElement()!
        defunto.luogoSepoltura = "Cimitero Comunale"
        
        // Familiare
        defunto.familiareRichiedente.nome = ["Marco", "Luca", "Andrea", "Giulia", "Sara"].randomElement()!
        defunto.familiareRichiedente.cognome = cognome
        defunto.familiareRichiedente.telefono = "+39 33\(Int.random(in: 10...99)) \(Int.random(in: 100...999)) \(Int.random(in: 1000...9999))"
        defunto.familiareRichiedente.parentela = .figlio
        
        if Bool.random() {
            defunto.familiareRichiedente.email = "\(defunto.familiareRichiedente.nome.lowercased())@email.com"
        }
        
        return defunto
    }
}

// MARK: - Supporting Types (versione semplificata)

struct DefuntiStatistics {
    let totalDefunti: Int
    let cremazioni: Int
    let tumulazioni: Int
    let inumazioni: Int
    let defuntiOggi: Int
    let defuntiSettimana: Int
    let etaMedia: Double
    let qualitaDatiPercentuale: Int
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
}

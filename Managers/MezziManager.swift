//
//  MezziManager.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 16/07/25.
//

import Foundation
import SwiftUI

// MARK: - MezziManager
class MezziManager: ObservableObject {
    @Published var mezzi: [Mezzo] = []
    
    init() {
        caricaMezziDefault()
    }
    
    // MARK: - Caricamento Dati Default
    private func caricaMezziDefault() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        mezzi = [
            Mezzo(
                targa: "GY840MC",
                modello: "Classe E",
                marca: "Mercedes",
                stato: .disponibile,
                km: "45.230",
                dataRevisione: formatter.date(from: "15/12/2024") ?? Date()
            ),
            Mezzo(
                targa: "FP509KN",
                modello: "Ghibli",
                marca: "Maserati",
                stato: .disponibile,
                km: "32.890",
                dataRevisione: formatter.date(from: "22/01/2025") ?? Date()
            ),
            Mezzo(
                targa: "GC002KN",
                modello: "Ghibli",
                marca: "Maserati",
                stato: .manutenzione,
                km: "28.450",
                dataRevisione: formatter.date(from: "08/03/2025") ?? Date()
            ),
            Mezzo(
                targa: "GL798XM",
                modello: "Ghibli",
                marca: "Maserati",
                stato: .inUso,
                km: "15.100",
                dataRevisione: formatter.date(from: "30/04/2025") ?? Date()
            ),
            Mezzo(
                targa: "GV589TV",
                modello: "Classe CLS",
                marca: "Mercedes",
                stato: .disponibile,
                km: "67.230",
                dataRevisione: formatter.date(from: "12/06/2025") ?? Date()
            ),
            Mezzo(
                targa: "FY559DJ",
                modello: "XF",
                marca: "Jaguar",
                stato: .disponibile,
                km: "23.890",
                dataRevisione: formatter.date(from: "18/07/2025") ?? Date()
            )
        ]
        
        // Aggiungi alcune manutenzioni di esempio
        aggiungiManutenzioniEsempio()
    }
    
    // MARK: - Gestione Mezzi
    func aggiungiMezzo(_ mezzo: Mezzo) {
        mezzi.append(mezzo)
        salvaDati()
    }
    
    func aggiornaMezzo(_ mezzoAggiornato: Mezzo) {
        if let index = mezzi.firstIndex(where: { $0.id == mezzoAggiornato.id }) {
            mezzi[index] = mezzoAggiornato
            salvaDati()
        }
    }
    
    func eliminaMezzo(_ mezzo: Mezzo) {
        mezzi.removeAll { $0.id == mezzo.id }
        salvaDati()
    }
    
    // MARK: - Gestione Manutenzioni
    func aggiungiManutenzione(_ manutenzione: Manutenzione, alMezzo mezzoId: UUID) {
        if let index = mezzi.firstIndex(where: { $0.id == mezzoId }) {
            mezzi[index].manutenzioni.append(manutenzione)
            salvaDati()
        }
    }
    
    func aggiornaManutenzione(_ manutenzione: Manutenzione, nelMezzo mezzoId: UUID) {
        if let mezzoIndex = mezzi.firstIndex(where: { $0.id == mezzoId }),
           let manutenzioneIndex = mezzi[mezzoIndex].manutenzioni.firstIndex(where: { $0.id == manutenzione.id }) {
            mezzi[mezzoIndex].manutenzioni[manutenzioneIndex] = manutenzione
            salvaDati()
        }
    }
    
    func eliminaManutenzione(_ manutenzione: Manutenzione, dalMezzo mezzoId: UUID) {
        if let mezzoIndex = mezzi.firstIndex(where: { $0.id == mezzoId }) {
            mezzi[mezzoIndex].manutenzioni.removeAll { $0.id == manutenzione.id }
            salvaDati()
        }
    }
    
    // MARK: - Filtri e Ricerche
    func mezziFiltrati(per stato: StatoMezzo? = nil, tipo: TipoProprietaMezzo? = nil) -> [Mezzo] {
        var risultato = mezzi
        
        if let stato = stato {
            risultato = risultato.filter { $0.stato == stato }
        }
        
        if let tipo = tipo {
            risultato = risultato.filter { $0.tipoProprietà == tipo }
        }
        
        return risultato
    }
    
    func mezziConRevisioneScaduta() -> [Mezzo] {
        return mezzi.filter { $0.isRevisioneScaduta }
    }
    
    func mezziConNoleggioScaduto() -> [Mezzo] {
        return mezzi.filter { $0.isScadutoNoleggio }
    }
    
    func mezziCheMancanoManutenzione(giorni: Int = 180) -> [Mezzo] {
        let dataLimite = Calendar.current.date(byAdding: .day, value: -giorni, to: Date()) ?? Date()
        return mezzi.filter { mezzo in
            guard let ultimaManutenzione = mezzo.ultimaManutenzione else { return true }
            return ultimaManutenzione.data < dataLimite
        }
    }
    
    // MARK: - Statistiche
    var statistiche: MezziStatistiche {
        let totale = mezzi.count
        let disponibili = mezzi.filter { $0.stato == .disponibile }.count
        let inUso = mezzi.filter { $0.stato == .inUso }.count
        let inManutenzione = mezzi.filter { $0.stato == .manutenzione }.count
        let fuoriServizio = mezzi.filter { $0.stato == .fuoriServizio }.count
        
        let costoTotaleManutenzioni = mezzi.reduce(0) { $0 + $1.costoTotaleManutenzioni }
        let numeroTotaleManutenzioni = mezzi.reduce(0) { $0 + $1.manutenzioni.count }
        
        let revisioniScadute = mezziConRevisioneScaduta().count
        let noleggiScaduti = mezziConNoleggioScaduto().count
        
        return MezziStatistiche(
            totale: totale,
            disponibili: disponibili,
            inUso: inUso,
            inManutenzione: inManutenzione,
            fuoriServizio: fuoriServizio,
            costoTotaleManutenzioni: costoTotaleManutenzioni,
            numeroTotaleManutenzioni: numeroTotaleManutenzioni,
            revisioniScadute: revisioniScadute,
            noleggiScaduti: noleggiScaduti
        )
    }
    
    // MARK: - Persistenza Dati (placeholder)
    private func salvaDati() {
        // Implementa il salvataggio su UserDefaults, Core Data, o altro
        print("Salvando dati mezzi...")
    }
    
    private func caricaDati() {
        // Implementa il caricamento dati
        print("Caricando dati mezzi...")
    }
    
    // MARK: - Dati di Esempio
    private func aggiungiManutenzioniEsempio() {
        // Aggiungi alcune manutenzioni di esempio al primo mezzo
        if !mezzi.isEmpty {
            let manutenzioni = [
                Manutenzione(
                    data: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                    tipo: .tagliando,
                    descrizione: "Tagliando 50.000 km",
                    costo: 450.0,
                    officina: "Officina Mercedes Cagliari",
                    note: "Cambio olio e filtri"
                ),
                Manutenzione(
                    data: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
                    tipo: .riparazione,
                    descrizione: "Sostituzione pastiglie freni",
                    costo: 280.0,
                    officina: "Officina Mercedes Cagliari",
                    note: "Freni anteriori usurati"
                )
            ]
            
            mezzi[0].manutenzioni.append(contentsOf: manutenzioni)
        }
    }
}

// MARK: - Struttura Statistiche
struct MezziStatistiche {
    let totale: Int
    let disponibili: Int
    let inUso: Int
    let inManutenzione: Int
    let fuoriServizio: Int
    let costoTotaleManutenzioni: Double
    let numeroTotaleManutenzioni: Int
    let revisioniScadute: Int
    let noleggiScaduti: Int
    
    var percentualeDisponibili: Double {
        totale > 0 ? Double(disponibili) / Double(totale) * 100 : 0
    }
    
    var costoMedioManutenzione: Double {
        numeroTotaleManutenzioni > 0 ? costoTotaleManutenzioni / Double(numeroTotaleManutenzioni) : 0
    }
}

//
//  MezzoHelper.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import SwiftUI
import Foundation

// MARK: - MezzoHelper
// Posizionare in: Utilities/MezzoHelper.swift
struct MezzoHelper {
    
    // MARK: - Status and Colors
    static func coloreStato(for mezzo: Mezzo) -> Color {
        return mezzo.stato.color
    }
    
    static func descrizioneStato(for mezzo: Mezzo) -> String {
        return mezzo.stato.rawValue
    }
    
    static func iconaStato(for mezzo: Mezzo) -> String {
        switch mezzo.stato {
        case .disponibile: return "checkmark.circle.fill"
        case .inUso: return "car.fill"
        case .manutenzione: return "wrench.fill"
        case .fuoriServizio: return "xmark.circle.fill"
        }
    }
    
    // MARK: - Validation Checks
    static func isRevisioneScaduta(for mezzo: Mezzo) -> Bool {
        return mezzo.isRevisioneScaduta
    }
    
    static func isNoleggioScaduto(for mezzo: Mezzo) -> Bool {
        return mezzo.isScadutoNoleggio
    }
    
    static func giorniAllaScadenzaRevisione(for mezzo: Mezzo) -> Int {
        let giorni = Calendar.current.dateComponents([.day], from: Date(), to: mezzo.dataRevisione).day ?? 0
        return giorni
    }
    
    static func isRevisioneInScadenza(for mezzo: Mezzo, entroGiorni giorni: Int = 30) -> Bool {
        let giorniMancanti = giorniAllaScadenzaRevisione(for: mezzo)
        return giorniMancanti <= giorni && giorniMancanti > 0
    }
    
    // MARK: - Display Formatting
    static func nomeCompleto(for mezzo: Mezzo) -> String {
        return "\(mezzo.marca) \(mezzo.modello)"
    }
    
    static func targaFormattata(for mezzo: Mezzo) -> String {
        return mezzo.targa.uppercased()
    }
    
    static func kmFormattato(for mezzo: Mezzo) -> String {
        return mezzo.kmFormatted
    }
    
    static func dataRevisioneFormattata(for mezzo: Mezzo) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: mezzo.dataRevisione)
    }
    
    static func dataRevisioneBreve(for mezzo: Mezzo) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: mezzo.dataRevisione)
    }
    
    // MARK: - Property Type Helpers
    static func tipoProprieta(for mezzo: Mezzo) -> String {
        return mezzo.tipoProprietà.rawValue
    }
    
    static func coloreTipoProprietà(for mezzo: Mezzo) -> Color {
        switch mezzo.tipoProprietà {
        case .proprio: return .green
        case .noleggio: return .blue
        }
    }
    
    static func iconaTipoProprietà(for mezzo: Mezzo) -> String {
        switch mezzo.tipoProprietà {
        case .proprio: return "house.fill"
        case .noleggio: return "calendar.badge.clock"
        }
    }
    
    // MARK: - Maintenance Helpers
    static func ultimaManutenzioneDescrizione(for mezzo: Mezzo) -> String {
        guard let ultima = mezzo.ultimaManutenzione else {
            return "Nessuna manutenzione registrata"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        
        return "\(ultima.tipo.rawValue) - \(formatter.string(from: ultima.data))"
    }
    
    static func costoTotaleManutenzioniFormattato(for mezzo: Mezzo) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "it_IT")
        
        return formatter.string(from: NSNumber(value: mezzo.costoTotaleManutenzioni)) ?? "€0,00"
    }
    
    static func numeroManutenzioni(for mezzo: Mezzo) -> Int {
        return mezzo.manutenzioni.count
    }
    
    static func needsMaintenance(mezzo: Mezzo) -> Bool {
        return mezzo.needsMaintenance()
    }
    
    static func nextMaintenanceDate(for mezzo: Mezzo) -> String {
        let date = mezzo.nextMaintenanceDate()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    // MARK: - Status Indicators
    static func statoIndicator(for mezzo: Mezzo) -> (color: Color, icon: String, text: String) {
        if isRevisioneScaduta(for: mezzo) {
            return (.red, "exclamationmark.triangle.fill", "Revisione Scaduta")
        }
        
        if isRevisioneInScadenza(for: mezzo) {
            return (.orange, "clock.fill", "Revisione in Scadenza")
        }
        
        if mezzo.tipoProprietà == .noleggio && isNoleggioScaduto(for: mezzo) {
            return (.red, "exclamationmark.triangle.fill", "Noleggio Scaduto")
        }
        
        if needsMaintenance(mezzo: mezzo) {
            return (.orange, "wrench.fill", "Manutenzione Necessaria")
        }
        
        switch mezzo.stato {
        case .disponibile:
            return (.green, "checkmark.circle.fill", "Disponibile")
        case .inUso:
            return (.blue, "car.fill", "In Uso")
        case .manutenzione:
            return (.orange, "wrench.fill", "In Manutenzione")
        case .fuoriServizio:
            return (.red, "xmark.circle.fill", "Fuori Servizio")
        }
    }
    
    // MARK: - AI Compatibility
    static func aiQualityScore(for mezzo: Mezzo) -> Int {
        return mezzo.aiQualityScore
    }
    
    static func isAIRecommended(mezzo: Mezzo) -> Bool {
        return mezzo.isAIRecommended
    }
    
    static func aiStatusDescription(for mezzo: Mezzo) -> String {
        return mezzo.aiStatusDescription
    }
    
    static func aiSuggestions(for mezzo: Mezzo) -> [String] {
        return mezzo.aiSuggestions
    }
    
    // MARK: - Filtering and Search
    static func matchesSearch(_ mezzo: Mezzo, searchText: String) -> Bool {
        if searchText.isEmpty { return true }
        
        let search = searchText.lowercased()
        return mezzo.targa.lowercased().contains(search) ||
               mezzo.marca.lowercased().contains(search) ||
               mezzo.modello.lowercased().contains(search) ||
               nomeCompleto(for: mezzo).lowercased().contains(search)
    }
    
    static func filterByStato(_ mezzi: [Mezzo], stato: StatoMezzo) -> [Mezzo] {
        return mezzi.filter { $0.stato == stato }
    }
    
    static func filterDisponibili(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.filter { $0.stato == .disponibile && !isRevisioneScaduta(for: $0) }
    }
    
    static func filterInScadenza(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.filter { isRevisioneInScadenza(for: $0) || needsMaintenance(mezzo: $0) }
    }
    
    // MARK: - Sorting
    static func sortByTarga(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.sorted { $0.targa < $1.targa }
    }
    
    static func sortByMarca(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.sorted { nomeCompleto(for: $0) < nomeCompleto(for: $1) }
    }
    
    static func sortByStato(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.sorted { $0.stato.rawValue < $1.stato.rawValue }
    }
    
    static func sortByKm(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.sorted { $0.kilometraggio < $1.kilometraggio }
    }
    
    static func sortByRevisione(_ mezzi: [Mezzo]) -> [Mezzo] {
        return mezzi.sorted { $0.dataRevisione < $1.dataRevisione }
    }
    
    // MARK: - Export Helpers
    static func toDictionary(_ mezzo: Mezzo) -> [String: Any] {
        return [
            "targa": targaFormattata(for: mezzo),
            "marca": mezzo.marca,
            "modello": mezzo.modello,
            "nomeCompleto": nomeCompleto(for: mezzo),
            "stato": descrizioneStato(for: mezzo),
            "km": kmFormattato(for: mezzo),
            "kilometraggio": mezzo.kilometraggio,
            "dataRevisione": dataRevisioneFormattata(for: mezzo),
            "tipoProprietà": tipoProprieta(for: mezzo),
            "isRevisioneScaduta": isRevisioneScaduta(for: mezzo),
            "isNoleggioScaduto": isNoleggioScaduto(for: mezzo),
            "numeroManutenzioni": numeroManutenzioni(for: mezzo),
            "costoTotaleManutenzioni": costoTotaleManutenzioniFormattato(for: mezzo),
            "ultimaManutenzione": ultimaManutenzioneDescrizione(for: mezzo),
            "aiQualityScore": aiQualityScore(for: mezzo),
            "isAIRecommended": isAIRecommended(mezzo: mezzo),
            "needsMaintenance": needsMaintenance(mezzo: mezzo)
        ]
    }
    
    // MARK: - Validation
    static func validate(_ mezzo: Mezzo) -> [String] {
        var errors: [String] = []
        
        if mezzo.targa.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("La targa è obbligatoria")
        }
        
        if mezzo.marca.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("La marca è obbligatoria")
        }
        
        if mezzo.modello.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il modello è obbligatorio")
        }
        
        if isRevisioneScaduta(for: mezzo) {
            errors.append("La revisione è scaduta")
        }
        
        if mezzo.tipoProprietà == .noleggio && isNoleggioScaduto(for: mezzo) {
            errors.append("Il contratto di noleggio è scaduto")
        }
        
        return errors
    }
    
    // MARK: - Statistics
    static func statistiche(mezzi: [Mezzo]) -> (
        totali: Int,
        disponibili: Int,
        inUso: Int,
        manutenzione: Int,
        fuoriServizio: Int,
        revisioniScadute: Int,
        inScadenza: Int
    ) {
        let totali = mezzi.count
        let disponibili = filterByStato(mezzi, stato: .disponibile).count
        let inUso = filterByStato(mezzi, stato: .inUso).count
        let manutenzione = filterByStato(mezzi, stato: .manutenzione).count
        let fuoriServizio = filterByStato(mezzi, stato: .fuoriServizio).count
        let revisioniScadute = mezzi.filter { isRevisioneScaduta(for: $0) }.count
        let inScadenza = mezzi.filter { isRevisioneInScadenza(for: $0) }.count
        
        return (totali, disponibili, inUso, manutenzione, fuoriServizio, revisioniScadute, inScadenza)
    }
}

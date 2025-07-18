//
//  GestioneMezziView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 14/07/25.
//

import SwiftUI

struct GestioneMezziView: View {
    @StateObject private var mezziManager = MezziManager()
    @State private var showingNuovoMezzo = false
    @State private var mezzoSelezionato: Mezzo?
    @State private var showingModificaMezzo = false
    @State private var filtroStato: StatoMezzo?
    @State private var filtroTipo: TipoProprietaMezzo?
    @State private var searchText = ""
    
    var mezziFiltrati: [Mezzo] {
        var risultato = mezziManager.mezzi
        
        // Filtro per testo di ricerca
        if !searchText.isEmpty {
            risultato = risultato.filter { mezzo in
                mezzo.targa.localizedCaseInsensitiveContains(searchText) ||
                mezzo.marca.localizedCaseInsensitiveContains(searchText) ||
                mezzo.modello.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filtro per stato
        if let filtroStato = filtroStato {
            risultato = risultato.filter { mezzo in mezzo.stato == filtroStato }
        }
        
        // Filtro per tipo proprietà
        if let filtroTipo = filtroTipo {
            risultato = risultato.filter { mezzo in mezzo.tipoProprietà == filtroTipo }
        }
        
        return risultato
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con statistiche generali
                    headerSection
                    
                    // Barra di ricerca e filtri
                    searchAndFiltersSection
                    
                    // Statistiche rapide
                    statisticheRapideSection
                    
                    // Alerts per scadenze
                    alertsSection
                    
                    // Griglia mezzi
                    mezziGridSection
                }
                .padding()
            }
            .navigationTitle("Gestione Mezzi")
            .searchable(text: $searchText, prompt: "Cerca per targa, marca o modello")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuovo Veicolo") {
                        showingNuovoMezzo = true
                    }
                }
            }
            .refreshable {
                // Ricarica dati se necessario
                await refreshData()
            }
        }
        .frame(width: 1000, height: 700)
        .sheet(isPresented: $showingNuovoMezzo) {
            NuovoMezzoView { nuovoMezzo in
                print("🚗 Aggiungendo nuovo mezzo: \(nuovoMezzo.targa) - Tipo: \(nuovoMezzo.tipoProprietà.rawValue)")
                mezziManager.aggiungiMezzo(nuovoMezzo)
            }
        }
        .sheet(isPresented: $showingModificaMezzo) {
            if let mezzo = mezzoSelezionato {
                ModificaMezzoView(
                    mezzo: mezzo,
                    onSave: { mezzoAggiornato in
                        print("🔧 Aggiornando mezzo: \(mezzoAggiornato.targa) - Tipo: \(mezzoAggiornato.tipoProprietà.rawValue)")
                        mezziManager.aggiornaMezzo(mezzoAggiornato)
                        // Reset selezione dopo aggiornamento
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            mezzoSelezionato = nil
                        }
                    },
                    onDelete: { mezzoEliminato in
                        print("🗑️ Eliminando mezzo: \(mezzoEliminato.targa)")
                        mezziManager.eliminaMezzo(mezzoEliminato)
                        // Reset selezione dopo eliminazione
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            mezzoSelezionato = nil
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "car.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gestione Mezzi")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Flotta di \(mezziManager.mezzi.count) veicoli")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Indicatore stato generale
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Operativi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let operativi = mezziManager.mezzi.filter { $0.stato == .disponibile || $0.stato == .inUso }.count
                    Text("\(operativi)/\(mezziManager.mezzi.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(operativi == mezziManager.mezzi.count ? .green : .orange)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Search and Filters Section
    private var searchAndFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filtro per stato
                Menu {
                    Button("Tutti gli stati") {
                        filtroStato = nil
                    }
                    Divider()
                    ForEach(StatoMezzo.allCases) { stato in
                        Button(action: { filtroStato = stato }) {
                            HStack {
                                Text(stato.rawValue)
                                if filtroStato == stato {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(filtroStato?.color ?? .gray)
                        Text(filtroStato?.rawValue ?? "Stato")
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(20)
                }
                
                // Filtro per tipo proprietà
                Menu {
                    Button("Tutti i tipi") {
                        filtroTipo = nil
                    }
                    Divider()
                    ForEach(TipoProprietaMezzo.allCases) { tipo in
                        Button(action: { filtroTipo = tipo }) {
                            HStack {
                                Text(tipo.rawValue)
                                if filtroTipo == tipo {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: filtroTipo == .proprio ? "house.fill" : "calendar.badge.clock")
                        Text(filtroTipo?.rawValue ?? "Proprietà")
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(20)
                }
                
                // Reset filtri
                if filtroStato != nil || filtroTipo != nil {
                    Button("Reset") {
                        filtroStato = nil
                        filtroTipo = nil
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Statistiche Rapide Section
    private var statisticheRapideSection: some View {
        let stats = mezziManager.statistiche
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatisticaCard(
                    titolo: "Disponibili",
                    valore: "\(stats.disponibili)",
                    icona: "checkmark.circle.fill",
                    colore: .green,
                    isCompact: true
                )
                
                StatisticaCard(
                    titolo: "In Uso",
                    valore: "\(stats.inUso)",
                    icona: "person.fill.car",
                    colore: .blue,
                    isCompact: true
                )
                
                StatisticaCard(
                    titolo: "Manutenzione",
                    valore: "\(stats.inManutenzione)",
                    icona: "wrench.fill",
                    colore: .orange,
                    isCompact: true
                )
                
                StatisticaCard(
                    titolo: "Costo Tot. Manutenzioni",
                    valore: stats.costoTotaleManutenzioni.formatted(.currency(code: "EUR")),
                    icona: "eurosign.circle.fill",
                    colore: .purple,
                    isCompact: true
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Alerts Section
    private var alertsSection: some View {
        let revisioniScadute = mezziManager.mezziConRevisioneScaduta()
        let noleggiScaduti = mezziManager.mezziConNoleggioScaduto()
        let manutenzioniRichieste = mezziManager.mezziCheMancanoManutenzione()
        
        return VStack(spacing: 12) {
            if !revisioniScadute.isEmpty {
                AlertCard(
                    titolo: "Revisioni Scadute",
                    messaggio: "\(revisioniScadute.count) veicoli con revisione scaduta",
                    icona: "exclamationmark.triangle.fill",
                    colore: .red,
                    veicoli: revisioniScadute.map { $0.targa }
                )
            }
            
            if !noleggiScaduti.isEmpty {
                AlertCard(
                    titolo: "Noleggi Scaduti",
                    messaggio: "\(noleggiScaduti.count) contratti di noleggio scaduti",
                    icona: "calendar.badge.exclamationmark",
                    colore: .orange,
                    veicoli: noleggiScaduti.map { $0.targa }
                )
            }
            
            if !manutenzioniRichieste.isEmpty {
                AlertCard(
                    titolo: "Manutenzione Richiesta",
                    messaggio: "\(manutenzioniRichieste.count) veicoli richiedono manutenzione",
                    icona: "wrench.adjustable.circle.fill",
                    colore: .blue,
                    veicoli: manutenzioniRichieste.map { $0.targa }
                )
            }
        }
    }
    
    // MARK: - Mezzi Grid Section
    private var mezziGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Veicoli")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(mezziFiltrati.count) di \(mezziManager.mezzi.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if mezziFiltrati.isEmpty {
                EmptyStateView(
                    title: searchText.isEmpty ? "Nessun veicolo" : "Nessun risultato",
                    message: searchText.isEmpty ?
                        "Aggiungi il primo veicolo alla flotta" :
                        "Nessun veicolo corrisponde ai criteri di ricerca",
                    systemImage: "car.2"
                )
                .frame(height: 200)
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 280), spacing: 16)
                ], spacing: 16) {
                    ForEach(mezziFiltrati) { mezzo in
                        MezzoCardCompatta(
                            mezzo: mezzo,
                            onTap: {
                                mezzoSelezionato = mezzo
                                showingModificaMezzo = true
                            },
                            onDelete: { mezzoEliminato in
                                print("🗑️ Eliminando mezzo da card: \(mezzoEliminato.targa)")
                                mezziManager.eliminaMezzo(mezzoEliminato)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func refreshData() async {
        // Simula refresh dei dati
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

// MARK: - Supporting Views (mantieni quelle esistenti)

struct StatisticaCard: View {
    let titolo: String
    let valore: String
    let icona: String
    let colore: Color
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: isCompact ? 6 : 8) {
            Image(systemName: icona)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundColor(colore)
            
            Text(valore)
                .font(isCompact ? .subheadline : .title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(titolo)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(minWidth: isCompact ? 120 : 140)
        .padding(isCompact ? 12 : 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AlertCard: View {
    let titolo: String
    let messaggio: String
    let icona: String
    let colore: Color
    let veicoli: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: icona)
                        .foregroundColor(colore)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(titolo)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(messaggio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Veicoli interessati:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(veicoli, id: \.self) { targa in
                        Text("• \(targa)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.leading, 24)
            }
        }
        .padding()
        .background(colore.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colore.opacity(0.3), lineWidth: 1)
        )
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MezzoCardCompatta: View {
    let mezzo: Mezzo
    let onTap: () -> Void
    let onDelete: ((Mezzo) -> Void)?
    @State private var isPressed = false
    @State private var showingDeleteAlert = false
    
    init(mezzo: Mezzo, onTap: @escaping () -> Void, onDelete: ((Mezzo) -> Void)? = nil) {
        self.mezzo = mezzo
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header con targa e stato
            HStack {
                Text(mezzo.targa)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(mezzo.stato.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(mezzo.stato.color.opacity(0.2))
                        .foregroundColor(mezzo.stato.color)
                        .cornerRadius(6)
                    
                    if onDelete != nil {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Icona e info base
            Button(action: {
                // Aggiungi un piccolo delay per evitare conflitti
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    onTap()
                }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "car.2.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(mezzo.marca) \(mezzo.modello)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(2)
                        
                        Text("Km: \(mezzo.km)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Info aggiuntive
                VStack(spacing: 6) {
                    HStack {
                        Text("Revisione")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(mezzo.dataRevisione.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(mezzo.isRevisioneScaduta ? .red : .primary)
                    }
                    
                    HStack {
                        Text("Tipo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: mezzo.tipoProprietà == .proprio ? "house.fill" : "calendar")
                                .font(.caption2)
                            Text(mezzo.tipoProprietà.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(mezzo.tipoProprietà == .proprio ? .green : .orange)
                    }
                    
                    if !mezzo.manutenzioni.isEmpty {
                        HStack {
                            Text("Manutenzioni")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(mezzo.manutenzioni.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Alerts in card
                if mezzo.isRevisioneScaduta || mezzo.isScadutoNoleggio {
                    HStack(spacing: 8) {
                        if mezzo.isRevisioneScaduta {
                            Label("Revisione scaduta", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        
                        if mezzo.isScadutoNoleggio {
                            Label("Noleggio scaduto", systemImage: "calendar.badge.exclamationmark")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .alert("Elimina Mezzo", isPresented: $showingDeleteAlert) {
            Button("Elimina", role: .destructive) {
                onDelete?(mezzo)
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Sei sicuro di voler eliminare il mezzo \(mezzo.targa)?")
        }
    }
}

#Preview {
    GestioneMezziView()
}

//
//  ManutenzioniView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI

// MARK: - Manutenzioni View
struct ManutenzioniView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mezzo: Mezzo
    @State private var showingNuovaManutenzione = false
    @State private var manutenzioneSelezionata: Manutenzione?
    @State private var showingModificaManutenzione = false
    @State private var showingDeleteAlert = false
    @State private var manutenzioneToDelete: Manutenzione?
    @State private var filtroTipo: TipoManutenzione?
    @State private var searchText = ""
    
    var manutezioniOrdinate: [Manutenzione] {
        return mezzo.manutenzioni.sorted { $0.data > $1.data }
    }
    
    var manutenzioniFiltrate: [Manutenzione] {
        var risultato = manutezioniOrdinate
        
        if let filtroTipo = filtroTipo {
            risultato = risultato.filter { $0.tipo == filtroTipo }
        }
        
        if !searchText.isEmpty {
            risultato = risultato.filter { manutenzione in
                manutenzione.descrizione.localizedCaseInsensitiveContains(searchText) ||
                manutenzione.officina.localizedCaseInsensitiveContains(searchText) ||
                manutenzione.note.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return risultato
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con statistiche
                headerSection
                
                // Filtri
                if !mezzo.manutenzioni.isEmpty {
                    filtriSection
                }
                
                // Lista manutenzioni
                if manutenzioniFiltrate.isEmpty {
                    emptyStateView
                } else {
                    listaManutenzioni
                }
            }
            .navigationTitle("Manutenzioni")
            .searchable(text: $searchText, prompt: "Cerca manutenzioni")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuova Manutenzione") {
                        showingNuovaManutenzione = true
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
        .sheet(isPresented: $showingNuovaManutenzione) {
            NuovaManutenzioneView(mezzo: $mezzo)
        }
        .sheet(isPresented: $showingModificaManutenzione) {
            if let manutenzione = manutenzioneSelezionata {
                ModificaManutenzioneView(
                    mezzo: $mezzo,
                    manutenzione: manutenzione
                )
            }
        }
        .alert("Elimina Manutenzione", isPresented: $showingDeleteAlert) {
            Button("Elimina", role: .destructive) {
                if let manutenzione = manutenzioneToDelete {
                    eliminaManutenzione(manutenzione)
                }
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Sei sicuro di voler eliminare questa manutenzione?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manutenzioni")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(mezzo.targa) - \(mezzo.marca) \(mezzo.modello)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Statistiche
            HStack(spacing: 16) {
                StatCard(
                    title: "Totale",
                    value: "\(mezzo.manutenzioni.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    title: "Costo Totale",
                    value: mezzo.costoTotaleManutenzioni.formatted(.currency(code: "EUR")),
                    icon: "eurosign.circle",
                    color: .green
                )
                
                StatCard(
                    title: "Ultima",
                    value: mezzo.ultimaManutenzione?.data.formatted(date: .abbreviated, time: .omitted) ?? "N/A",
                    icon: "clock",
                    color: .orange
                )
                
                StatCard(
                    title: "Costo Medio",
                    value: (mezzo.manutenzioni.count > 0 ? (mezzo.costoTotaleManutenzioni / Double(mezzo.manutenzioni.count)) : 0).formatted(.currency(code: "EUR")),
                    icon: "chart.bar",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
    
    // MARK: - Filtri Section
    private var filtriSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filtro per tipo
                Menu {
                    Button("Tutti i tipi") {
                        filtroTipo = nil
                    }
                    Divider()
                    ForEach(TipoManutenzione.allCases) { tipo in
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
                        Image(systemName: iconForTipo(filtroTipo ?? .ordinaria))
                            .foregroundColor(colorForTipo(filtroTipo ?? .ordinaria))
                        Text(filtroTipo?.rawValue ?? "Tipo")
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
                if filtroTipo != nil {
                    Button("Reset") {
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
        .padding(.vertical, 8)
    }
    
    // MARK: - Lista Manutenzioni
    private var listaManutenzioni: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(manutenzioniFiltrate) { manutenzione in
                    ManutenzioneCard(
                        manutenzione: manutenzione,
                        onTap: {
                            manutenzioneSelezionata = manutenzione
                            showingModificaManutenzione = true
                        },
                        onDelete: {
                            manutenzioneToDelete = manutenzione
                            showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "wrench.and.screwdriver" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "Nessuna Manutenzione" : "Nessun Risultato")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ?
                 "Aggiungi la prima manutenzione per questo veicolo" :
                 "Nessuna manutenzione corrisponde ai criteri di ricerca")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button("Aggiungi Manutenzione") {
                    showingNuovaManutenzione = true
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Actions
    private func eliminaManutenzione(_ manutenzione: Manutenzione) {
        mezzo.manutenzioni.removeAll { $0.id == manutenzione.id }
    }
    
    // MARK: - Helper Functions
    private func iconForTipo(_ tipo: TipoManutenzione) -> String {
        switch tipo {
        case .ordinaria: return "wrench"
        case .straordinaria: return "exclamationmark.triangle"
        case .revisione: return "checkmark.shield"
        case .riparazione: return "hammer"
        case .tagliando: return "gear"
        }
    }
    
    private func colorForTipo(_ tipo: TipoManutenzione) -> Color {
        switch tipo {
        case .ordinaria: return .blue
        case .straordinaria: return .orange
        case .revisione: return .green
        case .riparazione: return .red
        case .tagliando: return .purple
        }
    }
}

// MARK: - Supporting Views

// Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .frame(maxWidth: .infinity)
    }
}

// Manutenzione Card
struct ManutenzioneCard: View {
    let manutenzione: Manutenzione
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icona tipo manutenzione
                Image(systemName: iconForTipo(manutenzione.tipo))
                    .font(.system(size: 24))
                    .foregroundColor(colorForTipo(manutenzione.tipo))
                    .frame(width: 40, height: 40)
                    .background(colorForTipo(manutenzione.tipo).opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(manutenzione.tipo.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(manutenzione.data.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(manutenzione.descrizione)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !manutenzione.officina.isEmpty {
                        HStack {
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(manutenzione.officina)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(manutenzione.costo, format: .currency(code: "EUR"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForTipo(_ tipo: TipoManutenzione) -> String {
        switch tipo {
        case .ordinaria: return "wrench"
        case .straordinaria: return "exclamationmark.triangle"
        case .revisione: return "checkmark.shield"
        case .riparazione: return "hammer"
        case .tagliando: return "gear"
        }
    }
    
    private func colorForTipo(_ tipo: TipoManutenzione) -> Color {
        switch tipo {
        case .ordinaria: return .blue
        case .straordinaria: return .orange
        case .revisione: return .green
        case .riparazione: return .red
        case .tagliando: return .purple
        }
    }
}

// MARK: - Nuova Manutenzione View
struct NuovaManutenzioneView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mezzo: Mezzo
    
    @State private var data = Date()
    @State private var tipo: TipoManutenzione = .ordinaria
    @State private var descrizione = ""
    @State private var costo: Double = 0.0
    @State private var officina = ""
    @State private var note = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSectionNuova
                    
                    // Form sections
                    VStack(spacing: 16) {
                        informazioniGeneraliSection
                        dettagliEconomiciSection
                        noteSection
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Nuova Manutenzione")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        salvaManutenzione()
                    }
                    .disabled(descrizione.isEmpty)
                }
            }
            .alert("Errore", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .frame(width: 600, height: 500)
    }
    
    private var headerSectionNuova: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nuova Manutenzione")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(mezzo.targa) - \(mezzo.marca) \(mezzo.modello)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var informazioniGeneraliSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informazioni Generali")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $data, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo Manutenzione")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Tipo Manutenzione", selection: $tipo) {
                        Text("Ordinaria")
                            .tag(TipoManutenzione.ordinaria)
                        
                        Text("Straordinaria")
                            .tag(TipoManutenzione.straordinaria)
                        
                        Text("Revisione")
                            .tag(TipoManutenzione.revisione)
                        
                        Text("Riparazione")
                            .tag(TipoManutenzione.riparazione)
                        
                        Text("Tagliando")
                            .tag(TipoManutenzione.tagliando)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descrizione")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $descrizione)
                        .frame(minHeight: 60)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var dettagliEconomiciSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dettagli Economici")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Costo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Costo", value: $costo, format: .currency(code: "EUR"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // keyboardType rimosso per macOS
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Officina")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Officina", text: $officina)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Note")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $note)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    HStack {
                        if note.isEmpty {
                            Text("Note aggiuntive (opzionale)")
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                        }
                        Spacer()
                    },
                    alignment: .topLeading
                )
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func salvaManutenzione() {
        // Validazione
        guard !descrizione.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "La descrizione è obbligatoria"
            showingAlert = true
            return
        }
        
        if costo < 0 {
            alertMessage = "Il costo non può essere negativo"
            showingAlert = true
            return
        }
        
        let nuovaManutenzione = Manutenzione(
            data: data,
            tipo: tipo,
            descrizione: descrizione.trimmingCharacters(in: .whitespacesAndNewlines),
            costo: costo,
            officina: officina.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        mezzo.manutenzioni.append(nuovaManutenzione)
        dismiss()
    }
    
    private func iconForTipo(_ tipo: TipoManutenzione) -> String {
        switch tipo {
        case .ordinaria: return "wrench"
        case .straordinaria: return "exclamationmark.triangle"
        case .revisione: return "checkmark.shield"
        case .riparazione: return "hammer"
        case .tagliando: return "gear"
        }
    }
    
    private func colorForTipo(_ tipo: TipoManutenzione) -> Color {
        switch tipo {
        case .ordinaria: return .blue
        case .straordinaria: return .orange
        case .revisione: return .green
        case .riparazione: return .red
        case .tagliando: return .purple
        }
    }
}

// MARK: - Modifica Manutenzione View
struct ModificaManutenzioneView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mezzo: Mezzo
    @State private var manutenzione: Manutenzione
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(mezzo: Binding<Mezzo>, manutenzione: Manutenzione) {
        self._mezzo = mezzo
        self._manutenzione = State(initialValue: manutenzione)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSectionModifica
                    
                    // Form sections
                    VStack(spacing: 16) {
                        informazioniGeneraliSectionModifica
                        dettagliEconomiciSectionModifica
                        noteSectionModifica
                        infoSistemaSection
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Modifica Manutenzione")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        salvaManutenzione()
                    }
                    .disabled(manutenzione.descrizione.isEmpty)
                }
            }
            .alert("Errore", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .frame(width: 600, height: 600)
    }
    
    private var headerSectionModifica: some View {
        HStack {
            Image(systemName: iconForTipo(manutenzione.tipo))
                .font(.system(size: 40))
                .foregroundColor(colorForTipo(manutenzione.tipo))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Modifica Manutenzione")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(manutenzione.tipo.rawValue) - \(manutenzione.data.formatted(date: .abbreviated, time: .omitted))")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(colorForTipo(manutenzione.tipo).opacity(0.1))
        .cornerRadius(12)
    }
    
    private var informazioniGeneraliSectionModifica: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informazioni Generali")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $manutenzione.data, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo Manutenzione")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Tipo Manutenzione", selection: $manutenzione.tipo) {
                        ForEach(TipoManutenzione.allCases) { tipo in
                            HStack {
                                Image(systemName: iconForTipo(tipo))
                                    .foregroundColor(colorForTipo(tipo))
                                Text(tipo.rawValue)
                            }
                            .tag(tipo)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descrizione")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $manutenzione.descrizione)
                        .frame(minHeight: 60)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var dettagliEconomiciSectionModifica: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dettagli Economici")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Costo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Costo", value: $manutenzione.costo, format: .currency(code: "EUR"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // keyboardType rimosso per macOS
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Officina")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Officina", text: $manutenzione.officina)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var noteSectionModifica: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Note")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $manutenzione.note)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var infoSistemaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informazioni Sistema")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("Data Creazione")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(manutenzione.dataCreazione.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func salvaManutenzione() {
        // Validazione
        guard !manutenzione.descrizione.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "La descrizione è obbligatoria"
            showingAlert = true
            return
        }
        
        if manutenzione.costo < 0 {
            alertMessage = "Il costo non può essere negativo"
            showingAlert = true
            return
        }
        
        // Aggiorna la manutenzione nel mezzo
        if let index = mezzo.manutenzioni.firstIndex(where: { $0.id == manutenzione.id }) {
            mezzo.manutenzioni[index] = manutenzione
        }
        
        dismiss()
    }
    
    private func iconForTipo(_ tipo: TipoManutenzione) -> String {
        switch tipo {
        case .ordinaria: return "wrench"
        case .straordinaria: return "exclamationmark.triangle"
        case .revisione: return "checkmark.shield"
        case .riparazione: return "hammer"
        case .tagliando: return "gear"
        }
    }
    
    private func colorForTipo(_ tipo: TipoManutenzione) -> Color {
        switch tipo {
        case .ordinaria: return .blue
        case .straordinaria: return .orange
        case .revisione: return .green
        case .riparazione: return .red
        case .tagliando: return .purple
        }
    }
}

#Preview {
    @State var mezzoEsempio = Mezzo(
        targa: "AA123BB",
        modello: "Classe E",
        marca: "Mercedes",
        dataRevisione: Date()
    )
    
    return ManutenzioniView(mezzo: .constant(mezzoEsempio))
}

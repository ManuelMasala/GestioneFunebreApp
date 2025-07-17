//
//  GestioneDefuntiView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 14/07/25.
//
import SwiftUI

struct GestioneDefuntiView: View {
    @StateObject private var manager = ManagerGestioneDefunti()
    @State private var showingNuovoDefunto = false
    @State private var selectedDefunto: PersonaDefunta?
    @State private var showingDettaglio = false
    @State private var showingEliminaAlert = false
    @State private var defuntoDaEliminare: PersonaDefunta?
    @State private var showingExport = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header semplificato
            headerSection
            
            // Content
            if manager.defuntiFiltrati.isEmpty {
                emptyStateView
            } else {
                defuntiListView
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .navigationTitle("Gestione Defunti")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Esporta") {
                    showingExport = true
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Button("Nuovo Defunto") {
                    showingNuovoDefunto = true
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showingNuovoDefunto) {
            NuovoDefuntoBasicView()
                .environmentObject(manager)
        }
        .sheet(item: $selectedDefunto) { defunto in
            DettaglioDefuntoView(defunto: defunto)
        }
        .sheet(isPresented: $showingExport) {
            ExportView(defunti: manager.defuntiFiltrati)
        }
        .alert("Elimina Defunto", isPresented: $showingEliminaAlert) {
            Button("Elimina", role: .destructive) {
                if let defunto = defuntoDaEliminare {
                    manager.eliminaDefunto(defunto)
                    defuntoDaEliminare = nil
                }
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            if let defunto = defuntoDaEliminare {
                Text("Sei sicuro di voler eliminare \(defunto.nomeCompleto)?")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gestione Defunti")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Gestisci i defunti e le pratiche funebri")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats
                HStack(spacing: 16) {
                    VStack {
                        Text("\(manager.defunti.count)")
                            .font(.title)
                            .foregroundColor(.purple)
                        Text("Totale")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack {
                        Text("\(cremazioni)")
                            .font(.title)
                            .foregroundColor(.orange)
                        Text("Cremazioni")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Search bar semplificata
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Cerca defunti...", text: $manager.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !manager.searchText.isEmpty {
                    Button("Cancella") {
                        manager.searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Image(systemName: manager.searchText.isEmpty ? "person.3.sequence" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(manager.searchText.isEmpty ? "Nessun defunto registrato" : "Nessun risultato trovato")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Text(manager.searchText.isEmpty ? "Inizia aggiungendo il primo defunto" : "Prova a modificare i criteri di ricerca")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            if manager.searchText.isEmpty {
                Button("Aggiungi Primo Defunto") {
                    showingNuovoDefunto = true
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var defuntiListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(manager.defuntiFiltrati) { defunto in
                    DefuntoRow(defunto: defunto) {
                        selectedDefunto = defunto
                        showingDettaglio = true
                    } onDelete: {
                        defuntoDaEliminare = defunto
                        showingEliminaAlert = true
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var cremazioni: Int {
        manager.defunti.filter { $0.tipoSepoltura == .cremazione }.count
    }
}

// MARK: - Defunto Row Semplificata
struct DefuntoRow: View {
    let defunto: PersonaDefunta
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar circle
                Circle()
                    .fill(defunto.sesso == .maschio ? Color.blue : Color.pink)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(defunto.sesso.simbolo)
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(defunto.nomeCompleto)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Cartella N° \(defunto.numeroCartella)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(defunto.luogoNascita) • \(defunto.dataDecesoFormattata)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right info
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(defunto.eta) anni")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: defunto.tipoSepoltura.icona)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(defunto.tipoSepoltura.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Menu button
                Menu {
                    Button("Visualizza") {
                        onTap()
                    }
                    
                    Divider()
                    
                    Button("Elimina", role: .destructive) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                }
                .menuStyle(BorderlessButtonMenuStyle())
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Detail View Semplificata
struct DettaglioDefuntoView: View {
    let defunto: PersonaDefunta
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(defunto.sesso == .maschio ? Color.blue : Color.pink)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(defunto.sesso.simbolo)
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(defunto.nomeCompleto)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Cartella N° \(defunto.numeroCartella)")
                                .font(.body)
                                .foregroundColor(.blue)
                            
                            Text("\(defunto.eta) anni")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Dati Anagrafici
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dati Anagrafici")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            DetailRow(label: "Codice Fiscale", value: defunto.codiceFiscale)
                            DetailRow(label: "Data Nascita", value: defunto.dataNascitaFormattata)
                            DetailRow(label: "Luogo Nascita", value: defunto.luogoNascita)
                            DetailRow(label: "Stato Civile", value: defunto.statoCivile.rawValue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Decesso
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Decesso")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            DetailRow(label: "Data", value: defunto.dataDecesoFormattata)
                            DetailRow(label: "Ora", value: defunto.oraDecesso)
                            DetailRow(label: "Luogo", value: defunto.luogoDecesso.rawValue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Familiare con NUOVI CAMPI
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Familiare Responsabile")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            let familiare = defunto.familiareRichiedente
                            
                            DetailRow(label: "Nome", value: familiare.nomeCompleto)
                            DetailRow(label: "Data Nascita", value: familiare.dataNascitaFormattata)
                            DetailRow(label: "Luogo Nascita", value: familiare.luogoNascita)
                            DetailRow(label: "Età", value: "\(familiare.eta) anni")
                            DetailRow(label: "Sesso", value: familiare.sesso.descrizione)
                            DetailRow(label: "Parentela", value: familiare.parentela.rawValue)
                            DetailRow(label: "Telefono", value: familiare.telefono)
                            
                            if let cellulare = familiare.cellulare, !cellulare.isEmpty {
                                DetailRow(label: "Cellulare", value: cellulare)
                            }
                            
                            if let email = familiare.email, !email.isEmpty {
                                DetailRow(label: "Email", value: email)
                            }
                            
                            if let note = familiare.note, !note.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Note:")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    Text(note)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(16)
            }
            .navigationTitle("Dettaglio Defunto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 700)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Export View Semplificata
struct ExportView: View {
    let defunti: [PersonaDefunta]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .csv
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Esporta \(defunti.count) defunti")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button(action: { selectedFormat = format }) {
                            HStack {
                                Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == format ? .blue : .secondary)
                                
                                Text(format.rawValue)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(8)
                            .background(selectedFormat == format ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Button("Esporta") {
                    exportData()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Esporta Dati")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 350)
    }
    
    private func exportData() {
        let content: String
        
        switch selectedFormat {
        case .csv:
            content = ExportUtilities.exportToCSV(defunti: defunti)
        case .txt:
            content = ExportUtilities.exportToTXT(defunti: defunti)
        case .json:
            content = ExportUtilities.exportToJSON(defunti: defunti) ?? ""
        case .pdf:
            content = "PDF non disponibile"
        }
        
        print("Esportato: \(content.count) caratteri")
        dismiss()
    }
}

#Preview {
    GestioneDefuntiView()
}

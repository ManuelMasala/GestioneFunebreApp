//
//  GestioneDefuntiView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 14/07/25.
//
import SwiftUI

struct GestioneDefuntiView: View {
    @StateObject private var manager = ManagerGestioneDefunti()
    @StateObject private var aiManager = SimpleAIManager()
    @State private var showingNuovoDefunto = false
    @State private var selectedDefunto: PersonaDefunta?
    @State private var showingDettaglio = false
    @State private var showingEliminaAlert = false
    @State private var defuntoDaEliminare: PersonaDefunta?
    @State private var showingExport = false
    @State private var showingAIAnalytics = false
    @State private var aiAnalysisResult: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con toolbar integrato
            headerWithToolbarSection
            
            // Content
            if manager.defuntiFiltrati.isEmpty {
                emptyStateView
            } else {
                defuntiListView
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .navigationTitle("Gestione Defunti")
        .sheet(isPresented: $showingNuovoDefunto) {
            NuovoDefuntoBasicView()
                .environmentObject(manager)
        }
        .sheet(item: $selectedDefunto) { defunto in
            DettaglioDefuntoSimpleView(defunto: defunto, manager: manager)
        }
        .sheet(isPresented: $showingExport) {
            ExportView(manager: manager)
        }
        .sheet(isPresented: $showingAIAnalytics) {
            AIAnalyticsView(analysisResult: aiAnalysisResult)
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
        // Floating AI Assistant
        .overlay(
            FloatingAIAssistant()
                .offset(x: -20, y: -20),
            alignment: .bottomTrailing
        )
    }
    
    private var headerWithToolbarSection: some View {
        VStack(spacing: 16) {
            // Toolbar integrato
            HStack {
                Text("Gestione Defunti")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Toolbar buttons
                HStack(spacing: 12) {
                    // AI Analytics Button
                    Button("AI Analytics") {
                        performAIAnalysis()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                    
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
            
            // Subtitle e stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gestisci i defunti e le pratiche funebri")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats con AI insights
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
                    
                    Divider()
                        .frame(height: 40)
                    
                    // AI Quality Score
                    VStack {
                        Text("\(aiQualityScore)%")
                            .font(.title)
                            .foregroundColor(.green)
                        Text("Qualità AI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Search bar con AI suggestions
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
                
                // AI Smart Search
                Button(action: {
                    performAISmartSearch()
                }) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                }
                .help("Ricerca intelligente AI")
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
                VStack(spacing: 12) {
                    Button("Aggiungi Primo Defunto") {
                        showingNuovoDefunto = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    // AI Quick Start
                    Button("📄 Importa da Documento AI") {
                        startAIImportWorkflow()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var defuntiListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(manager.defuntiFiltrati) { defunto in
                    DefuntoRowWithAIClean(defunto: defunto) {
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
    
    private var aiQualityScore: Int {
        // Calcolo qualità dati AI
        let totalDefunti = manager.defunti.count
        guard totalDefunti > 0 else { return 100 }
        
        let qualityChecks = manager.defunti.map { defunto in
            var score = 0
            if !defunto.nome.isEmpty && !defunto.cognome.isEmpty { score += 20 }
            if !defunto.codiceFiscale.isEmpty { score += 20 }
            if !defunto.luogoNascita.isEmpty { score += 15 }
            if !defunto.oraDecesso.isEmpty { score += 15 }
            if !defunto.familiareRichiedente.telefono.isEmpty { score += 15 }
            if defunto.familiareRichiedente.email != nil { score += 15 }
            return score
        }
        
        return qualityChecks.reduce(0, +) / totalDefunti
    }
    
    // MARK: - AI Functions
    private func performAIAnalysis() {
        Task {
            await MainActor.run {
                aiManager.isProcessing = true
            }
            
            // Simula elaborazione AI
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            
            await MainActor.run {
                aiAnalysisResult = """
                📊 ANALISI AI COMPLETATA
                
                📈 STATISTICHE GENERALI:
                • Defunti totali: \(manager.defunti.count)
                • Cremazioni: \(cremazioni) (\(cremazioni > 0 ? String(format: "%.1f", Double(cremazioni) / Double(manager.defunti.count) * 100) : "0")%)
                • Qualità dati: \(aiQualityScore)%
                
                🎯 QUALITÀ DATI:
                • \(manager.defunti.filter { !$0.codiceFiscale.isEmpty }.count) defunti con codice fiscale
                • \(manager.defunti.filter { $0.familiareRichiedente.email != nil }.count) con email familiare
                • \(manager.defunti.filter { !$0.oraDecesso.isEmpty }.count) con ora decesso registrata
                
                💡 RACCOMANDAZIONI:
                • Completare i codici fiscali mancanti
                • Raccogliere email dei familiari per comunicazioni
                • Verificare completezza dati anagrafici
                • Implementare controlli automatici qualità
                
                📈 TREND IDENTIFICATI:
                • Aumento delle cremazioni vs tumulazioni
                • Necessità di digitalizzazione processi
                • Opportunità di automazione con AI
                """
                
                aiManager.isProcessing = false
                showingAIAnalytics = true
            }
        }
    }
    
    private func performAISmartSearch() {
        // Implementa ricerca intelligente
        if manager.searchText.isEmpty {
            // Suggerisci ricerche comuni
            manager.searchText = "dati incompleti"
        } else {
            // Migliora ricerca esistente
            manager.searchText = manager.searchText + " AI"
        }
    }
    
    private func startAIImportWorkflow() {
        // Implementa workflow per importazione AI
        print("Avvio workflow importazione AI...")
        showingNuovoDefunto = true
    }
}

// MARK: - Defunto Row Clean (senza conflitti)
struct DefuntoRowWithAIClean: View {
    let defunto: PersonaDefunta
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar circle con AI quality indicator
                ZStack {
                    Circle()
                        .fill(defunto.sesso == .maschio ? Color.blue : Color.pink)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(SessoPersonaHelper.simbolo(for: defunto.sesso))
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                    
                    // AI Quality badge
                    if aiQualityLevel(for: defunto) < 80 {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("!")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .offset(x: 20, y: -20)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(defunto.nomeCompleto)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Cartella N° \(defunto.numeroCartella)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    HStack {
                        Text("\(defunto.luogoNascita) • \(defunto.dataDecesoFormattata)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // AI Quality indicator
                        Text("AI: \(aiQualityLevel(for: defunto))%")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(aiQualityColor(for: defunto).opacity(0.2))
                            .foregroundColor(aiQualityColor(for: defunto))
                            .cornerRadius(4)
                    }
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
                    
                    Button("Migliora con AI") {
                        improveWithAI(defunto)
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
    
    private func aiQualityLevel(for defunto: PersonaDefunta) -> Int {
        var score = 0
        if !defunto.nome.isEmpty && !defunto.cognome.isEmpty { score += 20 }
        if !defunto.codiceFiscale.isEmpty { score += 20 }
        if !defunto.luogoNascita.isEmpty { score += 15 }
        if !defunto.oraDecesso.isEmpty { score += 15 }
        if !defunto.familiareRichiedente.telefono.isEmpty { score += 15 }
        if defunto.familiareRichiedente.email != nil { score += 15 }
        return score
    }
    
    private func aiQualityColor(for defunto: PersonaDefunta) -> Color {
        let quality = aiQualityLevel(for: defunto)
        if quality >= 90 { return .green }
        if quality >= 70 { return .orange }
        return .red
    }
    
    private func improveWithAI(_ defunto: PersonaDefunta) {
        print("Miglioramento AI per \(defunto.nomeCompleto)")
    }
}

// MARK: - AI Analytics View
struct AIAnalyticsView: View {
    let analysisResult: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 32))
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading) {
                            Text("Analisi AI")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Insights e suggerimenti automatici")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text(analysisResult)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("AI Analytics")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Export View
struct ExportView: View {
    let manager: ManagerGestioneDefunti
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("Esporta Dati")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Button("📊 Esporta CSV") {
                        exportCSV()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("📄 Esporta PDF") {
                        exportPDF()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Button("💾 Backup Completo") {
                        createBackup()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
        .alert("Export", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportCSV() {
        do {
            let url = try manager.esportaCSV()
            alertMessage = "File CSV salvato in: \(url.lastPathComponent)"
            showingAlert = true
        } catch {
            alertMessage = "Errore nell'esportazione: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func exportPDF() {
        alertMessage = "Esportazione PDF in sviluppo"
        showingAlert = true
    }
    
    private func createBackup() {
        alertMessage = "Backup completo in sviluppo"
        showingAlert = true
    }
}

// MARK: - Dettaglio Defunto View Semplificata
struct DettaglioDefuntoSimpleView: View {
    let defunto: PersonaDefunta
    let manager: ManagerGestioneDefunti
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Circle()
                            .fill(defunto.sesso == .maschio ? Color.blue : Color.pink)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(SessoPersonaHelper.simbolo(for: defunto.sesso))
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(defunto.nomeCompleto)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Cartella N° \(defunto.numeroCartella)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    
                    // Dati principali
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dati Anagrafici")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            InfoField(label: "Codice Fiscale", value: defunto.codiceFiscale)
                            InfoField(label: "Luogo Nascita", value: defunto.luogoNascita)
                            InfoField(label: "Data Nascita", value: defunto.dataNascita.formatted(date: .abbreviated, time: .omitted))
                            InfoField(label: "Data Decesso", value: defunto.dataDecesso.formatted(date: .abbreviated, time: .omitted))
                            InfoField(label: "Ora Decesso", value: defunto.oraDecesso)
                            InfoField(label: "Età", value: "\(defunto.eta) anni")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Sepoltura
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sepoltura")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            InfoField(label: "Tipo", value: defunto.tipoSepoltura.rawValue)
                            InfoField(label: "Luogo", value: defunto.luogoSepoltura)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Familiare
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Familiare Responsabile")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            InfoField(label: "Nome", value: defunto.familiareRichiedente.nome)
                            InfoField(label: "Cognome", value: defunto.familiareRichiedente.cognome)
                            InfoField(label: "Parentela", value: defunto.familiareRichiedente.parentela.rawValue)
                            InfoField(label: "Telefono", value: defunto.familiareRichiedente.telefono)
                            InfoField(label: "Email", value: defunto.familiareRichiedente.email ?? "Non specificata")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Dettaglio Defunto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Modifica") {
                        // Implementa modifica
                    }
                }
            }
        }
        .frame(width: 700, height: 600)
    }
}

struct InfoField: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            
            Text(value.isEmpty ? "Non specificato" : value)
                .font(.body)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Floating AI Assistant
struct FloatingAIAssistant: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            if isExpanded {
                VStack(spacing: 8) {
                    Button("🧠 Analisi Rapida") {
                        // Quick AI analysis
                        print("Analisi rapida AI")
                    }
                    
                    Button("📄 Scansiona Documento") {
                        // Document scan
                        print("Scansione documento")
                    }
                    
                    Button("💡 Suggerimenti") {
                        // AI suggestions
                        print("Suggerimenti AI")
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 5)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 5)
            }
        }
    }
}

#Preview {
    GestioneDefuntiView()
}

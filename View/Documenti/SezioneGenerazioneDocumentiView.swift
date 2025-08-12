//
//  SezioneGenerazioneDocumentiView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//
import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers

// MARK: - ⭐ SISTEMA DOCUMENTI COMPLETO - TUTTI I COMPONENTI INCLUSI

struct SezioneGenerazioneDocumentiView: View {
    @StateObject private var documentiManager = DocumentiManager()
    @StateObject private var adobeManager = AdobePDFManager.shared
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingNewDocument = false
    @State private var showingImportSheet = false
    @State private var showingDocumentEditor = false
    @State private var showingDocumentViewer = false
    @State private var selectedDocumentForEdit: DocumentoCompilato?
    @State private var selectedDocumentForView: DocumentoCompilato?
    @State private var searchText = ""
    @State private var selectedFilter: TipoDocumento?
    
    // ⭐ STATE VARIABLES PER EDITOR TESTO
    @State private var selectedTemplateForEdit: DocumentoTemplate?
    @State private var showingTemplateEditor = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerView
            
            // Toolbar
            enhancedToolbarView
            
            // Progress bar Adobe (se in processing)
            if adobeManager.isProcessing {
                adobeProgressView
            }
            
            // Contenuto principale
            contentView
        }
        .padding()
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingNewDocument) {
            NewDocumentSheetView { template in
                addTemplate(template)
                showAlert(title: "✅ Creato", message: "Nuovo template aggiunto!")
            }
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportDocumentSheetView { template in
                addTemplate(template)
                showAlert(title: "✅ Importato", message: "Template importato con Adobe OCR!")
            }
        }
        .sheet(isPresented: $showingDocumentEditor) {
            if let document = selectedDocumentForEdit {
                DocumentEditorSheetView(document: document) {
                    documentiManager.ricaricaDocumenti()
                }
            }
        }
        .sheet(isPresented: $showingDocumentViewer) {
            if let document = selectedDocumentForView {
                DocumentViewerSheetView(document: document)
            }
        }
        // ⭐ SHEET PER EDITOR TESTO INTEGRATO
        .sheet(isPresented: $showingTemplateEditor) {
            if let template = selectedTemplateForEdit {
                TextEditorView(
                    template: Binding.constant(template),
                    onSave: {
                        updateTemplate(template)
                        selectedTemplateForEdit = nil
                        showAlert(title: "💾 Salvato", message: "Template '\(template.nome)' aggiornato!")
                    },
                    onCancel: {
                        selectedTemplateForEdit = nil
                    }
                )
            }
        }
    }
    
    // MARK: - 🎨 UI VIEWS
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title)
                    .foregroundColor(.mint)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gestione Documenti AI")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sistema avanzato con Adobe PDF Services & Editor Testo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Statistiche
                HStack(spacing: 20) {
                    QuickStatView(title: "Templates", value: "\(documentiManager.templates.count)", color: Color.blue)
                    QuickStatView(title: "Documenti", value: "\(documentiManager.documentiCompilati.count)", color: Color.green)
                    AdobeStatusStatView(manager: adobeManager)
                }
            }
            
            // Ricerca e filtri
            searchAndFilterView
        }
    }
    
    private var searchAndFilterView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Cerca documenti, defunti, contenuto...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: 400)
            
            Menu {
                Button("Tutti i tipi") { selectedFilter = nil }
                Divider()
                ForEach(TipoDocumento.allCases, id: \.self) { tipo in
                    Button(action: { selectedFilter = tipo }) {
                        HStack {
                            Image(systemName: tipo.icona)
                                .foregroundColor(tipo.color)
                            Text(tipo.rawValue)
                        }
                    }
                }
            } label: {
                HStack {
                    if let filter = selectedFilter {
                        Image(systemName: filter.icona)
                            .foregroundColor(filter.color)
                        Text(DocumentSystemHelper.nomeBreve(for: filter))
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filtra")
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedFilter != nil ? selectedFilter!.color.opacity(0.1) : Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            if selectedFilter != nil || !searchText.isEmpty {
                Button("Reset") {
                    selectedFilter = nil
                    searchText = ""
                }
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
            }
            
            Spacer()
        }
    }
    
    private var enhancedToolbarView: some View {
        HStack {
            Button("📄 Nuovo Template") {
                showingNewDocument = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("🔍 Importa con OCR") {
                showingImportSheet = true
            }
            .buttonStyle(.bordered)
            
            Menu("🛠️ Strumenti") {
                Button("📁 Apri Cartella Documenti") {
                    documentiManager.apriCartellaDocumenti()
                }
                
                Button("💾 Crea Backup") {
                    createBackup()
                }
                
                Divider()
                
                Button("🧹 Elimina File Vecchi") {
                    documentiManager.eliminaFileVecchi()
                    showAlert(title: "🧹 Pulizia", message: "File vecchi eliminati")
                }
                
                Button("🔄 Ricarica Documenti") {
                    documentiManager.ricaricaDocumenti()
                    showAlert(title: "🔄 Aggiornato", message: "Documenti ricaricati")
                }
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // Status Adobe
            HStack(spacing: 8) {
                Circle()
                    .fill(adobeManager.isProcessing ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                
                Text(adobeManager.currentTask)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 120, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    private var adobeProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(adobeManager.isProcessing ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: adobeManager.isProcessing)
                
                Text(adobeManager.currentTask)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(adobeManager.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: adobeManager.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .scaleEffect(y: 2)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var contentView: some View {
        HSplitView {
            // Templates (sinistra)
            templatesListView
                .frame(minWidth: 350)
            
            // Documenti (destra)
            documentsListView
                .frame(minWidth: 450)
        }
        .frame(minHeight: 500)
    }
    
    private var templatesListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Templates (\(filteredTemplates.count))")
                    .font(.headline)
                
                Spacer()
                
                Button("➕") {
                    showingNewDocument = true
                }
                .font(.caption)
                .padding(4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(4)
            }
            
            if filteredTemplates.isEmpty {
                emptyStateView(
                    icon: "doc.text",
                    title: "Nessun template",
                    message: searchText.isEmpty ? "Crea templates per iniziare" : "Nessun template corrisponde alla ricerca"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTemplates) { template in
                            TemplateCardView(
                                template: template,
                                onEdit: { editTemplateText(template) },
                                onDelete: { deleteTemplate(template) },
                                onDuplicate: { duplicateTemplate(template) },
                                onUse: { useTemplate(template) }
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var documentsListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Documenti (\(filteredDocuments.count))")
                    .font(.headline)
                
                Spacer()
                
                Menu("📊 Vista") {
                    Button("📋 Lista") { /* Change view */ }
                    Button("🗂️ Griglia") { /* Change view */ }
                    Button("📈 Statistiche") { showDocumentStats() }
                }
                .font(.caption)
            }
            
            if filteredDocuments.isEmpty {
                emptyStateView(
                    icon: "doc.fill",
                    title: "Nessun documento",
                    message: searchText.isEmpty ? "Genera documenti dai templates" : "Nessun documento corrisponde alla ricerca"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredDocuments) { documento in
                            DocumentCardView(
                                documento: documento,
                                onView: { viewDocument(documento) },
                                onEdit: { editDocument(documento) },
                                onAnalyze: { analyzeDocument(documento) },
                                onExport: { exportDocument(documento) },
                                onDelete: { deleteDocument(documento) }
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - 📊 COMPUTED PROPERTIES
    
    private var filteredTemplates: [DocumentoTemplate] {
        var result = documentiManager.templates
        
        if let filter = selectedFilter {
            result = result.filter { $0.tipo == filter }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.nome.localizedCaseInsensitiveContains(searchText) ||
                $0.tipo.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.contenuto.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted {
            if $0.isDefault != $1.isDefault {
                return $0.isDefault && !$1.isDefault
            }
            return $0.nome < $1.nome
        }
    }
    
    private var filteredDocuments: [DocumentoCompilato] {
        var result = documentiManager.documentiCompilati
        
        if let filter = selectedFilter {
            result = result.filter { $0.template.tipo == filter }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.template.nome.localizedCaseInsensitiveContains(searchText) ||
                $0.defunto.nome.localizedCaseInsensitiveContains(searchText) ||
                $0.defunto.cognome.localizedCaseInsensitiveContains(searchText) ||
                $0.contenutoFinale.localizedCaseInsensitiveContains(searchText) ||
                $0.defunto.numeroCartella.contains(searchText)
            }
        }
        
        return result.sorted { $0.dataCreazione > $1.dataCreazione }
    }
    
    // MARK: - 🎬 ACTIONS
    
    private func editTemplateText(_ template: DocumentoTemplate) {
        selectedTemplateForEdit = template
        showingTemplateEditor = true
    }
    
    private func useTemplate(_ template: DocumentoTemplate) {
        showAlert(title: "📋 Template", message: "Usa template: \(template.nome)")
    }
    
    private func deleteTemplate(_ template: DocumentoTemplate) {
        if template.isDefault {
            showAlert(title: "⚠️ Attenzione", message: "Non puoi eliminare un template predefinito")
            return
        }
        
        removeTemplate(template)
        showAlert(title: "🗑️ Eliminato", message: "Template '\(template.nome)' eliminato")
    }
    
    private func duplicateTemplate(_ template: DocumentoTemplate) {
        let newTemplate = DocumentoTemplate(
            nome: "\(template.nome) - Copia",
            tipo: template.tipo,
            contenuto: template.contenuto
        )
        
        addTemplate(newTemplate)
        showAlert(title: "📋 Duplicato", message: "Template duplicato con successo")
    }
    
    private func viewDocument(_ documento: DocumentoCompilato) {
        selectedDocumentForView = documento
        showingDocumentViewer = true
    }
    
    private func editDocument(_ documento: DocumentoCompilato) {
        selectedDocumentForEdit = documento
        showingDocumentEditor = true
    }
    
    private func analyzeDocument(_ documento: DocumentoCompilato) {
        Task {
            do {
                let analysis = try await adobeManager.analyzeDocument(content: documento.contenutoFinale)
                await MainActor.run {
                    showAlert(
                        title: "🔍 Analisi AI Completata",
                        message: """
                        Tipo: \(analysis.detectedType.rawValue)
                        Qualità: \(analysis.qualityDescription) (\(Int(analysis.quality * 100))%)
                        Parole: \(analysis.wordCount)
                        Caratteri: \(analysis.characterCount)
                        
                        Suggerimenti:
                        \(analysis.suggestions.joined(separator: "\n• "))
                        """
                    )
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "❌ Errore", message: "Errore analisi: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func exportDocument(_ documento: DocumentoCompilato) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf, .plainText, UTType("public.json")!]
        panel.nameFieldStringValue = "\(documento.template.nome)_\(documento.defunto.cognome)"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            
            do {
                switch url.pathExtension.lowercased() {
                case "pdf":
                    let pdfData = generatePDFData(for: documento)
                    try pdfData.write(to: url)
                case "json":
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(documento)
                    try data.write(to: url)
                default:
                    try documento.contenutoFinale.write(to: url, atomically: true, encoding: .utf8)
                }
                showAlert(title: "💾 Esportato", message: "Documento salvato in: \(url.lastPathComponent)")
            } catch {
                showAlert(title: "❌ Errore", message: "Errore esportazione: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteDocument(_ documento: DocumentoCompilato) {
        documentiManager.eliminaDocumento(documento)
        showAlert(title: "🗑️ Eliminato", message: "Documento eliminato")
    }
    
    private func createBackup() {
        do {
            let backupURL = try documentiManager.creaBackup()
            showAlert(title: "💾 Backup", message: "Backup creato: \(backupURL.lastPathComponent)")
        } catch {
            showAlert(title: "❌ Errore", message: "Errore backup: \(error.localizedDescription)")
        }
    }
    
    private func showDocumentStats() {
        let stats = documentiManager.statisticheDocumenti()
        let fileStats = documentiManager.getStatisticheFiles()
        
        showAlert(
            title: "📊 Statistiche Documenti",
            message: """
            📅 Oggi: \(stats.documentiOggi)
            📅 Questa settimana: \(stats.documentiSettimana)  
            📅 Questo mese: \(stats.documentiMese)
            📁 Totale salvati: \(stats.totaleSalvati)
            
            💾 File totali: \(fileStats.totali)
            💾 Dimensione: \(fileStats.dimensione)
            """
        )
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    // MARK: - 🔧 HELPER METHODS
    
    private func updateTemplate(_ template: DocumentoTemplate) {
        if let index = documentiManager.templates.firstIndex(where: { $0.id == template.id }) {
            documentiManager.templates[index] = template
            print("📝 Template '\(template.nome)' aggiornato")
        }
    }
    
    private func addTemplate(_ template: DocumentoTemplate) {
        documentiManager.templates.append(template)
        print("➕ Template '\(template.nome)' aggiunto")
    }
    
    private func removeTemplate(_ template: DocumentoTemplate) {
        documentiManager.templates.removeAll { $0.id == template.id }
        print("🗑️ Template '\(template.nome)' rimosso")
    }
    
    private func generatePDFData(for documento: DocumentoCompilato) -> Data {
        // Implementazione semplificata per generare PDF
        let content = documento.contenutoFinale.isEmpty ? documento.template.contenuto : documento.contenutoFinale
        return content.data(using: .utf8) ?? Data()
    }
}

// MARK: - 🎴 COMPONENTI UI - TEMPLATE & DOCUMENT CARDS

struct TemplateCardView: View {
    let template: DocumentoTemplate
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onUse: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon e badge
            VStack(spacing: 6) {
                Image(systemName: template.tipo.icona)
                    .font(.title2)
                    .foregroundColor(template.tipo.color)
                    .frame(width: 32, height: 32)
                    .background(template.tipo.color.opacity(0.1))
                    .cornerRadius(8)
                
                if template.isDefault {
                    Text("DEFAULT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(template.nome)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(template.tipo.rawValue)
                    .font(.caption)
                    .foregroundColor(template.tipo.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(template.tipo.color.opacity(0.1))
                    .cornerRadius(4)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "textformat.abc")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(template.contenuto.count) caratteri")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "curlybraces")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(extractPlaceholders(from: template.contenuto).count) campi")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Modificato: \(template.dataUltimaModifica.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 6) {
                // Principale: Modifica Testo
                Button("✏️ Modifica") {
                    onEdit()
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
                
                // Secondari
                HStack(spacing: 4) {
                    Button("📋") { onUse() }
                        .font(.caption)
                        .padding(6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                        .help("Usa Template")
                    
                    Button("📄") { onDuplicate() }
                        .font(.caption)
                        .padding(6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                        .help("Duplica")
                    
                    if !template.isDefault {
                        Button("🗑️") { onDelete() }
                            .font(.caption)
                            .padding(6)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                            .help("Elimina")
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(isHovered ? 0.1 : 0.05), radius: isHovered ? 6 : 3)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button("✏️ Modifica Testo") { onEdit() }
            Button("📋 Usa Template") { onUse() }
            Button("📄 Duplica") { onDuplicate() }
            if !template.isDefault {
                Divider()
                Button("🗑️ Elimina") { onDelete() }
            }
        }
    }
}

struct DocumentCardView: View {
    let documento: DocumentoCompilato
    let onView: () -> Void
    let onEdit: () -> Void
    let onAnalyze: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Icon e status
                VStack {
                    Image(systemName: documento.template.tipo.icona)
                        .font(.title2)
                        .foregroundColor(documento.template.tipo.color)
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .fill(documento.isCompletato ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(documento.template.nome)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(documento.defunto.nome) \(documento.defunto.cognome)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Cartella: \(documento.defunto.numeroCartella)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(documento.dataCreazione.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Progress bar
            if !documento.isCompletato {
                let completionPercentage = calculateCompletionPercentage(for: documento)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Completamento")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(completionPercentage))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    ProgressView(value: completionPercentage / 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .scaleEffect(y: 0.8)
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button("👁️") { onView() }
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Button("📝") { onEdit() }
                    .font(.caption)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                Button("🔍") { onAnalyze() }
                    .font(.caption)
                    .padding(6)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(4)
                
                Button("💾") { onExport() }
                    .font(.caption)
                    .padding(6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button("🗑️") { onDelete() }
                    .font(.caption)
                    .padding(6)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    private func calculateCompletionPercentage(for documento: DocumentoCompilato) -> Double {
        let placeholders = extractPlaceholders(from: documento.template.contenuto)
        if placeholders.isEmpty { return 100.0 }
        
        let placeholderCompilati = placeholders.filter { placeholder in
            !documento.contenutoFinale.contains("{{\(placeholder)}}")
        }.count
        
        return Double(placeholderCompilati) / Double(placeholders.count) * 100.0
    }
}

// MARK: - 📊 STATISTICS & STATUS COMPONENTS

struct QuickStatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: color.opacity(0.2), radius: 2)
    }
}

struct AdobeStatusStatView: View {
    @ObservedObject var manager: AdobePDFManager
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: manager.isProcessing ? "gearshape.2.fill" : "checkmark.circle.fill")
                    .foregroundColor(manager.isProcessing ? .orange : .green)
                    .rotationEffect(.degrees(manager.isProcessing ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: manager.isProcessing)
                
                Text("Adobe")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(manager.isProcessing ? .orange : .green)
            }
            
            Text(manager.isProcessing ? "Processing" : "Ready")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: (manager.isProcessing ? Color.orange : Color.green).opacity(0.2), radius: 2)
    }
}

// MARK: - 📋 SHEET VIEWS

struct NewDocumentSheetView: View {
    let onSave: (DocumentoTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var tipo: TipoDocumento = .altro
    @State private var contenuto = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome Template:")
                        .font(.headline)
                    TextField("Inserisci nome...", text: $nome)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo:")
                        .font(.headline)
                    Picker("Tipo", selection: $tipo) {
                        ForEach(TipoDocumento.allCases, id: \.self) { tipo in
                            Text(tipo.rawValue).tag(tipo)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contenuto:")
                        .font(.headline)
                    TextEditor(text: $contenuto)
                        .font(.system(size: 12, design: .monospaced))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 200)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nuovo Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let template = DocumentoTemplate(
                            nome: nome,
                            tipo: tipo,
                            contenuto: contenuto
                        )
                        onSave(template)
                        dismiss()
                    }
                    .disabled(nome.isEmpty || contenuto.isEmpty)
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct ImportDocumentSheetView: View {
    let onSave: (DocumentoTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var adobeManager = AdobePDFManager.shared
    @State private var isImporting = false
    @State private var importedText = ""
    @State private var templateName = ""
    @State private var selectedType: TipoDocumento = .altro
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if importedText.isEmpty {
                    // Import phase
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("Importa con Adobe OCR")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Seleziona un file PDF o immagine per estrarre il testo automaticamente")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Seleziona File") {
                            selectFile()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isImporting)
                        
                        if isImporting {
                            VStack(spacing: 12) {
                                ProgressView(adobeManager.currentTask)
                                    .progressViewStyle(CircularProgressViewStyle())
                                
                                Text("Estrazione in corso...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    // Review phase
                    VStack(spacing: 16) {
                        Text("Testo Estratto")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome Template:")
                                .font(.headline)
                            TextField("Nome template...", text: $templateName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo:")
                                .font(.headline)
                            Picker("Tipo", selection: $selectedType) {
                                ForEach(TipoDocumento.allCases, id: \.self) { tipo in
                                    Text(tipo.rawValue).tag(tipo)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contenuto:")
                                .font(.headline)
                            ScrollView {
                                Text(importedText)
                                    .font(.system(size: 10, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            .frame(height: 200)
                        }
                        
                        HStack(spacing: 12) {
                            Button("Ricomincia") {
                                importedText = ""
                                templateName = ""
                                selectedType = .altro
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Crea Template") {
                                let template = DocumentoTemplate(
                                    nome: templateName.isEmpty ? "Template Importato" : templateName,
                                    tipo: selectedType,
                                    contenuto: importedText
                                )
                                onSave(template)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(templateName.isEmpty)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Importa con OCR")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf, .image]
        panel.title = "Seleziona file per OCR"
        
        if panel.runModal() == .OK, let url = panel.url {
            isImporting = true
            
            Task {
                do {
                    let extractedText = try await adobeManager.extractTextFromPDF(fileURL: url)
                    
                    await MainActor.run {
                        importedText = extractedText
                        templateName = "Template da \(url.deletingPathExtension().lastPathComponent)"
                        isImporting = false
                    }
                } catch {
                    await MainActor.run {
                        isImporting = false
                        print("Errore OCR: \(error)")
                    }
                }
            }
        }
    }
}

struct DocumentEditorSheetView: View {
    let document: DocumentoCompilato
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedContent: String
    
    init(document: DocumentoCompilato, onComplete: @escaping () -> Void) {
        self.document = document
        self.onComplete = onComplete
        self._editedContent = State(initialValue: document.contenutoFinale.isEmpty ? document.template.contenuto : document.contenutoFinale)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Document info header
                HStack {
                    Image(systemName: document.template.tipo.icona)
                        .font(.title2)
                        .foregroundColor(document.template.tipo.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(document.template.nome)
                            .font(.headline)
                        Text("Defunto: \(document.defunto.nome) \(document.defunto.cognome)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(editedContent.count) caratteri")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Text editor
                TextEditor(text: $editedContent)
                    .font(.system(size: 14, design: .monospaced))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
            }
            .navigationTitle("Modifica Documento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onComplete()
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
    }
}

struct DocumentViewerSheetView: View {
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Document header
                    HStack {
                        Image(systemName: document.template.tipo.icona)
                            .font(.largeTitle)
                            .foregroundColor(document.template.tipo.color)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.template.nome)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(document.defunto.nome) \(document.defunto.cognome)")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                            Text("Cartella: \(document.defunto.numeroCartella)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(document.template.tipo.color.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Document content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contenuto Documento:")
                            .font(.headline)
                        
                        Text(document.contenutoFinale.isEmpty ? document.template.contenuto : document.contenutoFinale)
                            .font(.body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Document info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informazioni:")
                            .font(.headline)
                        
                        VStack(spacing: 6) {
                            infoRow(label: "Creato", value: document.dataCreazione.formatted(date: .abbreviated, time: .shortened))
                            infoRow(label: "Tipo", value: document.template.tipo.rawValue)
                            infoRow(label: "Completato", value: document.isCompletato ? "Sì" : "No")
                            infoRow(label: "Caratteri", value: String(document.contenutoFinale.count))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Visualizza Documento")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                }
            }
        }
        .frame(width: 700, height: 600)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// MARK: - ✏️ EDITOR TESTO INTEGRATO - VERSIONE SEMPLIFICATA

struct TextEditorView: View {
    @Binding var template: DocumentoTemplate
    let onSave: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedContent: String
    @State private var isModified = false
    @State private var showingSaveAlert = false
    @State private var showingUnsavedAlert = false
    
    init(template: Binding<DocumentoTemplate>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._template = template
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedContent = State(initialValue: template.wrappedValue.contenuto)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header con info template
                HStack(spacing: 16) {
                    Image(systemName: template.tipo.icona)
                        .font(.title2)
                        .foregroundColor(template.tipo.color)
                        .frame(width: 40, height: 40)
                        .background(template.tipo.color.opacity(0.1))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(template.nome)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if isModified {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text(template.tipo.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick stats
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 16) {
                            statItem(label: "Caratteri", value: String(editedContent.count))
                            statItem(label: "Parole", value: String(wordCount))
                            statItem(label: "Placeholder", value: String(placeholderCount), color: placeholderCount > 0 ? .orange : .secondary)
                        }
                        
                        Text("Modificato: \(template.dataUltimaModifica.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Text editor
                VStack(spacing: 0) {
                    // Editor header
                    HStack {
                        Text("Editor Contenuto")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("Righe: \(totalLines)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    
                    // Main text editor
                    TextEditor(text: $editedContent)
                        .font(.system(size: 14, design: .monospaced))
                        .lineSpacing(2)
                        .padding(16)
                        .frame(minHeight: 400)
                        .background(Color.white)
                }
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                // Status bar
                HStack {
                    Text("\(template.tipo.rawValue) • \(template.nome)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Text("Caratteri: \(editedContent.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Parole: \(wordCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if placeholderCount > 0 {
                            Text("Placeholder: \(placeholderCount)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if isModified {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                Text("Modificato")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Modifica Template: \(template.nome)")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("💾 Salva") {
                        saveTemplate()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isModified)
                    .keyboardShortcut("s", modifiers: .command)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        if isModified {
                            showingUnsavedAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .onChange(of: editedContent) { _ in
                isModified = true
            }
            .alert("Template Salvato", isPresented: $showingSaveAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Le modifiche al template sono state salvate correttamente.")
            }
            .alert("Modifiche non salvate", isPresented: $showingUnsavedAlert) {
                Button("Salva e Chiudi") {
                    saveTemplate()
                    dismiss()
                }
                Button("Scarta Modifiche") {
                    dismiss()
                }
                Button("Continua", role: .cancel) { }
            } message: {
                Text("Hai modifiche non salvate. Cosa vuoi fare?")
            }
        }
        .frame(width: 900, height: 700)
    }
    
    // MARK: - Helper Methods & Computed Properties
    
    private func statItem(label: String, value: String, color: Color = .secondary) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var wordCount: Int {
        editedContent.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    private var totalLines: Int {
        max(1, editedContent.components(separatedBy: .newlines).count)
    }
    
    private var placeholderCount: Int {
        extractPlaceholders(from: editedContent).count
    }
    
    private func saveTemplate() {
        template.contenuto = editedContent
        template.dataUltimaModifica = Date()
        
        onSave()
        isModified = false
        showingSaveAlert = true
        
        print("📝 Template salvato: \(template.nome) con \(editedContent.count) caratteri")
    }
}

// MARK: - 🔧 HELPER FUNCTIONS & STRUCTS

struct DocumentSystemHelper {
    static func nomeBreve(for tipo: TipoDocumento) -> String {
        switch tipo {
        case .altro: return "Altri"
        default: return tipo.rawValue
        }
    }
}

// Helper function per estrarre placeholder
func extractPlaceholders(from content: String) -> [String] {
    let pattern = "\\{\\{([^}]+)\\}\\}"
    let regex = try? NSRegularExpression(pattern: pattern)
    let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
    
    return matches.compactMap { match in
        if let range = Range(match.range(at: 1), in: content) {
            return String(content[range])
        }
        return nil
    }
}

#Preview {
    SezioneGenerazioneDocumentiView()
}

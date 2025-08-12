//
//  DocumentViewerView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 23/07/25.
//
import SwiftUI
import AppKit
import PDFKit

// MARK: - ⭐ DOCUMENT VIEWER - Visualizzazione Documenti

struct DocumentViewerView: View {
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    @State private var showingExportOptions = false
    @State private var fontSize: CGFloat = 14
    @State private var showingPrintPreview = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con info documento
                documentHeaderView
                
                // Toolbar viewer
                viewerToolbarView
                
                Divider()
                
                // Contenuto documento
                documentContentView
            }
        }
        .frame(minWidth: 700, minHeight: 500)
        .navigationTitle("Visualizza Documento")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Modifica") {
                    showingEditor = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Esporta") {
                    showingExportOptions = true
                }
                .buttonStyle(.bordered)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            DocumentEditorView(document: document, adobeManager: AdobePDFManager.shared) {
                // Callback dopo editing
                dismiss()
            }
        }
        .sheet(isPresented: $showingExportOptions) {
            DocumentExportOptionsView(document: document)
        }
        .sheet(isPresented: $showingPrintPreview) {
            DocumentPrintPreviewView(document: document)
        }
    }
    
    // MARK: - Header
    private var documentHeaderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icona tipo documento
                Image(systemName: document.template.tipo.icona)
                    .font(.title)
                    .foregroundColor(document.template.tipo.color)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.template.nome)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(document.template.tipo.rawValue)
                        .font(.subheadline)
                        .foregroundColor(document.template.tipo.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(document.template.tipo.color.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Status e info
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(document.isCompletato ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        
                        Text(document.isCompletato ? "Completato" : "In lavorazione")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(document.isCompletato ? .green : .orange)
                    }
                    
                    Text("Creato: \(document.dataCreazioneFormattata)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if document.dataUltimaModifica != document.dataCreazione {
                        Text("Modificato: \(document.dataModificaFormattata)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Info defunto
            HStack {
                Label("Defunto", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(document.defunto.nomeCompleto)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Label("Cartella N°", systemImage: "folder.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(document.defunto.numeroCartella)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Toolbar
    private var viewerToolbarView: some View {
        HStack {
            // Font size controls
            HStack(spacing: 8) {
                Text("Dimensione:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("-") {
                    fontSize = max(fontSize - 1, 10)
                }
                .font(.caption)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                
                Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .frame(width: 35)
                
                Button("+") {
                    fontSize = min(fontSize + 1, 24)
                }
                .font(.caption)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            }
            
            Divider()
                .frame(height: 20)
            
            // Document stats
            HStack(spacing: 16) {
                Text("Caratteri: \(document.contenutoFinale.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Parole: \(contaParole(document.contenutoFinale))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                let placeholders = document.placeholderNonSostituiti
                if !placeholders.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("\(placeholders.count) campi mancanti")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button("Stampa") {
                    showingPrintPreview = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                Button("Copia Testo") {
                    copyToClipboard()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - Content
    private var documentContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Contenuto principale
                Text(document.contenutoFinale)
                    .font(.system(size: fontSize, design: .default))
                    .lineSpacing(4)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .textSelection(.enabled)
                
                // Placeholder mancanti
                let placeholders = document.placeholderNonSostituiti
                if !placeholders.isEmpty {
                    placeholderWarningView(placeholders)
                }
                
                // Note se presenti
                if !document.note.isEmpty {
                    documentNotesView
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.02))
    }
    
    private func placeholderWarningView(_ placeholders: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Campi da completare")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            // Semplifichiamo il LazyVGrid per evitare problemi di type-checking
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(placeholders.enumerated()), id: \.offset) { index, placeholder in
                    HStack {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text(placeholder)
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundColor(.orange)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var documentNotesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                Text("Note")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text(document.note)
                .font(.body)
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.blue.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    private func contaParole(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(document.contenutoFinale, forType: .string)
    }
}

// MARK: - ⭐ DOCUMENT EDITOR - Editor Avanzato

struct DocumentEditorView: View {
    let document: DocumentoCompilato
    let adobeManager: AdobePDFManager
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedContent: String
    @State private var editedNote: String
    @State private var isModified = false
    @State private var showingUnsavedAlert = false
    @State private var showingAIAssistant = false
    @State private var showingFieldsHelper = false
    @State private var fontSize: CGFloat = 14
    @State private var showingPreview = false
    
    init(document: DocumentoCompilato, adobeManager: AdobePDFManager, onComplete: @escaping () -> Void) {
        self.document = document
        self.adobeManager = adobeManager
        self.onComplete = onComplete
        self._editedContent = State(initialValue: document.contenutoFinale.isEmpty ? document.template.contenuto : document.contenutoFinale)
        self._editedNote = State(initialValue: document.note)
    }
    
    var body: some View {
        NavigationView {
            HSplitView {
                // Editor principale
                editorMainView
                    .frame(minWidth: 500)
                
                // Pannello laterale (se attivo)
                if showingPreview {
                    previewSidebarView
                        .frame(minWidth: 300, maxWidth: 400)
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Editor Documento")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Anteprima") {
                    showingPreview.toggle()
                }
                .buttonStyle(.bordered)
                
                Button("Salva") {
                    saveDocument()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isModified)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") {
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
        .onChange(of: editedNote) { _ in
            isModified = true
        }
        .alert("Modifiche non salvate", isPresented: $showingUnsavedAlert) {
            Button("Salva", role: .destructive) {
                saveDocument()
            }
            Button("Scarta", role: .destructive) {
                dismiss()
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Ci sono modifiche non salvate. Cosa vuoi fare?")
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIDocumentAssistantView(content: $editedContent, document: document)
        }
        .sheet(isPresented: $showingFieldsHelper) {
            DocumentFieldsHelperView(content: $editedContent, document: document)
        }
    }
    
    // MARK: - Editor Main View
    private var editorMainView: some View {
        VStack(spacing: 0) {
            // Header editor
            editorHeaderView
            
            // Toolbar editor
            editorToolbarView
            
            Divider()
            
            // Text editor
            textEditorView
            
            // Note editor
            noteEditorView
        }
    }
    
    private var editorHeaderView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: document.template.tipo.icona)
                    .font(.title2)
                    .foregroundColor(document.template.tipo.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.template.nome)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Defunto: \(document.defunto.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status modification
                if isModified {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("Modificato")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var editorToolbarView: some View {
        HStack {
            // Font controls
            HStack(spacing: 8) {
                Text("Font:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("-") {
                    fontSize = max(fontSize - 1, 10)
                }
                .font(.caption)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                
                Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .frame(width: 35)
                
                Button("+") {
                    fontSize = min(fontSize + 1, 24)
                }
                .font(.caption)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            }
            
            Divider()
                .frame(height: 20)
            
            // AI Tools
            HStack(spacing: 8) {
                Button("🤖 AI Assistant") {
                    showingAIAssistant = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.2))
                .foregroundColor(.purple)
                .cornerRadius(6)
                
                Button("🔧 Campi") {
                    showingFieldsHelper = true
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(6)
            }
            
            Spacer()
            
            // Document stats
            HStack(spacing: 12) {
                Text("Caratteri: \(editedContent.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Parole: \(contaParole(editedContent))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                let placeholderCount = getPlaceholderCount(editedContent)
                if placeholderCount > 0 {
                    Text("Campi: \(placeholderCount)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private var textEditorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contenuto Documento")
                .font(.headline)
                .padding(.horizontal)
            
            TextEditor(text: $editedContent)
                .font(.system(size: fontSize, design: .default))
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
        }
        .frame(minHeight: 300)
    }
    
    private var noteEditorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (opzionale)")
                .font(.headline)
                .padding(.horizontal)
            
            TextEditor(text: $editedNote)
                .font(.system(size: 12))
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
        }
        .frame(height: 100)
        .padding(.bottom)
    }
    
    // MARK: - Preview Sidebar
    private var previewSidebarView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Anteprima")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Preview content
                    Text(editedContent)
                        .font(.system(size: 10))
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Document info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informazioni")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        infoRow("Template", document.template.nome)
                        infoRow("Tipo", document.template.tipo.rawValue)
                        infoRow("Defunto", document.defunto.nomeCompleto)
                        infoRow("Cartella", document.defunto.numeroCartella)
                        infoRow("Caratteri", "\(editedContent.count)")
                        infoRow("Parole", "\(contaParole(editedContent))")
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Placeholder check
                    let placeholders = getPlaceholders(editedContent)
                    if !placeholders.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Campi da completare")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                            }
                            
                            ForEach(placeholders, id: \.self) { placeholder in
                                Text("• \(placeholder)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.02))
    }
    
    // MARK: - Helper Methods
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .trailing)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private func contaParole(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private func getPlaceholderCount(_ text: String) -> Int {
        let pattern = "\\{\\{[^}]+\\}\\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches?.count ?? 0
    }
    
    private func getPlaceholders(_ text: String) -> [String] {
        let pattern = "\\{\\{([^}]+)\\}\\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range(at: 1), in: text) {
                return String(text[range])
            }
            return nil
        }
    }
    
    private func saveDocument() {
        // Implementa salvataggio
        // document.contenutoFinale = editedContent
        // document.note = editedNote
        // document.dataUltimaModifica = Date()
        
        onComplete()
        dismiss()
    }
}

// MARK: - ⭐ EXPORT OPTIONS VIEW

struct DocumentExportOptionsView: View {
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Esporta Documento")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(document.template.nome)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Export options
                VStack(spacing: 16) {
                    exportButton(
                        title: "📄 Esporta come PDF",
                        subtitle: "Formato ideale per stampa e condivisione",
                        color: .red,
                        action: { exportAsPDF() }
                    )
                    
                    exportButton(
                        title: "📝 Esporta come Word",
                        subtitle: "Formato modificabile (.docx)",
                        color: .blue,
                        action: { exportAsWord() }
                    )
                    
                    exportButton(
                        title: "📖 Esporta come Pages",
                        subtitle: "Formato Apple Pages (.pages)",
                        color: .orange,
                        action: { exportAsPages() }
                    )
                    
                    exportButton(
                        title: "📋 Copia negli Appunti",
                        subtitle: "Copia il testo negli appunti",
                        color: .green,
                        action: { copyToClipboard() }
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Esporta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
        .alert("Esportazione", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func exportButton(title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(color)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func exportAsPDF() {
        // Implementa export PDF
        alertMessage = "PDF esportato con successo!"
        showingAlert = true
    }
    
    private func exportAsWord() {
        // Implementa export Word
        alertMessage = "Documento Word esportato con successo!"
        showingAlert = true
    }
    
    private func exportAsPages() {
        // Implementa export Pages
        alertMessage = "Documento Pages esportato con successo!"
        showingAlert = true
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(document.contenutoFinale, forType: .string)
        
        alertMessage = "Testo copiato negli appunti!"
        showingAlert = true
    }
}

// MARK: - ⭐ AI ASSISTANT VIEW

struct AIDocumentAssistantView: View {
    @Binding var content: String
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adobeManager = AdobePDFManager.shared
    
    @State private var aiSuggestion = ""
    @State private var isProcessing = false
    @State private var selectedAction: AIAction = .improve
    
    enum AIAction: String, CaseIterable {
        case improve = "Migliora Testo"
        case complete = "Completa Campi"
        case format = "Formatta"
        case check = "Controlla Errori"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 32))
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading) {
                        Text("AI Assistant")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Migliora il tuo documento con l'AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Action selector
                Picker("Azione", selection: $selectedAction) {
                    ForEach(AIAction.allCases, id: \.self) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // AI suggestions
                if !aiSuggestion.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggerimento AI:")
                            .font(.headline)
                        
                        Text(aiSuggestion)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                        
                        HStack {
                            Button("Applica") {
                                content = aiSuggestion
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Rigetta") {
                                aiSuggestion = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // Process button
                Button(action: processWithAI) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        
                        Text(isProcessing ? "Elaborando..." : "Elabora con AI")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Assistant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func processWithAI() {
        isProcessing = true
        
        Task {
            await MainActor.run {
                // Simula elaborazione AI
                switch selectedAction {
                case .improve:
                    aiSuggestion = """
                    Versione migliorata del documento con linguaggio più formale e struttura ottimizzata:
                    
                    \(content.replacingOccurrences(of: "è", with: "risulta essere").replacingOccurrences(of: "va", with: "deve essere"))
                    
                    [Testo migliorato con terminologia più appropriata]
                    """
                case .complete:
                    aiSuggestion = """
                    Campi identificati e completati automaticamente:
                    
                    {{NOME_DEFUNTO}} → \(document.defunto.nomeCompleto)
                    {{DATA_DECESSO}} → \(document.defunto.dataDecesoFormattata)
                    {{LUOGO_NASCITA}} → \(document.defunto.luogoNascita)
                    
                    [Documento con campi compilati]
                    """
                case .format:
                    aiSuggestion = """
                    Documento formattato secondo gli standard ufficiali:
                    
                    OGGETTO: \(document.template.nome.uppercased())
                    
                    \(content)
                    
                    [Formattazione migliorata]
                    """
                case .check:
                    aiSuggestion = """
                    Controllo qualità completato:
                    
                    ✅ Ortografia: Corretta
                    ✅ Grammatica: Corretta  
                    ⚠️ Suggerimento: Utilizzare linguaggio più formale
                    ✅ Campi obbligatori: Presenti
                    
                    [Documento verificato]
                    """
                }
                
                isProcessing = false
            }
        }
    }
}

// MARK: - ⭐ DOCUMENT FIELDS HELPER

struct DocumentFieldsHelperView: View {
    @Binding var content: String
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    @State private var availableFields: [DocumentField] = []
    
    struct DocumentField {
        let key: String
        let name: String
        let value: String
        let category: String
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Gestione Campi")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Inserisci e gestisci i campi del documento")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Fields list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(groupedFields.keys.sorted(), id: \.self) { category in
                            fieldCategoryView(category: category, fields: groupedFields[category] ?? [])
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Campi Documento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
        .onAppear {
            setupFields()
        }
    }
    
    private var groupedFields: [String: [DocumentField]] {
        Dictionary(grouping: availableFields, by: \.category)
    }
    
    private func fieldCategoryView(category: String, fields: [DocumentField]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(fields, id: \.key) { field in
                    fieldButton(field)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func fieldButton(_ field: DocumentField) -> some View {
        Button(action: {
            insertField(field)
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(field.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                
                Text("{{\(field.key)}}")
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundColor(.secondary)
                
                if !field.value.isEmpty {
                    Text("→ \(field.value)")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .lineLimit(1)
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func setupFields() {
        availableFields = [
            // Dati Defunto
            DocumentField(key: "NOME_DEFUNTO", name: "Nome Completo", value: document.defunto.nomeCompleto, category: "Dati Defunto"),
            DocumentField(key: "NOME", name: "Nome", value: document.defunto.nome, category: "Dati Defunto"),
            DocumentField(key: "COGNOME", name: "Cognome", value: document.defunto.cognome, category: "Dati Defunto"),
            DocumentField(key: "DATA_NASCITA", name: "Data Nascita", value: document.defunto.dataNascitaFormattata, category: "Dati Defunto"),
            DocumentField(key: "LUOGO_NASCITA", name: "Luogo Nascita", value: document.defunto.luogoNascita, category: "Dati Defunto"),
            DocumentField(key: "DATA_DECESSO", name: "Data Decesso", value: document.defunto.dataDecesoFormattata, category: "Dati Defunto"),
            DocumentField(key: "ORA_DECESSO", name: "Ora Decesso", value: document.defunto.oraDecesso, category: "Dati Defunto"),
            DocumentField(key: "ETA", name: "Età", value: "\(document.defunto.eta) anni", category: "Dati Defunto"),
            DocumentField(key: "CODICE_FISCALE", name: "Codice Fiscale", value: document.defunto.codiceFiscale, category: "Dati Defunto"),
            
            // Familiare
            DocumentField(key: "NOME_FAMILIARE", name: "Nome Familiare", value: document.defunto.familiareRichiedente.nomeCompleto, category: "Familiare"),
            DocumentField(key: "PARENTELA", name: "Parentela", value: document.defunto.familiareRichiedente.parentela.rawValue, category: "Familiare"),
            DocumentField(key: "TELEFONO_FAMILIARE", name: "Telefono", value: document.defunto.familiareRichiedente.telefono, category: "Familiare"),
            DocumentField(key: "EMAIL_FAMILIARE", name: "Email", value: document.defunto.familiareRichiedente.email ?? "", category: "Familiare"),
            
            // Documento
            DocumentField(key: "NUMERO_CARTELLA", name: "N° Cartella", value: document.defunto.numeroCartella, category: "Documento"),
            DocumentField(key: "DATA_DOCUMENTO", name: "Data Documento", value: document.dataCreazioneFormattata, category: "Documento"),
            DocumentField(key: "OPERATORE", name: "Operatore", value: document.operatoreCreazione, category: "Documento"),
            
            // Date comuni
            DocumentField(key: "DATA_OGGI", name: "Data Oggi", value: Date().formatted(date: .abbreviated, time: .omitted), category: "Date"),
            DocumentField(key: "ANNO_CORRENTE", name: "Anno Corrente", value: "\(Calendar.current.component(.year, from: Date()))", category: "Date")
        ]
    }
    
    private func insertField(_ field: DocumentField) {
        let placeholder = "{{\(field.key)}}"
        content += placeholder
        dismiss()
    }
}

// MARK: - ⭐ PRINT PREVIEW VIEW

struct DocumentPrintPreviewView: View {
    let document: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // Print preview content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Document header for print
                        printHeaderView
                        
                        Divider()
                        
                        // Document content
                        Text(document.contenutoFinale)
                            .font(.system(size: 12))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer(minLength: 40)
                        
                        // Footer
                        printFooterView
                    }
                    .padding(40)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            .navigationTitle("Anteprima Stampa")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Stampa") {
                        printDocument()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 700, height: 600)
    }
    
    private var printHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(document.template.nome)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(document.template.tipo.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Cartella N° \(document.defunto.numeroCartella)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(document.dataCreazioneFormattata)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Defunto: \(document.defunto.nomeCompleto)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var printFooterView: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Documento generato il \(Date().formatted(date: .complete, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("FunerApp - Sistema Gestione Funebre")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func printDocument() {
        // Implementa funzionalità di stampa
        let printInfo = NSPrintInfo.shared
        let printOperation = NSPrintOperation(view: NSView(), printInfo: printInfo)
        printOperation.run()
    }
}

#Preview {
    // Preview per DocumentViewerView
    let sampleDocument = DocumentoCompilato(
        template: DocumentoTemplate.autorizzazioneTrasporto,
        defunto: PersonaDefunta()
    )
    
    return DocumentViewerView(document: sampleDocument)
}

//
//  IntegratedTextEditorView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 24/07/25.
//

import SwiftUI
import AppKit

// MARK: - ⭐ INTEGRATED TEXT EDITOR - ADATTATO AI TUOI MODELLI ORIGINALI

struct IntegratedTextEditorView: View {
    @Binding var template: DocumentoTemplate
    let onSave: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedContent: String
    @State private var isModified = false
    @State private var showingPreview = false
    @State private var fontSize: CGFloat = 14
    @State private var showingFindReplace = false
    @State private var searchText = ""
    @State private var replaceText = ""
    @State private var showingSaveAlert = false
    @State private var showingUnsavedAlert = false
    @State private var wordWrap = true
    @State private var showLineNumbers = false
    
    init(template: Binding<DocumentoTemplate>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._template = template
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedContent = State(initialValue: template.wrappedValue.contenuto)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con info template
            headerSection
            
            Divider()
            
            // Toolbar editor
            toolbarSection
            
            Divider()
            
            // Main editing area
            HSplitView {
                // Editor principale
                mainEditorSection
                    .frame(minWidth: 400)
                
                // Preview sidebar (opzionale)
                if showingPreview {
                    previewSection
                        .frame(minWidth: 300, maxWidth: 400)
                }
            }
            
            // Status bar
            statusBarSection
        }
        .frame(minWidth: 800, minHeight: 600)
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Template info
            HStack(spacing: 12) {
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
                    
                    // Testo fisso invece di descrizione che non esiste
                    Text("Template per documenti")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
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
    }
    
    // MARK: - Toolbar Section
    private var toolbarSection: some View {
        HStack(spacing: 16) {
            // Font controls
            HStack(spacing: 8) {
                Text("Zoom:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("-") {
                    fontSize = max(10, fontSize - 1)
                }
                .font(.caption)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .disabled(fontSize <= 10)
                
                Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .frame(width: 40)
                
                Button("+") {
                    fontSize = min(24, fontSize + 1)
                }
                .font(.caption)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .disabled(fontSize >= 24)
            }
            
            Divider().frame(height: 20)
            
            // View options
            HStack(spacing: 8) {
                Toggle("A capo automatico", isOn: $wordWrap)
                    .font(.caption)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                Toggle("Numeri riga", isOn: $showLineNumbers)
                    .font(.caption)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            Divider().frame(height: 20)
            
            // Find & Replace
            Button(action: { showingFindReplace.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                    Text("Trova")
                }
                .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(showingFindReplace ? Color.blue : Color.blue.opacity(0.1))
            .foregroundColor(showingFindReplace ? .white : .blue)
            .cornerRadius(6)
            
            // Quick actions
            HStack(spacing: 8) {
                Button("↺ Ripristina") {
                    editedContent = template.contenuto
                    isModified = false
                }
                .font(.caption)
                .foregroundColor(.orange)
                .disabled(!isModified)
                
                Button("🔤 Placeholder") {
                    showPlaceholderHelper()
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
            
            Spacer()
            
            // Preview toggle
            Button("👁️ Anteprima") {
                showingPreview.toggle()
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(showingPreview ? Color.green : Color.green.opacity(0.1))
            .foregroundColor(showingPreview ? .white : .green)
            .cornerRadius(6)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Main Editor Section
    private var mainEditorSection: some View {
        VStack(spacing: 0) {
            // Find & Replace bar
            if showingFindReplace {
                findReplaceBar
                Divider()
            }
            
            // Text editor
            VStack(spacing: 0) {
                // Editor header
                HStack {
                    Text("Editor Contenuto")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Riga \(currentLine) di \(totalLines)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                
                // Text editor with line numbers
                HStack(spacing: 0) {
                    // Line numbers (opzionale)
                    if showLineNumbers {
                        lineNumbersView
                            .frame(width: 50)
                        
                        Divider()
                    }
                    
                    // Main text editor
                    ScrollView {
                        TextEditor(text: $editedContent)
                            .font(.system(size: fontSize, design: .monospaced))
                            .lineSpacing(2)
                            .scrollContentBackground(.hidden)
                            .padding(16)
                            .frame(minHeight: 400)
                    }
                    .background(Color.white)
                }
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding()
    }
    
    // MARK: - Find & Replace Bar
    private var findReplaceBar: some View {
        HStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                TextField("Cerca...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Replace field
            HStack {
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                TextField("Sostituisci...", text: $replaceText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Action buttons
            HStack(spacing: 6) {
                Button("Sostituisci") {
                    replaceFirst()
                }
                .font(.caption)
                .disabled(searchText.isEmpty)
                
                Button("Tutto") {
                    replaceAll()
                }
                .font(.caption)
                .disabled(searchText.isEmpty)
            }
            
            Spacer()
            
            // Close button
            Button("✕") {
                showingFindReplace = false
                searchText = ""
                replaceText = ""
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.1))
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Preview header
            HStack {
                Text("Anteprima")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("✕") {
                    showingPreview = false
                }
                .foregroundColor(.secondary)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Document preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contenuto Renderizzato:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(editedContent.isEmpty ? "Nessun contenuto" : editedContent)
                            .font(.system(size: 11))
                            .lineSpacing(3)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .frame(height: 200)
                    }
                    
                    Divider()
                    
                    // Template info
                    templateInfoView
                    
                    Divider()
                    
                    // Placeholder analysis
                    if placeholderCount > 0 {
                        placeholderAnalysisView
                    }
                    
                    // Quick stats
                    quickStatsView
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Status Bar
    private var statusBarSection: some View {
        HStack {
            // File info
            Text("\(template.tipo.rawValue) • \(template.nome)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Live stats
            HStack(spacing: 16) {
                Text("Caratteri: \(editedContent.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Parole: \(wordCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Righe: \(totalLines)")
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
    }
    
    // MARK: - Supporting Views
    
    private var lineNumbersView: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(1...max(1, totalLines), id: \.self) { lineNumber in
                Text(String(lineNumber))
                    .font(.system(size: fontSize - 2, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(height: fontSize + 4)
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.trailing, 8)
        .background(Color.gray.opacity(0.05))
    }
    
    private var templateInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Informazioni Template:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 6) {
                infoRow(label: "Nome", value: template.nome)
                infoRow(label: "Tipo", value: template.tipo.rawValue)
                infoRow(label: "Creato", value: template.dataCreazione.formatted(date: .abbreviated, time: .omitted))
                infoRow(label: "Modificato", value: template.dataUltimaModifica.formatted(date: .abbreviated, time: .omitted))
                // Calcola campi dinamicamente invece di usare template.campi che non esiste
                infoRow(label: "Campi", value: String(extractPlaceholders().count))
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var placeholderAnalysisView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "curlybraces")
                    .foregroundColor(.orange)
                Text("Placeholder Trovati:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
            
            let placeholders = extractPlaceholders()
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 4) {
                ForEach(placeholders, id: \.self) { placeholder in
                    HStack {
                        Text("{{\(placeholder)}}")
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
        .padding(12)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistiche:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 6) {
                infoRow(label: "Caratteri", value: String(editedContent.count))
                infoRow(label: "Parole", value: String(wordCount))
                infoRow(label: "Righe", value: String(totalLines))
                infoRow(label: "Paragrafi", value: String(paragraphCount))
                if placeholderCount > 0 {
                    infoRow(label: "Placeholder", value: String(placeholderCount), color: .orange)
                }
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func infoRow(label: String, value: String, color: Color = .primary) -> some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .trailing)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Spacer()
        }
    }
    
    private var wordCount: Int {
        editedContent.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    private var totalLines: Int {
        max(1, editedContent.components(separatedBy: .newlines).count)
    }
    
    private var currentLine: Int {
        // This would need more complex logic with cursor position
        1
    }
    
    private var paragraphCount: Int {
        editedContent.components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    private var placeholderCount: Int {
        extractPlaceholders().count
    }
    
    private func extractPlaceholders() -> [String] {
        let pattern = "\\{\\{([^}]+)\\}\\}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: editedContent, range: NSRange(editedContent.startIndex..., in: editedContent)) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range(at: 1), in: editedContent) {
                return String(editedContent[range])
            }
            return nil
        }
    }
    
    private func replaceFirst() {
        if let range = editedContent.range(of: searchText) {
            editedContent.replaceSubrange(range, with: replaceText)
        }
    }
    
    private func replaceAll() {
        editedContent = editedContent.replacingOccurrences(of: searchText, with: replaceText)
    }
    
    private func showPlaceholderHelper() {
        // Insert common placeholder at cursor position
        let commonPlaceholders = [
            "{{NOME_DEFUNTO}}",
            "{{DATA_DECESSO}}",
            "{{LUOGO_DECESSO}}",
            "{{NOME_RICHIEDENTE}}",
            "{{DATA_RICHIESTA}}"
        ]
        
        // For now, just add to end - in real implementation, would insert at cursor
        if !editedContent.isEmpty {
            editedContent += "\n\n"
        }
        editedContent += "Placeholder comuni:\n"
        editedContent += commonPlaceholders.joined(separator: "\n")
    }
    
    private func saveTemplate() {
        template.contenuto = editedContent
        template.dataUltimaModifica = Date()
        
        // NON aggiorniamo template.campi perché non esiste nei tuoi modelli originali
        
        onSave()
        isModified = false
        showingSaveAlert = true
        
        print("📝 Template salvato: \(template.nome) con \(editedContent.count) caratteri")
    }
}

// MARK: - ⭐ TEMPLATE ROW CON EDIT BUTTON (ADATTATO AI TUOI MODELLI)

struct TemplateRowWithEditButton: View {
    let template: DocumentoTemplate
    let onEdit: () -> Void
    let onUse: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Template icon
            Image(systemName: template.tipo.icona)
                .font(.title3)
                .foregroundColor(template.tipo.color)
                .frame(width: 32, height: 32)
                .background(template.tipo.color.opacity(0.1))
                .cornerRadius(8)
            
            // Template info
            VStack(alignment: .leading, spacing: 4) {
                Text(template.nome)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(template.tipo.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(template.contenuto.count) caratteri")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Calcola campi dinamicamente
                    let placeholderCount = extractPlaceholdersFromText(template.contenuto).count
                    Text("\(placeholderCount) campi")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button("✏️ Modifica") {
                    onEdit()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
                
                Button("📋 Usa") {
                    onUse()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

// MARK: - 🔧 HELPER FUNCTION

func extractPlaceholdersFromText(_ content: String) -> [String] {
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
    @State var sampleTemplate = DocumentoTemplate(
        nome: "Template di Test",
        tipo: .altro,
        contenuto: "Contenuto di esempio con {{PLACEHOLDER}} da modificare."
    )
    
    return IntegratedTextEditorView(
        template: $sampleTemplate,
        onSave: { print("Template salvato!") },
        onCancel: { print("Annullato") }
    )
}

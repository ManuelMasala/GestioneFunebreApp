//
//  DocumentPopupView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 25/07/25.
//

import SwiftUI

// MARK: - ⭐ DOCUMENT POPUP OVERLAY PRINCIPALE

struct DocumentPopupOverlay: View {
    @ObservedObject var popupManager = DocumentPopupManager.shared
    @ObservedObject var adobeManager = AdobePDFManager.shared
    
    var body: some View {
        ZStack {
            // Background overlay
            if popupManager.showTemplateSelectionPopup ||
               popupManager.showFieldEditingPopup ||
               popupManager.showDocumentPreview ||
               popupManager.showExtractionResult {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeAllPopups()
                    }
            }
            
            // Template Selection
            if popupManager.showTemplateSelectionPopup {
                PopupTemplateSelection(popupManager: popupManager)
            }
            
            // Field Editing
            if popupManager.showFieldEditingPopup {
                PopupFieldEditing(popupManager: popupManager)
            }
            
            // Document Preview
            if popupManager.showDocumentPreview {
                PopupDocumentPreview(
                    popupManager: popupManager,
                    adobeManager: adobeManager
                )
            }
            
            // Extraction Result
            if popupManager.showExtractionResult {
                PopupExtractionResult(
                    popupManager: popupManager,
                    extractedText: popupManager.extractedContent,
                    fileName: popupManager.lastProcessedFileName
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: popupManager.showTemplateSelectionPopup)
        .animation(.easeInOut(duration: 0.3), value: popupManager.showFieldEditingPopup)
        .animation(.easeInOut(duration: 0.3), value: popupManager.showDocumentPreview)
        .animation(.easeInOut(duration: 0.3), value: popupManager.showExtractionResult)
    }
    
    private func closeAllPopups() {
        popupManager.showTemplateSelectionPopup = false
        popupManager.showFieldEditingPopup = false
        popupManager.showDocumentPreview = false
        popupManager.showExtractionResult = false
    }
}

// MARK: - ⭐ TEMPLATE SELECTION

struct PopupTemplateSelection: View {
    @ObservedObject var popupManager: DocumentPopupManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Seleziona Tipo Documento")
                        .font(.headline)
                    Text("File: \(popupManager.lastProcessedFileName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("✕") {
                    popupManager.showTemplateSelectionPopup = false
                }
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            // ✅ CORREZIONE ERRORE 107, 109: Conversione esplicita per compatibilità
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(TipoDocumento.allCases, id: \.self) { tipo in
                    PopupTemplateCard(
                        tipo: tipo,
                        isSelected: popupManager.selectedTemplate.rawValue == tipo.rawValue
                    ) {
                        // ✅ CORREZIONE: Converti TipoDocumento a PopupTipoDocumento
                        if let popupTipo = PopupTipoDocumento(rawValue: tipo.rawValue) {
                            popupManager.selectedTemplate = popupTipo
                        }
                    }
                }
            }
            
            Divider()
            
            // Actions
            HStack {
                Button("Annulla") {
                    popupManager.showTemplateSelectionPopup = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Continua") {
                    popupManager.proceedWithTemplate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(popupManager.selectedTemplate == .altro)
            }
        }
        .padding(20)
        .frame(width: 500, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}

struct PopupTemplateCard: View {
    let tipo: TipoDocumento
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconForType(tipo))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(tipo.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    // ✅ CORREZIONE ERRORE 172: Switch exhaustive con tutti i casi di TipoDocumento
    private func iconForType(_ tipo: TipoDocumento) -> String {
        switch tipo {
        case .autorizzazioneTrasporto:
            return "car"
        case .comunicazioneParrocchia:
            return "building.2"
        case .fattura:
            return "doc.text.below.ecg"
        case .contratto:
            return "doc.text"
        case .certificatoMorte:
            return "doc.badge.plus"
        case .checklistFunerale:
            return "list.bullet.clipboard"
        case .ricevuta:
            return "receipt"
        case .altro:
            return "doc.questionmark"
        // ✅ Aggiungi eventuali altri casi se ne mancano
        @unknown default:
            return "doc.questionmark"
        }
    }
}

// MARK: - ⭐ FIELD EDITING

struct PopupFieldEditing: View {
    @ObservedObject var popupManager: DocumentPopupManager
    @State private var searchText = ""
    
    var filteredFields: [(String, String)] {
        let fields = Array(popupManager.documentFields.sorted(by: { $0.key < $1.key }))
        if searchText.isEmpty {
            return fields
        } else {
            return fields.filter { $0.0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Compila Campi Documento")
                        .font(.headline)
                    Text(popupManager.selectedTemplate.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("✕") {
                    popupManager.showFieldEditingPopup = false
                }
                .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Cerca campo...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Fields List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredFields, id: \.0) { field in
                        PopupFieldRow(
                            key: field.0,
                            value: field.1,
                            popupManager: popupManager
                        )
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400)
            
            Divider()
            
            // Actions
            HStack {
                Button("Indietro") {
                    popupManager.showFieldEditingPopup = false
                    popupManager.showTemplateSelectionPopup = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Anteprima Documento") {
                    popupManager.generateFinalDocument()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 600, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
}

struct PopupFieldRow: View {
    let key: String
    let value: String
    @ObservedObject var popupManager: DocumentPopupManager
    @State private var editedValue: String
    
    init(key: String, value: String, popupManager: DocumentPopupManager) {
        self.key = key
        self.value = value
        self.popupManager = popupManager
        self._editedValue = State(initialValue: value)
    }
    
    var displayKey: String {
        key.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(displayKey)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isRequired(key) {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            if isMultiline(key) {
                TextEditor(text: $editedValue)
                    .frame(height: 60)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField("Inserisci \(displayKey.lowercased())", text: $editedValue)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .onChange(of: editedValue) { _, newValue in
            popupManager.updateField(key: key, value: newValue)
        }
    }
    
    private func isRequired(_ key: String) -> Bool {
        let requiredFields = ["NOME_DEFUNTO", "COGNOME_DEFUNTO", "DATA_DECESSO", "COMUNE"]
        return requiredFields.contains(key)
    }
    
    private func isMultiline(_ key: String) -> Bool {
        let multilineFields = ["CONTENUTO_PRINCIPALE", "NOTE_AGGIUNTIVE", "DESCRIZIONE_SERVIZI", "NOTE"]
        return multilineFields.contains(key)
    }
}

// MARK: - ⭐ DOCUMENT PREVIEW

struct PopupDocumentPreview: View {
    @ObservedObject var popupManager: DocumentPopupManager
    @ObservedObject var adobeManager: AdobePDFManager
    @State private var isGeneratingPDF = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Anteprima Documento")
                        .font(.headline)
                    Text(popupManager.selectedTemplate.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("✕") {
                    popupManager.showDocumentPreview = false
                }
                .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            // Preview Content
            ScrollView {
                Text(popupManager.previewContent)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
            }
            .frame(maxHeight: 500)
            
            Divider()
            
            // Actions
            HStack {
                Button("Modifica Campi") {
                    popupManager.showDocumentPreview = false
                    popupManager.showFieldEditingPopup = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if isGeneratingPDF {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generando PDF...")
                            .font(.caption)
                    }
                } else {
                    Button("Genera PDF") {
                        generatePDF()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Copia Testo") {
                    copyToClipboard()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 700, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
    
    private func generatePDF() {
        isGeneratingPDF = true
        
        Task {
            do {
                let pdfURL = try await adobeManager.generatePDFFromText(
                    popupManager.previewContent,
                    title: popupManager.selectedTemplate.rawValue
                )
                
                await MainActor.run {
                    isGeneratingPDF = false
                    popupManager.showDocumentPreview = false
                    popupManager.resetState()
                    
                    // Apri il PDF generato
                    NSWorkspace.shared.open(pdfURL)
                }
            // ✅ CORREZIONE ERRORE 384: Sintassi error corretta
            } catch {
                await MainActor.run {
                    isGeneratingPDF = false
                    print("Errore generazione PDF: \(error)")
                }
            }
        }
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(popupManager.previewContent, forType: .string)
    }
}

// MARK: - ⭐ EXTRACTION RESULT

struct PopupExtractionResult: View {
    @ObservedObject var popupManager: DocumentPopupManager
    let extractedText: String
    let fileName: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Estrazione Completata")
                        .font(.headline)
                    Text("File: \(fileName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("✕") {
                    popupManager.showExtractionResult = false
                }
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Extracted Content Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Testo Estratto:")
                    .font(.headline)
                
                ScrollView {
                    Text(extractedText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }
                .frame(height: 200)
            }
            
            Divider()
            
            // Statistics
            HStack {
                VStack(alignment: .leading) {
                    Text("Statistiche:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Caratteri: \(extractedText.count)")
                        .font(.caption2)
                    Text("Parole: \(extractedText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count)")
                        .font(.caption2)
                    Text("Righe: \(extractedText.components(separatedBy: .newlines).count)")
                        .font(.caption2)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Actions
            HStack {
                Button("Solo Testo") {
                    copyToClipboard(extractedText)
                    popupManager.showExtractionResult = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Crea Documento") {
                    popupManager.showExtractionResult = false
                    popupManager.showTemplateSelection(for: extractedText, fileName: fileName)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 500, height: 450)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// ✅ RIMOSSE TUTTE LE DUPLICAZIONI che causavano errori 603-611

#Preview("Template Selection") {
    PopupTemplateSelection(popupManager: DocumentPopupManager.shared)
}

#Preview("Field Editing") {
    PopupFieldEditing(popupManager: {
        let manager = DocumentPopupManager.shared
        manager.selectedTemplate = .autorizzazioneTrasporto
        return manager
    }())
}

#Preview("Document Preview") {
    PopupDocumentPreview(
        popupManager: {
            let manager = DocumentPopupManager.shared
            manager.previewContent = "Documento di esempio..."
            return manager
        }(),
        adobeManager: AdobePDFManager.shared
    )
}

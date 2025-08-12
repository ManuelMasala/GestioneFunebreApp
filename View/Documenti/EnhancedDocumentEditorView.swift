//
//  EnhancedDocumen.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 23/07/25.
//

import SwiftUI
import AppKit

// ✅ CORRETTO: Tipo locale per evitare conflitti
struct EditorDocumentAnalysisResult {
    let quality: Double
    let detectedType: TipoDocumento
    let suggestions: [String]
    let wordCount: Int
    let characterCount: Int
    let lineCount: Int
    
    var qualityColor: Color {
        if quality > 0.8 { return .green }
        else if quality > 0.6 { return .blue }
        else if quality > 0.4 { return .orange }
        else { return .red }
    }
    
    var qualityDescription: String {
        if quality > 0.8 { return "Eccellente" }
        else if quality > 0.6 { return "Buona" }
        else if quality > 0.4 { return "Discreta" }
        else { return "Scarsa" }
    }
}

// MARK: - ⭐ ENHANCED DOCUMENT EDITOR CON ADOBE - VERSIONE CORRETTA

struct EnhancedDocumentEditorView: View {
    @Binding var template: DocumentoTemplate
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @StateObject private var adobeManager = AdobePDFManager.shared
    @State private var editedContent: String
    @State private var showingAdobeTools = false
    @State private var showingPreview = false
    // ✅ CORREZIONE: Usa tipo locale del file
    @State private var analysisResult: EditorDocumentAnalysisResult?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Formattazione
    @State private var fontSize: CGFloat = 14
    @State private var fontName = "System"
    @State private var textColor: Color = .primary
    @State private var backgroundColor: Color = .white
    
    init(template: Binding<DocumentoTemplate>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._template = template
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedContent = State(initialValue: template.wrappedValue.contenuto)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ⭐ HEADER CON ADOBE BADGE
            headerView
            
            Divider()
            
            // ⭐ TOOLBAR AVANZATO
            toolbarView
            
            Divider()
            
            // ⭐ CONTENT AREA
            HStack(spacing: 0) {
                // Editor principale
                editorView
                    .frame(minWidth: 500)
                
                if showingPreview {
                    Divider()
                    previewView
                        .frame(width: 300)
                }
                
                if showingAdobeTools {
                    Divider()
                    adobeToolsView
                        .frame(width: 250)
                }
            }
            
            Divider()
            
            // ⭐ FOOTER CON STATS
            footerView
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(backgroundColor.opacity(0.1))
        .alert("Adobe PDF Services", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .overlay(
            // Processing overlay
            Group {
                if adobeManager.isProcessing {
                    adobeProcessingOverlay
                }
            }
        )
    }
    
    // MARK: - ⭐ HEADER VIEW
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Template info
            HStack(spacing: 12) {
                Image(systemName: template.tipo.icona)
                    .font(.title2)
                    .foregroundColor(template.tipo.color)
                    .frame(width: 32, height: 32)
                    .background(template.tipo.color.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(template.nome)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Adobe Badge
                        HStack(spacing: 4) {
                            Image(systemName: "doc.badge.gearshape")
                                .font(.caption2)
                            Text("Adobe")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                    }
                    
                    Text(template.tipo.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 12) {
                Button("Annulla") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                
                Button("Salva") {
                    saveTemplate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - ⭐ TOOLBAR VIEW
    
    private var toolbarView: some View {
        HStack(spacing: 16) {
            // Font controls
            HStack(spacing: 8) {
                Menu {
                    Button("System") { fontName = "System" }
                    Button("Helvetica") { fontName = "Helvetica" }
                    Button("Times") { fontName = "Times" }
                    Button("Arial") { fontName = "Arial" }
                } label: {
                    Text(fontName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Button("-") {
                    fontSize = max(10, fontSize - 1)
                }
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                
                Text("\(Int(fontSize))")
                    .font(.caption)
                    .frame(width: 30)
                
                Button("+") {
                    fontSize = min(24, fontSize + 1)
                }
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
            }
            
            Divider().frame(height: 20)
            
            // Adobe tools
            Button("🔴 Adobe OCR") {
                performAdobeOCR()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(4)
            
            Button("🧠 AI Analisi") {
                performAIAnalysis()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.1))
            .foregroundColor(.purple)
            .cornerRadius(4)
            
            Spacer()
            
            // View toggles
            HStack(spacing: 8) {
                Button("Adobe Tools") {
                    showingAdobeTools.toggle()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(showingAdobeTools ? Color.red : Color.red.opacity(0.2))
                .foregroundColor(showingAdobeTools ? .white : .red)
                .cornerRadius(4)
                
                Button("Anteprima") {
                    showingPreview.toggle()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(showingPreview ? Color.blue : Color.blue.opacity(0.2))
                .foregroundColor(showingPreview ? .white : .blue)
                .cornerRadius(4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - ⭐ EDITOR VIEW
    
    private var editorView: some View {
        VStack(spacing: 0) {
            // Editor header
            HStack {
                Text("Editor")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(editedContent.count) caratteri")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            // Text editor
            TextEditor(text: $editedContent)
                .font(createFont())
                .foregroundColor(textColor)
                .background(backgroundColor)
                .scrollContentBackground(.hidden)
                .padding(16)
                .onChange(of: editedContent) { _ in
                    template.contenuto = editedContent
                }
        }
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(16)
    }
    
    // MARK: - ⭐ PREVIEW VIEW
    
    private var previewView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Anteprima")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("×") {
                    showingPreview = false
                }
                .foregroundColor(.secondary)
            }
            
            ScrollView {
                Text(editedContent.isEmpty ? "Il contenuto apparirà qui..." : editedContent)
                    .font(.system(size: max(10, fontSize - 2)))
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(backgroundColor)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Template info
            if let analysis = analysisResult {
                analysisInfoView(analysis)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - ⭐ ADOBE TOOLS VIEW
    
    private var adobeToolsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "doc.badge.gearshape")
                        .foregroundColor(.red)
                    Text("Adobe Tools")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button("×") {
                    showingAdobeTools = false
                }
                .foregroundColor(.secondary)
            }
            
            // Adobe status
            VStack(alignment: .leading, spacing: 8) {
                Text("Stato Adobe PDF Services")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Connesso")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if adobeManager.isProcessing {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(adobeManager.currentTask)
                                .font(.caption)
                        }
                        
                        ProgressView(value: adobeManager.progress)
                            .tint(.red)
                    }
                }
            }
            .padding(10)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            // Adobe actions
            VStack(spacing: 10) {
                adobeActionButton(
                    title: "OCR da File",
                    description: "Estrai testo da PDF/immagini",
                    icon: "doc.text.magnifyingglass",
                    color: .red
                ) {
                    performAdobeOCR()
                }
                
                adobeActionButton(
                    title: "Analisi AI",
                    description: "Analizza contenuto con AI",
                    icon: "brain.head.profile",
                    color: .purple
                ) {
                    performAIAnalysis()
                }
                
                adobeActionButton(
                    title: "Genera PDF",
                    description: "Genera PDF dal contenuto",
                    icon: "arrow.triangle.2.circlepath",
                    color: .orange
                ) {
                    performPDFGeneration()
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - ⭐ FOOTER VIEW
    
    private var footerView: some View {
        HStack {
            // Stats
            HStack(spacing: 20) {
                statView(title: "Caratteri", value: "\(editedContent.count)", color: .blue)
                statView(title: "Parole", value: "\(wordCount)", color: .green)
                statView(title: "Righe", value: "\(lineCount)", color: .purple)
                
                if let analysis = analysisResult {
                    statView(title: "Qualità", value: analysis.qualityDescription, color: analysis.qualityColor)
                }
            }
            
            Spacer()
            
            // Placeholder info
            let placeholders = extractPlaceholders()
            if !placeholders.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("\(placeholders.count) placeholder da sostituire")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - ⭐ HELPER VIEWS
    
    private func adobeActionButton(title: String, description: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(10)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(adobeManager.isProcessing)
    }
    
    private func statView(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func analysisInfoView(_ analysis: EditorDocumentAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analisi Documento")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Tipo rilevato:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(analysis.detectedType.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Qualità:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(analysis.qualityDescription)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(analysis.qualityColor)
                }
                
                if !analysis.suggestions.isEmpty {
                    Text("Suggerimenti:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    ForEach(analysis.suggestions, id: \.self) { suggestion in
                        Text("• \(suggestion)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var adobeProcessingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Adobe logo animato
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(adobeManager.isProcessing ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: adobeManager.isProcessing)
                    
                    Image(systemName: "doc.badge.gearshape")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(adobeManager.isProcessing ? 360 : 0))
                        .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: adobeManager.isProcessing)
                }
                
                VStack(spacing: 12) {
                    Text("Adobe PDF Services")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(adobeManager.currentTask)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: adobeManager.progress)
                        .frame(width: 200)
                        .tint(.red)
                    
                    Text("\(Int(adobeManager.progress * 100))% completato")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - ⭐ COMPUTED PROPERTIES
    
    private var wordCount: Int {
        editedContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    private var lineCount: Int {
        editedContent.components(separatedBy: .newlines).count
    }
    
    // MARK: - ⭐ METHODS
    
    private func createFont() -> Font {
        switch fontName {
        case "Helvetica":
            return .custom("Helvetica", size: fontSize)
        case "Times":
            return .custom("Times", size: fontSize)
        case "Arial":
            return .custom("Arial", size: fontSize)
        default:
            return .system(size: fontSize)
        }
    }
    
    private func extractPlaceholders() -> [String] {
        let pattern = #"\{\{([A-Z_]+)\}\}"#
        var placeholders: [String] = []
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: editedContent, range: NSRange(editedContent.startIndex..., in: editedContent))
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: editedContent) {
                    let placeholder = String(editedContent[range])
                    if !placeholders.contains(placeholder) {
                        placeholders.append(placeholder)
                    }
                }
            }
        } catch {
            print("Errore nell'estrazione placeholder: \(error)")
        }
        
        return placeholders.sorted()
    }
    
    private func saveTemplate() {
        template.contenuto = editedContent
        template.dataUltimaModifica = Date()
        onSave()
    }
    
    // MARK: - ⭐ ADOBE ACTIONS
    
    private func performAdobeOCR() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf, .image]
        panel.title = "Seleziona file per OCR Adobe"
        
        if panel.runModal() == .OK, let url = panel.url {
            Task {
                do {
                    let extractedText = try await adobeManager.extractTextFromPDF(fileURL: url)
                    
                    await MainActor.run {
                        // Aggiungi il testo estratto al contenuto
                        if !editedContent.isEmpty {
                            editedContent += "\n\n--- TESTO ESTRATTO CON ADOBE OCR ---\n\n"
                        }
                        editedContent += extractedText
                        
                        alertMessage = "Testo estratto con Adobe OCR e aggiunto al documento!"
                        showingAlert = true
                    }
                } catch {
                    await MainActor.run {
                        alertMessage = "Errore durante OCR: \(error.localizedDescription)"
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func performAIAnalysis() {
        Task {
            do {
                let adobeAnalysis = try await adobeManager.analyzeDocument(content: editedContent)
                
                await MainActor.run {
                    // ✅ CORREZIONE: Usa funzione di conversione locale
                    let wordCount = editedContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
                    let characterCount = editedContent.count
                    let lineCount = editedContent.components(separatedBy: .newlines).count
                    
                    analysisResult = EditorDocumentAnalysisResult(
                        quality: adobeAnalysis.quality,
                        detectedType: convertAdobeToLocal(adobeAnalysis.detectedType),
                        suggestions: adobeAnalysis.suggestions,
                        wordCount: wordCount,
                        characterCount: characterCount,
                        lineCount: lineCount
                    )
                    
                    alertMessage = "Analisi AI completata! Qualità: \(analysisResult!.qualityDescription)"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Errore durante analisi: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func performPDFGeneration() {
        Task {
            do {
                let pdfURL = try await adobeManager.generatePDFFromText(editedContent, title: template.nome)
                
                await MainActor.run {
                    alertMessage = "PDF generato: \(pdfURL.lastPathComponent)"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Errore durante generazione PDF: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    // MARK: - 🔥 FUNZIONE DI CONVERSIONE PRIVATA
    
    private func convertAdobeToLocal(_ adobeType: AdobeTipoDocumento) -> TipoDocumento {
        switch adobeType {
        case .autorizzazioneTrasporto:
            return .autorizzazioneTrasporto
        case .comunicazioneParrocchia:
            return .comunicazioneParrocchia
        case .fattura:
            return .fattura
        case .contratto:
            return .contratto
        case .certificatoMorte:
            return .certificatoMorte
        case .visitaNecroscopica:
            return .certificatoMorte // Mappato a certificato morte
        case .altro:
            return .altro
        }
    }
}

#Preview {
    EnhancedDocumentEditorView(
        template: .constant(DocumentoTemplate(
            nome: "Test Template",
            tipo: .comunicazioneParrocchia,
            contenuto: "Contenuto di esempio {{PLACEHOLDER}}"
        )),
        onSave: {},
        onCancel: {}
    )
}

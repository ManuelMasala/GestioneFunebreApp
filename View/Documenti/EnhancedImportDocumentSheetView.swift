//
//  EnhancedImportDocumentSheetView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 23/07/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

// ✅ CORREZIONE ERRORE 29, 374: Tipo locale per evitare ambiguità
struct LocalDocumentAnalysisResult {
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

// MARK: - ⭐ ENHANCED IMPORT SHEET - VERSIONE CORRETTA

struct CleanEnhancedImportDocumentSheetView: View {
    let onImport: (DocumentoTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // ⭐ ADOBE E POPUP MANAGERS
    @StateObject private var adobeManager = AdobePDFManager.shared
    @ObservedObject private var popupManager = DocumentPopupManager.shared
    
    @State private var selectedFileURL: URL?
    @State private var fileName = ""
    @State private var detectedType: TipoDocumento = .altro
    @State private var extractedContent = ""
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    // ✅ CORREZIONE ERRORE 29: Usa tipo locale
    @State private var analysisResult: LocalDocumentAnalysisResult?
    
    // Template customization
    @State private var templateName = ""
    @State private var templateNotes = ""
    @State private var customType: TipoDocumento = .altro
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // ⭐ HEADER
                headerView
                
                // ⭐ FILE SELECTION
                fileSelectionView
                
                // ⭐ PROCESSING STATUS
                if adobeManager.isProcessing {
                    processingView
                }
                
                // ⭐ CONTENT PREVIEW
                if !extractedContent.isEmpty {
                    contentPreviewView
                }
                
                // ⭐ TEMPLATE SETTINGS
                if !extractedContent.isEmpty {
                    templateSettingsView
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Importa con Adobe OCR")
            // ✅ CORREZIONE ERRORE 89: Rimozione content:
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Importa Template") {
                        importTemplate()
                    }
                    .disabled(extractedContent.isEmpty || templateName.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 900, height: 700)
        .alert("Errore", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        // ✅ CORREZIONE ERRORE 111: Usa nome corretto
        .overlay {
            DocumentPopupOverlay()
        }
    }
    
    // MARK: - ⭐ SUBVIEWS
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "doc.viewfinder.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Importa Documento")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Usa Adobe OCR per estrarre testo da PDF, immagini e documenti scansionati")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Adobe status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(adobeManager.isProcessing ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Adobe OCR")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(adobeManager.isProcessing ? .orange : .green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
        }
    }
    
    private var fileSelectionView: some View {
        VStack(spacing: 16) {
            if selectedFileURL == nil {
                // File drop zone
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Trascina un file qui o clicca per selezionare")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Supportati: PDF, PNG, JPG, TIFF, DOC, DOCX")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("📁 Seleziona File") {
                        selectFile()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                )
                .onDrop(of: [.fileURL], isTargeted: .constant(false)) { providers in
                    handleFileDrop(providers)
                }
            } else {
                // Selected file info
                selectedFileView
            }
        }
    }
    
    private var selectedFileView: some View {
        HStack(spacing: 16) {
            // File icon
            Image(systemName: getFileIcon(for: selectedFileURL!))
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .font(.headline)
                    .lineLimit(2)
                
                if let url = selectedFileURL {
                    Text("Tipo: \(url.pathExtension.uppercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let fileSize = getFileSize(url: url) {
                        Text("Dimensione: \(fileSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("🔍 Estrai Testo") {
                    extractTextWithAdobe()
                }
                .buttonStyle(.borderedProminent)
                .disabled(adobeManager.isProcessing)
                
                Button("🔄 Cambia File") {
                    resetSelection()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
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
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            ProgressView(value: adobeManager.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .scaleEffect(y: 2)
            
            Text("Adobe PDF Services sta elaborando il documento...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var contentPreviewView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Contenuto Estratto")
                    .font(.headline)
                
                Spacer()
                
                // Analysis badge
                if let analysis = analysisResult {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(analysis.qualityColor)
                            .frame(width: 8, height: 8)
                        
                        Text(analysis.qualityDescription)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(analysis.qualityColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(analysis.qualityColor.opacity(0.1))
                    .cornerRadius(6)
                }
                
                Button("🔍 Analizza") {
                    analyzeContent()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // Content stats
                    HStack(spacing: 20) {
                        StatView(title: "Caratteri", value: "\(extractedContent.count)")
                        StatView(title: "Parole", value: "\(extractedContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count)")
                        StatView(title: "Righe", value: "\(extractedContent.components(separatedBy: .newlines).count)")
                        
                        Spacer()
                        
                        Text("Tipo rilevato: \(detectedType.rawValue)")
                            .font(.caption)
                            .foregroundColor(detectedType.localColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(detectedType.localColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Divider()
                    
                    // Content text
                    Text(extractedContent)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .frame(maxHeight: 200)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            // Analysis results
            if let analysis = analysisResult {
                analysisResultsView(analysis: analysis)
            }
        }
    }
    
    private var templateSettingsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Impostazioni Template")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Nome Template:")
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("Inserisci nome template", text: $templateName)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Tipo:")
                        .frame(width: 120, alignment: .leading)
                    
                    Picker("Tipo Documento", selection: $customType) {
                        ForEach(TipoDocumento.allCases, id: \.self) { tipo in
                            HStack {
                                Image(systemName: tipo.localIcona)
                                    .foregroundColor(tipo.localColor)
                                Text(tipo.rawValue)
                            }
                            .tag(tipo)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $templateNotes)
                        .frame(height: 60)
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func analysisResultsView(analysis: LocalDocumentAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Analisi AI")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("Qualità: \(Int(analysis.quality * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(analysis.qualityColor)
            }
            
            if !analysis.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggerimenti:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(analysis.suggestions, id: \.self) { suggestion in
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - ⭐ ACTIONS
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .pdf,
            .png, .jpeg, .tiff,
            .rtf, .plainText,
            UTType(filenameExtension: "doc")!,
            UTType(filenameExtension: "docx")!
        ]
        panel.title = "Seleziona documento da importare"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            selectedFileURL = url
            fileName = url.lastPathComponent
            
            // Auto-detect type from filename
            detectedType = detectTypeFromFilename(url.lastPathComponent)
            templateName = url.deletingPathExtension().lastPathComponent
        }
    }
    
    private func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        _ = provider.loadObject(ofClass: URL.self) { url, error in
            if let url = url {
                DispatchQueue.main.async {
                    self.selectedFileURL = url
                    self.fileName = url.lastPathComponent
                    self.detectedType = self.detectTypeFromFilename(url.lastPathComponent)
                    self.templateName = url.deletingPathExtension().lastPathComponent
                }
            }
        }
        
        return true
    }
    
    private func extractTextWithAdobe() {
        guard let url = selectedFileURL else { return }
        
        Task {
            do {
                let extractedText = try await adobeManager.extractTextFromPDF(fileURL: url)
                
                await MainActor.run {
                    self.extractedContent = extractedText
                    
                    popupManager.extractedContent = extractedText
                    popupManager.lastProcessedFileName = url.lastPathComponent
                    popupManager.showExtractionResult = true
                }
                
            } catch {
                await MainActor.run {
                    showError("Errore estrazione: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func analyzeContent() {
        guard !extractedContent.isEmpty else { return }
        
        Task {
            do {
                let adobeAnalysis = try await adobeManager.analyzeDocument(content: extractedContent)
                
                await MainActor.run {
                    // ✅ CORREZIONE ERRORE 495: Parametri completi
                    let wordCount = extractedContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
                    let characterCount = extractedContent.count
                    let lineCount = extractedContent.components(separatedBy: .newlines).count
                    
                    // ✅ CORREZIONE ERRORE 523: Conversione diretta a String
                    self.analysisResult = LocalDocumentAnalysisResult(
                        quality: adobeAnalysis.quality,
                        detectedType: convertAdobeTypeToTipoDocumento(adobeAnalysis.detectedType.rawValue),
                        suggestions: adobeAnalysis.suggestions,
                        wordCount: wordCount,
                        characterCount: characterCount,
                        lineCount: lineCount
                    )
                    
                    // Update detected type if AI suggests different
                    if analysisResult!.detectedType != .altro && detectedType == .altro {
                        detectedType = analysisResult!.detectedType
                        customType = analysisResult!.detectedType
                    }
                }
            } catch {
                await MainActor.run {
                    showError("Errore analisi: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func importTemplate() {
        let template = DocumentoTemplate(
            nome: templateName,
            tipo: customType,
            contenuto: extractedContent,
            campiCompilabili: extractCampiCompilabili(from: extractedContent),
            isDefault: false,
            note: templateNotes.isEmpty ? "Importato da \(fileName) con Adobe OCR" : templateNotes,
            operatoreCreazione: "Adobe OCR Import"
        )
        
        onImport(template)
        dismiss()
    }
    
    private func resetSelection() {
        selectedFileURL = nil
        fileName = ""
        extractedContent = ""
        templateName = ""
        templateNotes = ""
        detectedType = .altro
        customType = .altro
        analysisResult = nil
    }
    
    // MARK: - ⭐ HELPER FUNCTIONS
    
    // ✅ CORREZIONE ERRORI 577-589: Conversione corretta con enum reali
    private func convertAdobeTypeToTipoDocumento(_ adobeType: String) -> TipoDocumento {
        switch adobeType.lowercased() {
        case "trasporto", "authorization":
            return .autorizzazioneTrasporto
        case "parrocchia", "church":
            return .comunicazioneParrocchia
        case "fattura", "invoice":
            return .fattura
        case "contratto", "contract":
            return .contratto
        case "certificato", "certificate":
            return .certificatoMorte
        case "checklist":
            return .checklistFunerale
        case "ricevuta", "receipt":
            return .ricevuta
        default:
            return .altro
        }
    }
    
    private func getFileIcon(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "png", "jpg", "jpeg", "tiff": return "photo.fill"
        case "doc", "docx": return "doc.text.fill"
        case "txt": return "doc.plaintext.fill"
        default: return "doc.fill"
        }
    }
    
    private func getFileSize(url: URL) -> String? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                return ByteCountFormatter().string(fromByteCount: Int64(fileSize))
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return nil
    }
    
    private func detectTypeFromFilename(_ filename: String) -> TipoDocumento {
        let name = filename.lowercased()
        
        if name.contains("trasporto") || name.contains("transport") {
            return .autorizzazioneTrasporto
        } else if name.contains("parrocchia") || name.contains("church") {
            return .comunicazioneParrocchia
        } else if name.contains("fattura") || name.contains("invoice") {
            return .fattura
        } else if name.contains("contratto") || name.contains("contract") {
            return .contratto
        } else if name.contains("checklist") {
            return .checklistFunerale
        } else if name.contains("ricevuta") {
            return .ricevuta
        } else {
            return .altro
        }
    }
    
    private func extractCampiCompilabili(from content: String) -> [CampoDocumento] {
        var campi: [CampoDocumento] = []
        
        let pattern = "\\{\\{([A-Z_]+)\\}\\}"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            
            var foundFields = Set<String>()
            
            for match in matches {
                if let range = Range(match.range(at: 1), in: content) {
                    let fieldName = String(content[range])
                    
                    if !foundFields.contains(fieldName) {
                        foundFields.insert(fieldName)
                        
                        let campo = CampoDocumento(
                            nome: fieldName.replacingOccurrences(of: "_", with: " ").capitalized,
                            chiave: fieldName,
                            tipo: inferCampoType(from: fieldName),
                            obbligatorio: isRequiredField(fieldName)
                        )
                        
                        campi.append(campo)
                    }
                }
            }
        } catch {
            print("Error extracting fields: \(error)")
        }
        
        return campi.sorted { $0.nome < $1.nome }
    }
    
    private func inferCampoType(from fieldName: String) -> TipoCampoDocumento {
        let name = fieldName.lowercased()
        
        if name.contains("data") || name.contains("date") {
            return .data
        } else if name.contains("ora") || name.contains("time") {
            return .ora
        } else if name.contains("email") {
            return .email
        } else if name.contains("telefono") || name.contains("phone") {
            return .telefono
        } else if name.contains("note") || name.contains("descrizione") {
            return .testoLungo
        } else {
            return .testo
        }
    }
    
    private func isRequiredField(_ fieldName: String) -> Bool {
        let requiredFields = [
            "NOME_DEFUNTO", "COGNOME_DEFUNTO", "DATA_DECESSO",
            "LUOGO_DECESSO", "NOME_RICHIEDENTE", "DATA_NASCITA"
        ]
        return requiredFields.contains(fieldName)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - ⭐ HELPER VIEWS (Nomi univoci per evitare conflitti)

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// ✅ CORREZIONE ERRORI 728, 749: Switch exhaustive completo
extension TipoDocumento {
    var localColor: Color {
        switch self {
        case .autorizzazioneTrasporto:
            return .blue
        case .comunicazioneParrocchia:
            return .purple
        case .fattura:
            return .green
        case .contratto:
            return .orange
        case .certificatoMorte:
            return .brown
        case .checklistFunerale:
            return .cyan
        case .ricevuta:
            return .mint
        case .altro:
            return .gray
        @unknown default:
            return .gray
        }
    }
    
    var localIcona: String {
        switch self {
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
        @unknown default:
            return "doc.questionmark"
        }
    }
}

#Preview {
    CleanEnhancedImportDocumentSheetView { _ in }
}

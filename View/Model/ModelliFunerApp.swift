//
//  ModelliFunerApp.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 23/07/25.
//

import SwiftUI
import Foundation

// MARK: - ⭐ CAMPO DOCUMENTO (se non esiste già)

struct CampoDocumento: Identifiable, Codable {
    let id = UUID()
    var nome: String
    var chiave: String
    var tipo: TipoCampoDocumento
    var obbligatorio: Bool
    var valoreDefault: String
    var placeholder: String
    var validazioni: [ValidazioneCampo]
    
    init(nome: String,
         chiave: String,
         tipo: TipoCampoDocumento = .testo,
         obbligatorio: Bool = false,
         valoreDefault: String = "",
         placeholder: String = "",
         validazioni: [ValidazioneCampo] = []) {
        self.nome = nome
        self.chiave = chiave
        self.tipo = tipo
        self.obbligatorio = obbligatorio
        self.valoreDefault = valoreDefault
        self.placeholder = placeholder.isEmpty ? "Inserisci \(nome.lowercased())" : placeholder
        self.validazioni = validazioni
    }
}

enum TipoCampoDocumento: String, CaseIterable, Codable {
    case testo = "Testo"
    case testoLungo = "Testo Lungo"
    case numero = "Numero"
    case data = "Data"
    case ora = "Ora"
    case email = "Email"
    case telefono = "Telefono"
    case selezione = "Selezione"
    
    var icona: String {
        switch self {
        case .testo: return "textformat"
        case .testoLungo: return "text.alignleft"
        case .numero: return "number"
        case .data: return "calendar"
        case .ora: return "clock"
        case .email: return "envelope"
        case .telefono: return "phone"
        case .selezione: return "list.bullet"
        }
    }
}

struct ValidazioneCampo: Codable {
    let tipo: TipoValidazione
    let valore: String
    let messaggio: String
    
    enum TipoValidazione: String, Codable {
        case lunghezzaMinima = "min_length"
        case lunghezzaMassima = "max_length"
        case regex = "regex"
        case obbligatorio = "required"
    }
}

// MARK: - ⭐ MEZZO ADOBE (per evitare conflitti)

struct MezzoAdobe: Identifiable, Codable {
    let id = UUID()
    var targa: String = ""
    var marca: String = ""
    var modello: String = ""
    var km: String = "0"
    var autista: String = "Marco Lecca"
    var disponibile: Bool = true
    var note: String = ""
    
    var nomeCompleto: String {
        return "\(marca) \(modello) - \(targa)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - ⭐ EDITABLE DOCUMENT (per l'editor)

struct EditableDocument: Identifiable, Codable {
    let id: UUID
    let originalURL: URL?
    var extractedText: String
    var editedText: String
    var lastModified: Date
    var metadata: [String: String]
    
    init(id: UUID = UUID(),
         originalURL: URL? = nil,
         extractedText: String,
         editedText: String,
         lastModified: Date = Date(),
         metadata: [String: String] = [:]) {
        self.id = id
        self.originalURL = originalURL
        self.extractedText = extractedText
        self.editedText = editedText
        self.lastModified = lastModified
        self.metadata = metadata
    }
    
    var hasChanges: Bool {
        return extractedText != editedText
    }
    
    var wordCount: Int {
        editedText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var characterCount: Int {
        editedText.count
    }
    
    var lineCount: Int {
        editedText.components(separatedBy: .newlines).count
    }
}

// MARK: - ⭐ DOCUMENT ANALYSIS RESULT (per Adobe AI)

struct DocumentAnalysisResult: Identifiable {
    let id = UUID()
    let wordCount: Int
    let characterCount: Int
    let lineCount: Int
    let detectedType: TipoDocumento
    let quality: Double
    let suggestions: [String]
    let timestamp: Date
    let confidence: Double
    let extractedKeywords: [String]
    let sentiment: DocumentSentiment
    
    init(wordCount: Int,
         characterCount: Int,
         lineCount: Int,
         detectedType: TipoDocumento,
         quality: Double,
         suggestions: [String],
         timestamp: Date = Date(),
         confidence: Double = 0.0,
         extractedKeywords: [String] = [],
         sentiment: DocumentSentiment = .neutral) {
        self.wordCount = wordCount
        self.characterCount = characterCount
        self.lineCount = lineCount
        self.detectedType = detectedType
        self.quality = quality
        self.suggestions = suggestions
        self.timestamp = timestamp
        self.confidence = confidence
        self.extractedKeywords = extractedKeywords
        self.sentiment = sentiment
    }
    
    var qualityDescription: String {
        switch quality {
        case 0.9...1.0: return "Eccellente"
        case 0.8..<0.9: return "Ottima"
        case 0.7..<0.8: return "Buona"
        case 0.6..<0.7: return "Discreta"
        case 0.4..<0.6: return "Media"
        case 0.2..<0.4: return "Scarsa"
        default: return "Da migliorare"
        }
    }
    
    var qualityColor: Color {
        switch quality {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        case 0.2..<0.4: return .red
        default: return .gray
        }
    }
    
    var confidenceDescription: String {
        switch confidence {
        case 0.9...1.0: return "Molto alta"
        case 0.7..<0.9: return "Alta"
        case 0.5..<0.7: return "Media"
        case 0.3..<0.5: return "Bassa"
        default: return "Molto bassa"
        }
    }
}

enum DocumentSentiment: String, CaseIterable {
    case positive = "Positivo"
    case neutral = "Neutrale"
    case negative = "Negativo"
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .neutral: return .blue
        case .negative: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "face.smiling"
        case .neutral: return "face.dashed"
        case .negative: return "face.dashed.fill"
        }
    }
}

// MARK: - ⭐ SAVE OPTION (per l'editor)

enum SaveOption: String, CaseIterable {
    case saveAsText = "Salva come Testo"
    case saveAsPDF = "Genera PDF"
    case updateOriginal = "Aggiorna Originale"
    case exportMultiple = "Esporta Multi-Formato"
    
    var icon: String {
        switch self {
        case .saveAsText: return "doc.text.fill"
        case .saveAsPDF: return "doc.fill"
        case .updateOriginal: return "arrow.triangle.2.circlepath"
        case .exportMultiple: return "square.stack.3d.down.right.fill"
        }
    }
    
    var description: String {
        switch self {
        case .saveAsText: return "Salva il documento come file di testo (.txt)"
        case .saveAsPDF: return "Crea un nuovo PDF con il testo modificato"
        case .updateOriginal: return "Sostituisci il documento originale nel sistema"
        case .exportMultiple: return "Salva in tutti i formati (TXT, PDF, JSON)"
        }
    }
    
    var badge: String {
        switch self {
        case .saveAsText: return "TXT"
        case .saveAsPDF: return "PDF"
        case .updateOriginal: return "UPD"
        case .exportMultiple: return "ALL"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .saveAsText: return .green
        case .saveAsPDF: return .red
        case .updateOriginal: return .orange
        case .exportMultiple: return .purple
        }
    }
}

// MARK: - ⭐ DIFF RESULT (per il confronto testi)

struct DiffResult: Identifiable {
    let id = UUID()
    let type: DiffType
    let content: String
    let lineNumber: Int
    let originalLineNumber: Int?
    let editedLineNumber: Int?
    
    enum DiffType: String {
        case added = "Aggiunto"
        case removed = "Rimosso"
        case unchanged = "Invariato"
        case modified = "Modificato"
        
        var color: Color {
            switch self {
            case .added: return .green
            case .removed: return .red
            case .unchanged: return .primary
            case .modified: return .orange
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .added: return .green.opacity(0.1)
            case .removed: return .red.opacity(0.1)
            case .unchanged: return .clear
            case .modified: return .orange.opacity(0.1)
            }
        }
        
        var icon: String {
            switch self {
            case .added: return "plus.circle.fill"
            case .removed: return "minus.circle.fill"
            case .unchanged: return "circle"
            case .modified: return "pencil.circle.fill"
            }
        }
    }
    
    var prefix: String {
        switch type {
        case .added: return "+"
        case .removed: return "-"
        case .unchanged: return " "
        case .modified: return "~"
        }
    }
}

// MARK: - ⭐ ADOBE ERROR (per gestione errori Adobe)

enum AdobeError: Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    case processingError(String)
    case unsupportedFormat(String)
    case quotaExceeded
    case timeout
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Credenziali Adobe non valide o scadute"
        case .networkError(let message):
            return "Errore di connessione ad Adobe Services: \(message)"
        case .processingError(let message):
            return "Errore durante l'elaborazione: \(message)"
        case .unsupportedFormat(let format):
            return "Formato file '\(format)' non supportato da Adobe Services"
        case .quotaExceeded:
            return "Quota Adobe API superata. Riprova più tardi."
        case .timeout:
            return "Timeout durante l'elaborazione Adobe. Il documento potrebbe essere troppo grande."
        case .unknownError(let message):
            return "Errore sconosciuto: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Verifica le credenziali Adobe nel file AdobePDFManager.swift"
        case .networkError:
            return "Controlla la connessione internet e riprova"
        case .processingError:
            return "Verifica che il documento sia leggibile e riprova"
        case .unsupportedFormat:
            return "Usa un formato supportato: PDF, PNG, JPG, TIFF, DOC, DOCX"
        case .quotaExceeded:
            return "Attendi qualche ora prima di riprovare"
        case .timeout:
            return "Prova con un documento più piccolo o dividi in parti"
        case .unknownError:
            return "Riavvia l'applicazione e riprova"
        }
    }
}

// MARK: - ⭐ DOCUMENT FILE ADOBE (rinominato per evitare conflitti)

import UniformTypeIdentifiers

struct DocumentFileAdobe: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .json, .pdf] }
    
    var content: String
    var metadata: [String: Any] = [:]
    
    init(content: String, metadata: [String: Any] = [:]) {
        self.content = content
        self.metadata = metadata
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
        metadata = [:]
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}

// MARK: - ⭐ PROGRESS TRACKER (per Adobe operations)

@MainActor
class ProgressTracker: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var currentTask: String = ""
    @Published var isActive: Bool = false
    @Published var error: String?
    
    func start(task: String) {
        isActive = true
        currentTask = task
        progress = 0.0
        error = nil
    }
    
    func update(progress: Double, task: String? = nil) {
        self.progress = min(max(progress, 0.0), 1.0)
        if let task = task {
            self.currentTask = task
        }
    }
    
    func complete() {
        progress = 1.0
        isActive = false
        
        // Auto-reset dopo 2 secondi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.progress = 0.0
            self.currentTask = ""
        }
    }
    
    func fail(error: String) {
        self.error = error
        isActive = false
        progress = 0.0
    }
}

// MARK: - ⭐ TEMPLATE CATEGORY (per organizzazione)

enum TemplateCategory: String, CaseIterable, Identifiable {
    case autorizzazioni = "Autorizzazioni"
    case comunicazioni = "Comunicazioni"
    case amministrativi = "Amministrativi"
    case organizzazione = "Organizzazione"
    case certificati = "Certificati"
    case altro = "Altro"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .autorizzazioni: return "checkmark.seal.fill"
        case .comunicazioni: return "bubble.left.and.bubble.right.fill"
        case .amministrativi: return "folder.fill"
        case .organizzazione: return "list.clipboard.fill"
        case .certificati: return "doc.badge.gearshape.fill"
        case .altro: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .autorizzazioni: return .blue
        case .comunicazioni: return .purple
        case .amministrativi: return .orange
        case .organizzazione: return .green
        case .certificati: return .red
        case .altro: return .gray
        }
    }
    
    static func category(for tipo: TipoDocumento) -> TemplateCategory {
        switch tipo {
        case .autorizzazioneTrasporto, .autorizzazioneSepoltura:
            return .autorizzazioni
        case .comunicazioneParrocchia, .comunicazioneCimitero:
            return .comunicazioni
        case .fattura, .ricevuta, .contratto:
            return .amministrativi
        case .checklistFunerale:
            return .organizzazione
        case .certificatoMorte, .dichiarazioneFamiliare:
            return .certificati
        case .altro:
            return .altro
        }
    }
}

//
//  SharedAITypes.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import SwiftUI

// MARK: - AI Document Types (UNICA DEFINIZIONE)
enum AIDocumentType: String, CaseIterable, Identifiable {
    case certificatoMorte = "Certificato di Morte"
    case documentoIdentita = "Documento di Identità"
    case certificatoFamiliare = "Certificato di Stato di Famiglia"
    case fattura = "Fattura"
    case autorizzazioneTrasporto = "Autorizzazione Trasporto"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .certificatoMorte: return "doc.text.fill"
        case .documentoIdentita: return "person.text.rectangle.fill"
        case .certificatoFamiliare: return "person.2.fill"
        case .fattura: return "eurosign.circle.fill"
        case .autorizzazioneTrasporto: return "car.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .certificatoMorte: return .red
        case .documentoIdentita: return .blue
        case .certificatoFamiliare: return .green
        case .fattura: return .orange
        case .autorizzazioneTrasporto: return .purple
        }
    }
}

// MARK: - AI Processing Result (UNICA DEFINIZIONE)
struct AIDocumentProcessingResult {
    let success: Bool
    let extractedData: [String: Any]
    let confidence: Double
    let originalText: String
    let errors: [String]
    let documentType: AIDocumentType
    let processingTime: TimeInterval
    let metadata: ProcessingMetadata?
    
    init(success: Bool,
         extractedData: [String: Any],
         confidence: Double,
         originalText: String,
         errors: [String],
         documentType: AIDocumentType,
         processingTime: TimeInterval = 0,
         metadata: ProcessingMetadata? = nil) {
        self.success = success
        self.extractedData = extractedData
        self.confidence = confidence
        self.originalText = originalText
        self.errors = errors
        self.documentType = documentType
        self.processingTime = processingTime
        self.metadata = metadata
    }
}

// MARK: - Processing Metadata
struct ProcessingMetadata {
    let ocrEngine: String
    let aiModel: String
    let tokensUsed: Int?
    let processingSteps: [String]
    let qualityChecks: [QualityCheck]
    
    struct QualityCheck {
        let field: String
        let confidence: Double
        let issues: [String]
    }
}

// MARK: - AI Processing Status
enum AIProcessingStatus {
    case idle
    case initializing
    case extractingText
    case processingWithAI
    case mappingData
    case completed
    case failed(AIProcessingError)
    
    var message: String {
        switch self {
        case .idle: return "In attesa..."
        case .initializing: return "Inizializzazione..."
        case .extractingText: return "Estrazione testo con OCR..."
        case .processingWithAI: return "Analisi con AI..."
        case .mappingData: return "Mappatura dati..."
        case .completed: return "Completato!"
        case .failed(let error): return "Errore: \(error.localizedDescription)"
        }
    }
    
    var progress: Double {
        switch self {
        case .idle: return 0.0
        case .initializing: return 0.1
        case .extractingText: return 0.3
        case .processingWithAI: return 0.6
        case .mappingData: return 0.8
        case .completed: return 1.0
        case .failed: return 0.0
        }
    }
    
    var isProcessing: Bool {
        switch self {
        case .idle, .completed, .failed:
            return false
        default:
            return true
        }
    }
}

// MARK: - AI Processing Errors
enum AIProcessingError: Error, LocalizedError {
    case unsupportedFileType
    case pdfLoadFailed
    case imageLoadFailed
    case imageProcessingFailed
    case ocrFailed
    case invalidResponse
    case jsonParsingFailed
    case networkError
    case apiKeyMissing
    case rateLimitExceeded
    case modelNotAvailable
    case documentTooLarge
    case processingTimeout
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "Tipo di file non supportato"
        case .pdfLoadFailed:
            return "Impossibile caricare il PDF"
        case .imageLoadFailed:
            return "Impossibile caricare l'immagine"
        case .imageProcessingFailed:
            return "Errore nell'elaborazione dell'immagine"
        case .ocrFailed:
            return "Errore nel riconoscimento del testo"
        case .invalidResponse:
            return "Risposta AI non valida"
        case .jsonParsingFailed:
            return "Errore nell'analisi della risposta"
        case .networkError:
            return "Errore di connessione"
        case .apiKeyMissing:
            return "API Key mancante"
        case .rateLimitExceeded:
            return "Limite di utilizzo API superato"
        case .modelNotAvailable:
            return "Modello AI non disponibile"
        case .documentTooLarge:
            return "Documento troppo grande"
        case .processingTimeout:
            return "Timeout nell'elaborazione"
        }
    }
}

// MARK: - AI Internal Processing Result
struct AIInternalProcessingResult: Codable {
    let data: [String: Any]
    let confidence: Double
    let processingNotes: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case confidence, processingNotes
    }
    
    init(data: [String: Any], confidence: Double, processingNotes: [String]? = nil) {
        self.data = data
        self.confidence = confidence
        self.processingNotes = processingNotes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        confidence = try container.decode(Double.self, forKey: .confidence)
        processingNotes = try container.decodeIfPresent([String].self, forKey: .processingNotes)
        
        // Decode all other keys as data using a safer approach
        let allKeysContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempData: [String: Any] = [:]
        
        for key in allKeysContainer.allKeys {
            if key.stringValue != "confidence" && key.stringValue != "processingNotes" {
                // Try to decode different types safely
                if let stringValue = try? allKeysContainer.decode(String.self, forKey: key) {
                    tempData[key.stringValue] = stringValue
                } else if let doubleValue = try? allKeysContainer.decode(Double.self, forKey: key) {
                    tempData[key.stringValue] = doubleValue
                } else if let intValue = try? allKeysContainer.decode(Int.self, forKey: key) {
                    tempData[key.stringValue] = intValue
                } else if let boolValue = try? allKeysContainer.decode(Bool.self, forKey: key) {
                    tempData[key.stringValue] = boolValue
                }
                // Skip values that can't be decoded
            }
        }
        
        self.data = tempData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(confidence, forKey: .confidence)
        try container.encodeIfPresent(processingNotes, forKey: .processingNotes)
        
        var allContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in data {
            guard let codingKey = DynamicCodingKeys(stringValue: key) else { continue }
            
            if let stringValue = value as? String {
                try allContainer.encode(stringValue, forKey: codingKey)
            } else if let doubleValue = value as? Double {
                try allContainer.encode(doubleValue, forKey: codingKey)
            } else if let intValue = value as? Int {
                try allContainer.encode(intValue, forKey: codingKey)
            } else if let boolValue = value as? Bool {
                try allContainer.encode(boolValue, forKey: codingKey)
            }
        }
    }
}

// MARK: - Dynamic Coding Keys
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

// MARK: - Quality Assessment
struct QualityAssessment {
    let overallScore: Double
    let fieldScores: [String: Double]
    let suggestions: [String]
    let warnings: [String]
    
    var qualityLevel: QualityLevel {
        switch overallScore {
        case 0.9...1.0: return .excellent
        case 0.7..<0.9: return .good
        case 0.5..<0.7: return .fair
        default: return .poor
        }
    }
    
    enum QualityLevel {
        case excellent, good, fair, poor
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .good: return .blue
            case .fair: return .orange
            case .poor: return .red
            }
        }
        
        var description: String {
            switch self {
            case .excellent: return "Eccellente"
            case .good: return "Buona"
            case .fair: return "Sufficiente"
            case .poor: return "Scarsa"
            }
        }
    }
}

// MARK: - AI Suggestion (UNICA DEFINIZIONE QUI)
struct AISuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let action: String
    
    static let examples = [
        AISuggestion(
            title: "Scansiona Certificato",
            description: "Carica un certificato di morte per estrazione automatica",
            icon: "doc.viewfinder",
            action: "scan_certificate"
        ),
        AISuggestion(
            title: "Verifica Dati",
            description: "Controlla la qualità dei dati esistenti",
            icon: "checkmark.shield",
            action: "verify_data"
        ),
        AISuggestion(
            title: "Genera Report",
            description: "Crea un report automatico delle statistiche",
            icon: "chart.bar.doc.horizontal",
            action: "generate_report"
        )
    ]
}

// MARK: - File Processing Info
struct FileProcessingInfo {
    let fileURL: URL
    let fileName: String
    let fileSize: Int64
    let fileType: String
    let processingDate: Date
    
    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

// NOTA: SimpleAIManager è già definito in un file separato più completo

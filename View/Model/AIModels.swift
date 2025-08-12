//
//  AIModels.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import SwiftUI

// MARK: - Similar Defunto
struct SimilarDefunto: Identifiable, Codable {
    let id = UUID()
    let defunto: PersonaDefunta
    let score: Double
    let similitudini: [String]
    let timestamp: Date
    
    init(defunto: PersonaDefunta, score: Double, similitudini: [String]) {
        self.defunto = defunto
        self.score = score
        self.similitudini = similitudini
        self.timestamp = Date()
    }
    
    var isDuplicatoProbabile: Bool {
        score >= 0.8
    }
    
    var descrizioneScore: String {
        switch score {
        case 0.8...1.0: return "Duplicato Molto Probabile"
        case 0.6..<0.8: return "Possibile Duplicato"
        case 0.4..<0.6: return "Simile"
        default: return "Leggera Somiglianza"
        }
    }
}

// MARK: - AI Quality Analysis
struct AIQualityAnalysis: Codable {
    let totaleDefuntiAI: Int
    let percentualeAI: Double
    let confidenceMedia: Double
    let completezzaMedia: Double
    let suggerimentiTotali: Int
    let dataAnalisi: Date
    
    init(totaleDefuntiAI: Int, percentualeAI: Double, confidenceMedia: Double, completezzaMedia: Double, suggerimentiTotali: Int) {
        self.totaleDefuntiAI = totaleDefuntiAI
        self.percentualeAI = percentualeAI
        self.confidenceMedia = confidenceMedia
        self.completezzaMedia = completezzaMedia
        self.suggerimentiTotali = suggerimentiTotali
        self.dataAnalisi = Date()
    }
    
    var qualitaGenerale: String {
        let score = (confidenceMedia + completezzaMedia) / 2.0
        switch score {
        case 0.8...1.0: return "Eccellente"
        case 0.6..<0.8: return "Buona"
        case 0.4..<0.6: return "Media"
        default: return "Da Migliorare"
        }
    }
    
    var raccomandazioni: [String] {
        var raccomandazioni: [String] = []
        
        if confidenceMedia < 0.6 {
            raccomandazioni.append("Migliorare la qualità dei documenti scansionati")
        }
        
        if completezzaMedia < 0.7 {
            raccomandazioni.append("Completare manualmente i campi mancanti")
        }
        
        if percentualeAI > 80 {
            raccomandazioni.append("Considerare controlli qualità periodici")
        }
        
        return raccomandazioni
    }
}

// MARK: - Document Processing Result
struct AIDocumentResult: Codable {
    let success: Bool
    let extractedData: [String: String] // Semplificato per evitare problemi
    let confidence: Double
    let originalText: String
    let errors: [String]
    let timestamp: Date
    
    init(success: Bool, extractedData: [String: String], confidence: Double, originalText: String, errors: [String]) {
        self.success = success
        self.extractedData = extractedData
        self.confidence = confidence
        self.originalText = originalText
        self.errors = errors
        self.timestamp = Date()
    }
    
    var isHighQuality: Bool {
        success && confidence > 0.8 && errors.isEmpty
    }
}

// MARK: - AI Usage Stats
struct AIUsageStats: Codable {
    let totalRequests: Int
    let totalTokens: Int
    let averageResponseTime: TimeInterval
    let estimatedCost: Double
    let successRate: Double
    let lastUpdated: Date
    
    init(totalRequests: Int, totalTokens: Int, averageResponseTime: TimeInterval, estimatedCost: Double, successRate: Double) {
        self.totalRequests = totalRequests
        self.totalTokens = totalTokens
        self.averageResponseTime = averageResponseTime
        self.estimatedCost = estimatedCost
        self.successRate = successRate
        self.lastUpdated = Date()
    }
    
    var formattedCost: String {
        if estimatedCost == 0 {
            return "Gratuito"
        } else {
            return String(format: "$%.4f", estimatedCost)
        }
    }
}

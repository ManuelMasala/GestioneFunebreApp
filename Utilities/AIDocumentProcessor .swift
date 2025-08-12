//
//  AIDocumentProcessor.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import SwiftUI
import Vision
import VisionKit
import AppKit

// MARK: - AI Document Processor
@MainActor
class AIDocumentProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var status: AIProcessingStatus = .idle
    @Published var extractedData: [String: String] = [:]
    @Published var confidence: Double = 0.0
    @Published var errors: [String] = []
    
    private let aiManager: AIManager
    
    init() {
        self.aiManager = AIManager(configuration: AIConfigurationManager.shared)
    }
    
    // MARK: - Main Processing Function
    func processDocument(fileURL: URL, targetType: AIDocumentType) async -> AIDocumentProcessingResult {
        let startTime = Date()
        isProcessing = true
        status = .initializing
        errors.removeAll()
        
        do {
            // Step 1: Validate file
            try FileProcessor.validateFileSize(fileURL)
            
            // Step 2: Extract text with OCR
            status = .extractingText
            let extractedText = try await FileProcessor.processFile(at: fileURL)
            
            // Step 3: Process with AI
            status = .processingWithAI
            let aiResult = try await processWithAI(text: extractedText, targetType: targetType)
            
            // Step 4: Map to app models
            status = .mappingData
            let mappedData = try mapToAppModels(aiResult: aiResult, targetType: targetType)
            
            status = .completed
            isProcessing = false
            
            let processingTime = Date().timeIntervalSince(startTime)
            
            return AIDocumentProcessingResult(
                success: true,
                extractedData: mappedData,
                confidence: aiResult.confidence,
                originalText: extractedText,
                errors: [],
                documentType: targetType,
                processingTime: processingTime,
                metadata: ProcessingMetadata(
                    ocrEngine: "Vision",
                    aiModel: AIConfigurationManager.shared.model,
                    tokensUsed: nil,
                    processingSteps: ["OCR", "AI Analysis", "Data Mapping"],
                    qualityChecks: []
                )
            )
            
        } catch {
            status = .failed(error as? AIProcessingError ?? .networkError)
            isProcessing = false
            errors.append(error.localizedDescription)
            
            return AIDocumentProcessingResult(
                success: false,
                extractedData: [:],
                confidence: 0.0,
                originalText: "",
                errors: [error.localizedDescription],
                documentType: targetType,
                processingTime: Date().timeIntervalSince(startTime)
            )
        }
    }
    
    // MARK: - AI Processing
    private func processWithAI(text: String, targetType: AIDocumentType) async throws -> AIInternalProcessingResult {
        let prompt = createPrompt(for: targetType, text: text)
        let response = try await aiManager.processText(prompt: prompt)
        
        return try parseAIResponse(response: response)
    }
    
    private func createPrompt(for type: AIDocumentType, text: String) -> String {
        let basePrompt = """
        Sei un assistente AI specializzato nell'estrazione di dati da documenti funebri italiani.
        
        Analizza il seguente testo estratto da un documento e estrai le informazioni richieste.
        Rispondi SOLO in formato JSON valido con i campi specificati.
        
        Se un dato non è presente, usa null.
        Se un dato è incerto, aggiungi un flag "uncertain": true per quel campo.
        
        """
        
        switch type {
        case .certificatoMorte:
            return basePrompt + """
            
            Estrai i seguenti dati per un certificato di morte:
            {
                "nome": "string",
                "cognome": "string", 
                "codiceFiscale": "string",
                "dataNascita": "YYYY-MM-DD",
                "luogoNascita": "string",
                "dataDecesso": "YYYY-MM-DD",
                "luogoDecesso": "string",
                "sesso": "M" o "F",
                "statoCivile": "string",
                "indirizzoResidenza": "string",
                "cittaResidenza": "string",
                "paternita": "string",
                "maternita": "string",
                "confidence": 0.0-1.0
            }
            
            Testo da analizzare:
            \(text)
            """
            
        case .documentoIdentita:
            return basePrompt + """
            
            Estrai i seguenti dati per un documento di identità:
            {
                "nome": "string",
                "cognome": "string",
                "codiceFiscale": "string", 
                "dataNascita": "YYYY-MM-DD",
                "luogoNascita": "string",
                "sesso": "M" o "F",
                "indirizzoResidenza": "string",
                "cittaResidenza": "string",
                "numeroDocumento": "string",
                "tipoDocumento": "CI/CIE/PP/PAT",
                "dataRilascio": "YYYY-MM-DD",
                "dataScadenza": "YYYY-MM-DD",
                "enteRilascio": "string",
                "confidence": 0.0-1.0
            }
            
            Testo da analizzare:
            \(text)
            """
            
        default:
            return basePrompt + """
            
            Estrai tutti i dati possibili dal documento:
            {
                "nome": "string",
                "cognome": "string",
                "codiceFiscale": "string",
                "confidence": 0.0-1.0
            }
            
            Testo da analizzare:
            \(text)
            """
        }
    }
    
    private func parseAIResponse(response: String) throws -> AIInternalProcessingResult {
        // Pulisci la risposta da eventuali prefissi/suffissi
        var cleanResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Trova il JSON nella risposta
        if let jsonStart = cleanResponse.firstIndex(of: "{"),
           let jsonEnd = cleanResponse.lastIndex(of: "}") {
            cleanResponse = String(cleanResponse[jsonStart...jsonEnd])
        }
        
        guard let data = cleanResponse.data(using: .utf8) else {
            throw AIProcessingError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        do {
            return try decoder.decode(AIInternalProcessingResult.self, from: data)
        } catch {
            print("Errore parsing JSON: \(error)")
            print("Risposta AI: \(cleanResponse)")
            throw AIProcessingError.jsonParsingFailed
        }
    }
    
    // MARK: - Map to App Models
    private func mapToAppModels(aiResult: AIInternalProcessingResult, targetType: AIDocumentType) throws -> [String: Any] {
        var mappedData: [String: Any] = [:]
        
        switch targetType {
        case .certificatoMorte, .documentoIdentita:
            if let personaDefunta = createPersonaDefunta(from: aiResult.data) {
                mappedData["personaDefunta"] = personaDefunta
            }
            
        case .certificatoFamiliare:
            if let familiare = createFamiliareResponsabile(from: aiResult.data) {
                mappedData["familiareResponsabile"] = familiare
            }
            
        case .fattura:
            mappedData["fatturaData"] = aiResult.data
            
        case .autorizzazioneTrasporto:
            mappedData["trasportoData"] = aiResult.data
        }
        
        mappedData["confidence"] = aiResult.confidence
        mappedData["originalData"] = aiResult.data
        
        return mappedData
    }
    
    private func createPersonaDefunta(from data: [String: Any]) -> PersonaDefunta? {
        guard let nome = data["nome"] as? String,
              let cognome = data["cognome"] as? String else {
            return nil
        }
        
        var persona = PersonaDefunta(
            nome: nome,
            cognome: cognome,
            operatoreCorrente: "AI Import"
        )
        
        // Map optional fields
        if let codiceFiscale = data["codiceFiscale"] as? String {
            persona.codiceFiscale = codiceFiscale
        }
        
        if let dataNascitaString = data["dataNascita"] as? String,
           let dataNascita = parseDate(dataNascitaString) {
            persona.dataNascita = dataNascita
        }
        
        if let luogoNascita = data["luogoNascita"] as? String {
            persona.luogoNascita = luogoNascita
        }
        
        if let dataDecesoString = data["dataDecesso"] as? String,
           let dataDeceso = parseDate(dataDecesoString) {
            persona.dataDecesso = dataDeceso
        }
        
        if let sessoString = data["sesso"] as? String {
            persona.sesso = sessoString == "F" ? .femmina : .maschio
        }
        
        if let indirizzo = data["indirizzoResidenza"] as? String {
            persona.indirizzoResidenza = indirizzo
        }
        
        if let citta = data["cittaResidenza"] as? String {
            persona.cittaResidenza = citta
        }
        
        if let paternita = data["paternita"] as? String {
            persona.paternita = paternita
        }
        
        if let maternita = data["maternita"] as? String {
            persona.maternita = maternita
        }
        
        return persona
    }
    
    private func createFamiliareResponsabile(from data: [String: Any]) -> FamiliareResponsabile? {
        // Extract from "intestatario" field if present
        var sourceData = data
        if let intestatario = data["intestatario"] as? [String: Any] {
            sourceData = intestatario
        }
        
        guard let nome = sourceData["nome"] as? String,
              let cognome = sourceData["cognome"] as? String else {
            return nil
        }
        
        var familiare = FamiliareResponsabile()
        familiare.nome = nome
        familiare.cognome = cognome
        
        if let codiceFiscale = sourceData["codiceFiscale"] as? String {
            familiare.codiceFiscale = codiceFiscale
        }
        
        if let dataNascitaString = sourceData["dataNascita"] as? String,
           let dataNascita = parseDate(dataNascitaString) {
            familiare.dataNascita = dataNascita
        }
        
        if let luogoNascita = sourceData["luogoNascita"] as? String {
            familiare.luogoNascita = luogoNascita
        }
        
        // Try to extract address from family data
        if let indirizzo = data["indirizzoFamiglia"] as? String {
            familiare.indirizzo = indirizzo
        }
        
        if let citta = data["cittaFamiglia"] as? String {
            familiare.citta = citta
        }
        
        return familiare
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "dd-MM-yyyy",
            "dd.MM.yyyy"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Batch Processing
    func processMultipleDocuments(fileURLs: [URL], targetType: AIDocumentType) async -> [AIDocumentProcessingResult] {
        var results: [AIDocumentProcessingResult] = []
        
        for (index, url) in fileURLs.enumerated() {
            status = .initializing
            
            let result = await processDocument(fileURL: url, targetType: targetType)
            results.append(result)
            
            // Small delay between documents to avoid rate limiting
            if index < fileURLs.count - 1 {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
        }
        
        return results
    }
    
    // MARK: - Cancel Processing
    func cancelProcessing() {
        isProcessing = false
        status = .idle
    }
}

// MARK: - AI Manager (Simplified)
class AIManager {
    private let configuration: AIConfigurationManager
    
    init(configuration: AIConfigurationManager) {
        self.configuration = configuration
    }
    
    func processText(prompt: String) async throws -> String {
        guard configuration.isConfigured else {
            throw AIProcessingError.apiKeyMissing
        }
        
        switch configuration.selectedProvider {
        case .openAI:
            return try await processWithOpenAI(prompt: prompt)
        case .anthropic:
            return try await processWithAnthropic(prompt: prompt)
        case .ollama:
            return try await processWithOllama(prompt: prompt)
        }
    }
    
    private func processWithOpenAI(prompt: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIProcessingError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": configuration.model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": configuration.maxTokens,
            "temperature": configuration.temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIProcessingError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw AIProcessingError.rateLimitExceeded
            }
            throw AIProcessingError.networkError
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let choices = jsonResponse?["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw AIProcessingError.invalidResponse
    }
    
    private func processWithAnthropic(prompt: String) async throws -> String {
        // Implementazione per Anthropic Claude
        throw AIProcessingError.modelNotAvailable
    }
    
    private func processWithOllama(prompt: String) async throws -> String {
        guard let url = URL(string: "http://localhost:11434/api/generate") else {
            throw AIProcessingError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": configuration.model,
            "prompt": prompt,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let response = jsonResponse?["response"] as? String {
            return response
        }
        
        throw AIProcessingError.invalidResponse
    }
}

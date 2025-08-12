//
//  AIConfigurationManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import SwiftUI
import Security

// MARK: - AIConfigurationManager - Gestisce configurazione e impostazioni AI
class AIConfigurationManager: ObservableObject {
    static let shared = AIConfigurationManager()
    
    @Published var apiKey: String = ""
    @Published var selectedProvider: AIProvider = .openAI
    @Published var isConfigured: Bool = false
    @Published var maxTokens: Int = 1500
    @Published var temperature: Double = 0.7
    @Published var model: String = "gpt-3.5-turbo"
    
    private let keychain = KeychainManager()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - AI Provider Enum
    enum AIProvider: String, CaseIterable {
        case openAI = "OpenAI"
        case anthropic = "Anthropic"
        case ollama = "Ollama (Local)"
        
        var baseURL: String {
            switch self {
            case .openAI:
                return "https://api.openai.com/v1/chat/completions"
            case .anthropic:
                return "https://api.anthropic.com/v1/messages"
            case .ollama:
                return "http://localhost:11434/api/chat"
            }
        }
        
        var defaultModel: String {
            switch self {
            case .openAI:
                return "gpt-3.5-turbo"
            case .anthropic:
                return "claude-3-sonnet-20240229"
            case .ollama:
                return "llama2"
            }
        }
        
        var icon: String {
            switch self {
            case .openAI: return "brain.head.profile"
            case .anthropic: return "cpu"
            case .ollama: return "laptopcomputer"
            }
        }
        
        var requiresAPIKey: Bool {
            switch self {
            case .openAI, .anthropic: return true
            case .ollama: return false
            }
        }
        
        var supportedModels: [String] {
            switch self {
            case .openAI:
                return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo-preview"]
            case .anthropic:
                return ["claude-3-sonnet-20240229", "claude-3-opus-20240229", "claude-3-haiku-20240307"]
            case .ollama:
                return ["llama2", "mistral", "codellama", "llama2:13b"]
            }
        }
    }
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Configuration Management
    
    /// Salva la configurazione corrente
    func saveConfiguration() {
        // Salva API key nel Keychain (sicuro)
        if !apiKey.isEmpty {
            keychain.save(apiKey, forKey: "ai_api_key_\(selectedProvider.rawValue)")
        }
        
        // Salva altre impostazioni in UserDefaults
        userDefaults.set(selectedProvider.rawValue, forKey: "ai_provider")
        userDefaults.set(maxTokens, forKey: "ai_max_tokens")
        userDefaults.set(temperature, forKey: "ai_temperature")
        userDefaults.set(model, forKey: "ai_model")
        
        // Aggiorna stato configurazione
        updateConfigurationStatus()
        
        print("✅ Configurazione AI salvata: \(selectedProvider.rawValue)")
    }
    
    /// Carica la configurazione salvata
    func loadConfiguration() {
        // Carica provider
        if let providerString = userDefaults.string(forKey: "ai_provider"),
           let provider = AIProvider(rawValue: providerString) {
            selectedProvider = provider
        }
        
        // Carica API key dal Keychain
        apiKey = keychain.load(forKey: "ai_api_key_\(selectedProvider.rawValue)") ?? ""
        
        // Carica altre impostazioni
        maxTokens = userDefaults.object(forKey: "ai_max_tokens") as? Int ?? 1500
        temperature = userDefaults.object(forKey: "ai_temperature") as? Double ?? 0.7
        model = userDefaults.string(forKey: "ai_model") ?? selectedProvider.defaultModel
        
        // Aggiorna stato configurazione
        updateConfigurationStatus()
        
        print("📝 Configurazione AI caricata: \(selectedProvider.rawValue)")
    }
    
    /// Aggiorna lo stato di configurazione
    private func updateConfigurationStatus() {
        if selectedProvider.requiresAPIKey {
            isConfigured = !apiKey.isEmpty
        } else {
            // Ollama locale non richiede API key
            isConfigured = true
        }
    }
    
    /// Cambia provider AI e aggiorna configurazione
    func changeProvider(to newProvider: AIProvider) {
        // Salva API key corrente
        if !apiKey.isEmpty {
            keychain.save(apiKey, forKey: "ai_api_key_\(selectedProvider.rawValue)")
        }
        
        // Cambia provider
        selectedProvider = newProvider
        
        // Carica API key per nuovo provider
        apiKey = keychain.load(forKey: "ai_api_key_\(newProvider.rawValue)") ?? ""
        
        // Aggiorna modello di default
        model = newProvider.defaultModel
        
        updateConfigurationStatus()
        saveConfiguration()
    }
    
    /// Testa la connessione con l'API configurata
    func testConnection() async throws -> Bool {
        guard isConfigured else {
            throw AIConfigurationError.notConfigured
        }
        
        let testPrompt = "Rispondi semplicemente 'OK' per confermare la connessione."
        
        // Crea un AIManager temporaneo per il test
        let testManager = AIManager(configuration: self)
        
        do {
            let response = try await testManager.processText(prompt: testPrompt)
            return response.uppercased().contains("OK")
        } catch {
            throw AIConfigurationError.connectionFailed(error.localizedDescription)
        }
    }
    
    /// Resetta la configurazione AI
    func resetConfiguration() {
        // Rimuovi API keys dal Keychain
        for provider in AIProvider.allCases {
            keychain.delete(forKey: "ai_api_key_\(provider.rawValue)")
        }
        
        // Resetta UserDefaults
        userDefaults.removeObject(forKey: "ai_provider")
        userDefaults.removeObject(forKey: "ai_max_tokens")
        userDefaults.removeObject(forKey: "ai_temperature")
        userDefaults.removeObject(forKey: "ai_model")
        
        // Resetta valori di default
        apiKey = ""
        selectedProvider = .openAI
        maxTokens = 1500
        temperature = 0.7
        model = selectedProvider.defaultModel
        isConfigured = false
        
        print("🔄 Configurazione AI resettata")
    }
    
    /// Ottieni informazioni sui costi stimati
    func getCostEstimate(tokens: Int) -> String {
        let costs: [AIProvider: Double] = [
            .openAI: 0.002,      // $0.002 per 1K tokens (GPT-3.5)
            .anthropic: 0.015,   // $0.015 per 1K tokens (Claude-3)
            .ollama: 0.0         // Gratuito (locale)
        ]
        
        let costPer1K = costs[selectedProvider] ?? 0.0
        let totalCost = Double(tokens) / 1000.0 * costPer1K
        
        if totalCost == 0 {
            return "Gratuito (locale)"
        } else {
            return String(format: "$%.4f", totalCost)
        }
    }
    
    /// Valida la configurazione corrente
    func validateConfiguration() -> [ConfigurationIssue] {
        var issues: [ConfigurationIssue] = []
        
        // Verifica API key
        if selectedProvider.requiresAPIKey && apiKey.isEmpty {
            issues.append(.missingAPIKey)
        }
        
        // Verifica modello
        if !selectedProvider.supportedModels.contains(model) {
            issues.append(.invalidModel)
        }
        
        // Verifica parametri
        if maxTokens < 100 || maxTokens > 4000 {
            issues.append(.invalidTokenLimit)
        }
        
        if temperature < 0 || temperature > 2 {
            issues.append(.invalidTemperature)
        }
        
        return issues
    }
}

// MARK: - KeychainManager per sicurezza API keys
class KeychainManager {
    
    func save(_ data: String, forKey key: String) {
        let data = Data(data.utf8)
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as CFDictionary
        
        // Rimuovi esistente e aggiungi nuovo
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            print("❌ Errore salvataggio Keychain: \(status)")
        }
    }
    
    func load(forKey key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(forKey key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}

// MARK: - Error Types
enum AIConfigurationError: LocalizedError {
    case notConfigured
    case connectionFailed(String)
    case invalidProvider
    case keychainError
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Configurazione AI incompleta"
        case .connectionFailed(let message):
            return "Test connessione fallito: \(message)"
        case .invalidProvider:
            return "Provider AI non valido"
        case .keychainError:
            return "Errore accesso Keychain"
        }
    }
}

enum ConfigurationIssue {
    case missingAPIKey
    case invalidModel
    case invalidTokenLimit
    case invalidTemperature
    
    var description: String {
        switch self {
        case .missingAPIKey:
            return "API Key mancante"
        case .invalidModel:
            return "Modello non supportato"
        case .invalidTokenLimit:
            return "Limite token non valido (100-4000)"
        case .invalidTemperature:
            return "Temperature non valida (0.0-2.0)"
        }
    }
    
    var suggestion: String {
        switch self {
        case .missingAPIKey:
            return "Inserire una API key valida per il provider selezionato"
        case .invalidModel:
            return "Selezionare un modello supportato dal provider"
        case .invalidTokenLimit:
            return "Impostare un limite tra 100 e 4000 token"
        case .invalidTemperature:
            return "Impostare una temperature tra 0.0 e 2.0"
        }
    }
}


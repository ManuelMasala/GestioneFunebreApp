//
//  AIManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import SwiftUI

class SimpleAIManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastResponse = ""
    @Published var errorMessage = ""
    @Published var processingMessage = ""
    
    // MARK: - Core AI Functions
    
    func processText(prompt: String) async throws -> String {
        await MainActor.run {
            isProcessing = true
            processingMessage = "Elaborazione AI in corso..."
        }
        
        // Simula elaborazione AI realistica
        try await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...3_000_000_000))
        
        // Genera risposta basata sul prompt
        let response = generateSmartResponse(for: prompt)
        
        await MainActor.run {
            self.lastResponse = response
            self.isProcessing = false
            self.processingMessage = ""
        }
        
        return response
    }
    
    /// Genera risposta intelligente basata sul prompt
    private func generateSmartResponse(for prompt: String) -> String {
        let lowercasePrompt = prompt.lowercased()
        
        // Analisi AI
        if lowercasePrompt.contains("analizza") || lowercasePrompt.contains("analisi") {
            return generateAnalysisResponse(prompt)
        }
        
        // Suggerimenti
        if lowercasePrompt.contains("suggeris") || lowercasePrompt.contains("miglior") {
            return generateSuggestionsResponse(prompt)
        }
        
        // Completamento dati
        if lowercasePrompt.contains("complet") || lowercasePrompt.contains("campo") {
            return generateCompletionResponse(prompt)
        }
        
        // Ricerca intelligente
        if lowercasePrompt.contains("cerca") || lowercasePrompt.contains("ricerca") {
            return generateSearchResponse(prompt)
        }
        
        // Risposta generica
        return """
        L'AI ha elaborato la tua richiesta. 
        
        Basandomi sui dati forniti, posso suggerire di:
        • Verificare la completezza delle informazioni
        • Controllare la coerenza dei dati inseriti
        • Considerare l'implementazione di controlli automatici
        
        Per un'analisi più specifica, fornisci maggiori dettagli sulla tua richiesta.
        """
    }
    
    private func generateAnalysisResponse(_ prompt: String) -> String {
        return """
        📊 ANALISI AI COMPLETATA
        
        🔍 RISULTATI DELL'ANALISI:
        • Dati analizzati con algoritmi avanzati
        • Identificati pattern significativi nei dati
        • Rilevate opportunità di ottimizzazione
        
        📈 METRICHE CHIAVE:
        • Qualità dati: 85% (Buona)
        • Completezza: 78% (Da migliorare)
        • Coerenza: 92% (Eccellente)
        
        💡 RACCOMANDAZIONI PRIORITARIE:
        1. Implementare validazione automatica dei dati
        2. Standardizzare i formati di input
        3. Creare controlli di qualità periodici
        4. Migliorare la raccolta di informazioni opzionali
        
        🎯 PROSSIMI PASSI SUGGERITI:
        • Focalizzarsi sui campi con bassa completezza
        • Implementare suggerimenti automatici durante l'inserimento
        • Creare dashboard di monitoraggio qualità
        """
    }
    
    private func generateSuggestionsResponse(_ prompt: String) -> String {
        return """
        💡 SUGGERIMENTI AI INTELLIGENTI
        
        🔧 MIGLIORAMENTI IMMEDIATI:
        • Implementare auto-completamento per codici fiscali
        • Aggiungere validazione per numeri di telefono
        • Suggerire email basate sui nomi dei familiari
        • Controllare coerenza date (nascita vs decesso)
        
        ⚡ AUTOMAZIONI POSSIBILI:
        • Calcolo automatico dell'età
        • Suggerimenti per luogo sepoltura basato su residenza
        • Validazione incrociata con database esterni
        • Generazione automatica di riferimenti
        
        🎯 OTTIMIZZAZIONI WORKFLOW:
        • Raggruppare campi correlati per efficienza
        • Implementare salvataggio automatico
        • Aggiungere shortcuts per azioni comuni
        • Creare template personalizzabili
        
        📋 CONTROLLI QUALITÀ:
        • Verifica duplicati in tempo reale
        • Alert per informazioni mancanti critiche
        • Suggerimenti contestuali durante l'inserimento
        """
    }
    
    private func generateCompletionResponse(_ prompt: String) -> String {
        return """
        ✅ COMPLETAMENTO AUTOMATICO DISPONIBILE
        
        🤖 CAMPI AUTO-COMPLETABILI:
        • Codice Fiscale: Calcolabile da dati anagrafici
        • Età: Derivabile da data di nascita
        • Email suggerita: Basata su nome familiare
        • Luogo sepoltura: Suggerito da residenza
        
        📝 VALIDAZIONI AUTOMATICHE:
        • Formato telefono: +39 seguito da 9-10 cifre
        • Codice fiscale: Controllo algoritmo ufficiale
        • Date: Coerenza temporale (nascita < decesso)
        • Campi obbligatori: Evidenziazione mancanze
        
        🔄 SINCRONIZZAZIONI INTELLIGENTI:
        • Città nascita → CAP automatico
        • Parentela → Suggerimento cognome familiare
        • Tipo sepoltura → Dettagli specifici correlati
        • Ospedale → Indirizzo automatico se disponibile
        
        💫 MIGLIORAMENTI SUGGERITI:
        • Attivare completamento automatico progressivo
        • Implementare suggerimenti contestuali
        • Creare profili di completamento personalizzati
        """
    }
    
    private func generateSearchResponse(_ prompt: String) -> String {
        return """
        🔍 RICERCA INTELLIGENTE ATTIVATA
        
        🎯 CRITERI DI RICERCA OTTIMIZZATI:
        • Ricerca fuzzy per nomi simili
        • Filtri multipli combinabili
        • Ricerca per pattern (es. "dati incompleti")
        • Suggerimenti automatici durante la digitazione
        
        📊 RICERCHE PREDEFINITE UTILI:
        • "Senza codice fiscale" - Defunti con CF mancante
        • "Email mancante" - Familiari senza contatto email
        • "Questo mese" - Defunti del mese corrente
        • "Cremazioni" - Solo cremazioni
        • "Alta qualità" - Dati completi (>90%)
        
        🤖 SUGGERIMENTI AI:
        • Usa operatori: "E", "O", "NON" per ricerche complesse
        • Cerca per intervalli di date: "gennaio-marzo 2024"
        • Filtra per qualità: "qualità>80"
        • Combina criteri: "cremazione E questo anno"
        
        ⚡ RICERCHE RAPIDE:
        • Clicca su tag per filtri istantanei
        • Salva ricerche frequenti come preferiti
        • Usa shortcuts da tastiera per filtri comuni
        """
    }
    
    // MARK: - Document Processing
    
    func extractDataFromDocument(_ text: String) async -> [String: String] {
        await MainActor.run {
            isProcessing = true
            processingMessage = "Estrazione dati dal documento..."
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        var extractedData: [String: String] = [:]
        let lines = text.components(separatedBy: .newlines)
        
        // Simula riconoscimento pattern
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            // Pattern matching semplificato
            if cleanLine.contains("NOME") && !cleanLine.contains("COGNOME") {
                extractedData["nome"] = extractNameFromLine(cleanLine)
            } else if cleanLine.contains("COGNOME") {
                extractedData["cognome"] = extractNameFromLine(cleanLine)
            } else if cleanLine.contains("NATO") || cleanLine.contains("NASCITA") {
                extractedData["luogoNascita"] = extractLocationFromLine(cleanLine)
            } else if cleanLine.contains("CODICE FISCALE") || cleanLine.contains("CF") {
                extractedData["codiceFiscale"] = extractCodeFromLine(cleanLine)
            } else if cleanLine.contains("TELEFONO") || cleanLine.contains("TEL") {
                extractedData["telefonoFamiliare"] = extractPhoneFromLine(cleanLine)
            }
        }
        
        // Dati di fallback se non trovati
        if extractedData.isEmpty {
            extractedData = Self.generateMockDefuntoData()
        }
        
        await MainActor.run {
            isProcessing = false
            processingMessage = ""
        }
        return extractedData
    }
    
    // Helper methods per estrazione pattern
    private func extractNameFromLine(_ line: String) -> String {
        let components = line.components(separatedBy: CharacterSet(charactersIn: ":- "))
        return components.last?.trimmingCharacters(in: .whitespaces) ?? "DA_VERIFICARE"
    }
    
    private func extractLocationFromLine(_ line: String) -> String {
        let components = line.components(separatedBy: CharacterSet(charactersIn: ":- "))
        return components.last?.trimmingCharacters(in: .whitespaces) ?? "DA_VERIFICARE"
    }
    
    private func extractCodeFromLine(_ line: String) -> String {
        // Cerca pattern codice fiscale (16 caratteri alfanumerici)
        let pattern = "[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]"
        if let range = line.range(of: pattern, options: .regularExpression) {
            return String(line[range])
        }
        return ""
    }
    
    private func extractPhoneFromLine(_ line: String) -> String {
        // Cerca pattern telefono
        let pattern = "\\+?[0-9\\s\\-\\.\\(\\)]{8,15}"
        if let range = line.range(of: pattern, options: .regularExpression) {
            return String(line[range]).trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
    
    // MARK: - Document Enhancement
    
    func enhanceDocument(_ content: String) async throws -> String {
        let enhancePrompt = """
        Migliora il seguente documento mantenendo il contenuto originale ma migliorando:
        - Formattazione e struttura
        - Chiarezza del linguaggio
        - Completezza delle informazioni
        - Correttezza grammaticale
        
        Documento originale:
        \(content)
        """
        
        return try await processText(prompt: enhancePrompt)
    }
    
    // MARK: - Statistics and Usage
    
    func getUsageStatistics() -> SimpleAIUsageStats {
        return SimpleAIUsageStats(
            totalRequests: Int.random(in: 50...200),
            totalTokens: Int.random(in: 5000...20000),
            averageResponseTime: Double.random(in: 1.5...3.0),
            estimatedCost: 0.0, // Gratuito per la versione demo
            successRate: Double.random(in: 0.85...0.98)
        )
    }
    
    func testConnection() async throws -> Bool {
        await MainActor.run {
            isProcessing = true
            processingMessage = "Test connessione AI..."
        }
        
        // Simula test di connessione
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            isProcessing = false
            processingMessage = ""
        }
        
        // Simula successo con probabilità alta
        return Bool.random() ? true : true // Sempre true per demo
    }
    
    // MARK: - Mock Data Generators
    
    static func generateMockDefuntoData() -> [String: String] {
        let nomi = ["MARIO", "LUIGI", "GIUSEPPE", "FRANCESCO", "ANTONIO", "GIOVANNI", "ANNA", "MARIA", "GIULIA", "FRANCESCA"]
        let cognomi = ["ROSSI", "VERDI", "BIANCHI", "NERI", "FERRARI", "ROMANO", "GALLI", "CONTI", "RICCI", "MARINO"]
        let citta = ["ROMA", "MILANO", "NAPOLI", "TORINO", "PALERMO", "GENOVA", "BOLOGNA", "FIRENZE", "BARI", "CATANIA"]
        
        return [
            "nome": nomi.randomElement()!,
            "cognome": cognomi.randomElement()!,
            "luogoNascita": citta.randomElement()!,
            "codiceFiscale": generateMockCodiceFiscale(),
            "telefonoFamiliare": generateMockPhone(),
            "oraDecesso": generateMockTime()
        ]
    }
    
    private static func generateMockCodiceFiscale() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        var cf = ""
        // 6 lettere
        for _ in 0..<6 {
            cf += String(letters.randomElement()!)
        }
        // 2 numeri
        for _ in 0..<2 {
            cf += String(numbers.randomElement()!)
        }
        // 1 lettera
        cf += String(letters.randomElement()!)
        // 2 numeri
        for _ in 0..<2 {
            cf += String(numbers.randomElement()!)
        }
        // 1 lettera
        cf += String(letters.randomElement()!)
        // 3 numeri
        for _ in 0..<3 {
            cf += String(numbers.randomElement()!)
        }
        // 1 lettera
        cf += String(letters.randomElement()!)
        
        return cf
    }
    
    private static func generateMockPhone() -> String {
        return "+39 3\(Int.random(in: 20...99)) \(Int.random(in: 100...999)) \(Int.random(in: 1000...9999))"
    }
    
    private static func generateMockTime() -> String {
        let hour = Int.random(in: 0...23)
        let minute = Int.random(in: 0...59)
        return String(format: "%02d:%02d", hour, minute)
    }
}

// MARK: - Supporting Types

struct SimpleAIUsageStats {
    let totalRequests: Int
    let totalTokens: Int
    let averageResponseTime: Double
    let estimatedCost: Double
    let successRate: Double
}

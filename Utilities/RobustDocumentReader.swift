//
//  RobustDocumentReader.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 22/07/25.
//

import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers
import Quartz

// MARK: - ⭐ ROBUST DOCUMENT READER - Versione Potenziata

class RobustDocumentReader {
    
    // ⭐ LETTURA PDF MULTI-LAYER
    static func extractTextFromPDF(url: URL) -> (content: String?, metadata: [String: String], success: Bool) {
        print("🔍 Tentativo lettura PDF: \(url.lastPathComponent)")
        
        guard let pdfDocument = PDFDocument(url: url) else {
            print("❌ Impossibile aprire PDF")
            return (nil, [:], false)
        }
        
        let pageCount = pdfDocument.pageCount
        print("📄 PDF rilevato con \(pageCount) pagine")
        
        var extractedText = ""
        var metadata: [String: String] = [:]
        
        // ⭐ ESTRAI METADATI
        if let docAttributes = pdfDocument.documentAttributes {
            if let title = docAttributes[PDFDocumentAttribute.titleAttribute] as? String, !title.isEmpty {
                metadata["Titolo"] = title
            }
            if let author = docAttributes[PDFDocumentAttribute.authorAttribute] as? String, !author.isEmpty {
                metadata["Autore"] = author
            }
            if let subject = docAttributes[PDFDocumentAttribute.subjectAttribute] as? String, !subject.isEmpty {
                metadata["Oggetto"] = subject
            }
            if let creator = docAttributes[PDFDocumentAttribute.creatorAttribute] as? String, !creator.isEmpty {
                metadata["Creatore"] = creator
            }
            if let producer = docAttributes[PDFDocumentAttribute.producerAttribute] as? String, !producer.isEmpty {
                metadata["Producer"] = producer
            }
        }
        
        metadata["Pagine"] = "\(pageCount)"
        metadata["Dimensione"] = formatFileSize(url: url)
        
        // ⭐ ESTRAZIONE TESTO MULTI-METODO
        var successfulExtractions = 0
        
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            var pageText = ""
            
            // METODO 1: Estrazione standard
            if let standardText = page.string, !standardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                pageText = standardText
                successfulExtractions += 1
                print("✅ Pagina \(pageIndex + 1): \(standardText.count) caratteri (metodo standard)")
            }
            
            // METODO 2: Se il metodo standard fallisce, prova con attributedString
            else if let attributedString = page.attributedString, !attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                pageText = attributedString.string
                successfulExtractions += 1
                print("✅ Pagina \(pageIndex + 1): \(pageText.count) caratteri (metodo attributed)")
            }
            
            // METODO 3: Se tutto fallisce, almeno segna la presenza della pagina
            else {
                pageText = "[PAGINA \(pageIndex + 1) - CONTENUTO NON TESTUALE O PROTETTO]"
                print("⚠️ Pagina \(pageIndex + 1): Contenuto non estraibile (possibile immagine/protetto)")
            }
            
            // Pulisci e formatta il testo estratto
            let cleanedText = cleanAndFormatText(pageText)
            
            extractedText += "=== PAGINA \(pageIndex + 1) ===\n"
            extractedText += cleanedText
            extractedText += "\n\n"
        }
        
        // ⭐ ANALISI QUALITÀ ESTRAZIONE
        let extractionQuality = Double(successfulExtractions) / Double(pageCount)
        metadata["Qualità estrazione"] = String(format: "%.0f%%", extractionQuality * 100)
        
        print("📊 Qualità estrazione: \(successfulExtractions)/\(pageCount) pagine (\(String(format: "%.0f%%", extractionQuality * 100)))")
        
        let finalContent = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let success = !finalContent.isEmpty && extractionQuality > 0
        
        if success {
            print("✅ PDF elaborato con successo: \(finalContent.count) caratteri totali")
        } else {
            print("❌ PDF non contiene testo estraibile")
        }
        
        return (success ? finalContent : nil, metadata, success)
    }
    
    // ⭐ PULIZIA E FORMATTAZIONE TESTO AVANZATA
    static func cleanAndFormatText(_ text: String) -> String {
        var cleaned = text
        
        // Normalizza i caratteri di a capo
        cleaned = cleaned.replacingOccurrences(of: "\r\n", with: "\n")
        cleaned = cleaned.replacingOccurrences(of: "\r", with: "\n")
        
        // Rimuove caratteri di controllo strani
        cleaned = cleaned.replacingOccurrences(of: "\u{00A0}", with: " ") // Non-breaking space
        cleaned = cleaned.replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
        cleaned = cleaned.replacingOccurrences(of: "\u{FEFF}", with: "") // BOM
        
        // Gestisce righe multiple vuote
        let lines = cleaned.components(separatedBy: .newlines)
        var processedLines: [String] = []
        var consecutiveEmptyLines = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty {
                consecutiveEmptyLines += 1
                // Mantieni massimo 2 righe vuote consecutive
                if consecutiveEmptyLines <= 2 {
                    processedLines.append("")
                }
            } else {
                consecutiveEmptyLines = 0
                // Pulisce spazi multipli nella riga
                let cleanLine = trimmedLine.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                processedLines.append(cleanLine)
            }
        }
        
        return processedLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // ⭐ LETTURA FILE DI TESTO ROBUSTA
    static func extractTextFromFile(url: URL) -> (content: String?, metadata: [String: String], success: Bool) {
        let ext = url.pathExtension.lowercased()
        var metadata: [String: String] = [:]
        
        metadata["Tipo"] = ext.uppercased()
        metadata["Dimensione"] = formatFileSize(url: url)
        metadata["Nome"] = url.lastPathComponent
        
        do {
            // Prova diverse codifiche
            var content: String?
            
            // METODO 1: UTF-8 (più comune)
            do {
                content = try String(contentsOf: url, encoding: .utf8)
                metadata["Codifica"] = "UTF-8"
                print("✅ File letto con codifica UTF-8")
            } catch {
                // METODO 2: ISO Latin 1
                do {
                    content = try String(contentsOf: url, encoding: .isoLatin1)
                    metadata["Codifica"] = "ISO Latin 1"
                    print("✅ File letto con codifica ISO Latin 1")
                } catch {
                    // METODO 3: Windows Latin 1
                    do {
                        content = try String(contentsOf: url, encoding: .windowsCP1252)
                        metadata["Codifica"] = "Windows CP1252"
                        print("✅ File letto con codifica Windows CP1252")
                    } catch {
                        print("❌ Impossibile leggere il file con nessuna codifica")
                        return (nil, metadata, false)
                    }
                }
            }
            
            guard let finalContent = content, !finalContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                print("⚠️ File vuoto o solo spazi")
                return (nil, metadata, false)
            }
            
            let cleanContent = cleanAndFormatText(finalContent)
            metadata["Caratteri"] = "\(cleanContent.count)"
            metadata["Righe"] = "\(cleanContent.components(separatedBy: .newlines).count)"
            
            print("✅ File di testo elaborato: \(cleanContent.count) caratteri, \(cleanContent.components(separatedBy: .newlines).count) righe")
            
            return (cleanContent, metadata, true)
            
        } catch {
            print("❌ Errore lettura file: \(error.localizedDescription)")
            metadata["Errore"] = error.localizedDescription
            return (nil, metadata, false)
        }
    }
    
    // ⭐ RICONOSCIMENTO TIPO DOCUMENTO INTELLIGENTE
    static func intelligentDocumentTypeDetection(_ content: String, filename: String) -> (tipo: TipoDocumento, confidence: Double) {
        let contentLower = content.lowercased()
        let filenameLower = filename.lowercased()
        
        // ⭐ PATTERN MATCHING AVANZATO
        let patterns: [(pattern: [String], tipo: TipoDocumento, weight: Double)] = [
            // Autorizzazione Trasporto
            (["trasporto", "cadavere", "verbale", "chiusura", "feretro", "salma"], .autorizzazioneTrasporto, 3.0),
            (["autorizzazione", "trasporto", "mortuario"], .autorizzazioneTrasporto, 2.5),
            (["art.", "l.r.", "regione", "funebre"], .autorizzazioneTrasporto, 2.0),
            
            // Comunicazione Parrocchia
            (["parrocchia", "funerale", "chiesa", "parroco", "celebrazione"], .comunicazioneParrocchia, 3.0),
            (["messa", "rito", "religioso", "sacerdote"], .comunicazioneParrocchia, 2.5),
            (["benedizione", "suffragio", "commemorazione"], .comunicazioneParrocchia, 2.0),
            
            // Certificato Morte
            (["certificato", "morte", "decesso", "medico", "causa"], .certificatoMorte, 3.0),
            (["autopsia", "patologico", "clinico"], .certificatoMorte, 2.5),
            (["istat", "codice icd"], .certificatoMorte, 2.0),
            
            // Checklist Funerale
            (["checklist", "lista", "controllo", "verifica", "procedura"], .checklistFunerale, 3.0),
            (["elenco", "inventario", "promemoria"], .checklistFunerale, 2.0),
            (["step", "passaggio", "fase"], .checklistFunerale, 1.5),
            
            // Fattura
            (["fattura", "importo", "euro", "€", "iva", "totale"], .fattura, 3.0),
            (["pagamento", "bonifico", "conto", "addebito"], .fattura, 2.5),
            (["codice fiscale", "partita iva", "scontrino"], .fattura, 2.0),
            
            // Contratto
            (["contratto", "accordo", "clausola", "condizioni"], .contratto, 3.0),
            (["parti contraenti", "sottoscritto", "firma"], .contratto, 2.5),
            (["servizi funebri", "prestazioni"], .contratto, 2.0),
            
            // Ricevuta
            (["ricevuta", "quietanza", "pagato", "versamento"], .ricevuta, 3.0),
            (["ricevuto", "acconto", "saldo"], .ricevuta, 2.5),
        ]
        
        var scores: [TipoDocumento: Double] = [:]
        
        // ⭐ ANALISI CONTENUTO
        for (keywords, tipo, weight) in patterns {
            var matchScore: Double = 0
            
            for keyword in keywords {
                if contentLower.contains(keyword) {
                    matchScore += weight
                    print("📝 Rilevato '\(keyword)' per tipo \(tipo.rawValue)")
                }
            }
            
            if matchScore > 0 {
                scores[tipo, default: 0] += matchScore
            }
        }
        
        // ⭐ ANALISI NOME FILE
        let filenamePatterns: [(pattern: String, tipo: TipoDocumento, bonus: Double)] = [
            ("trasporto", .autorizzazioneTrasporto, 2.0),
            ("autorizzazione", .autorizzazioneTrasporto, 2.0),
            ("parrocchia", .comunicazioneParrocchia, 2.0),
            ("chiesa", .comunicazioneParrocchia, 1.5),
            ("certificato", .certificatoMorte, 2.0),
            ("morte", .certificatoMorte, 2.0),
            ("fattura", .fattura, 2.0),
            ("contratto", .contratto, 2.0),
            ("ricevuta", .ricevuta, 2.0),
            ("checklist", .checklistFunerale, 2.0),
        ]
        
        for (pattern, tipo, bonus) in filenamePatterns {
            if filenameLower.contains(pattern) {
                scores[tipo, default: 0] += bonus
                print("📂 Nome file contiene '\(pattern)' per tipo \(tipo.rawValue)")
            }
        }
        
        // ⭐ TROVA IL TIPO CON SCORE PIÙ ALTO
        if let (bestType, bestScore) = scores.max(by: { $0.value < $1.value }), bestScore > 0 {
            let totalPossibleScore = patterns.map { $0.weight * Double($0.pattern.count) }.reduce(0, +) + 4.0 // filename bonus
            let confidence = min(bestScore / totalPossibleScore, 0.95) // Max 95% confidence
            
            print("🎯 Tipo rilevato: \(bestType.rawValue) con confidence \(String(format: "%.1f%%", confidence * 100))")
            return (bestType, confidence)
        }
        
        print("❓ Tipo non riconosciuto, assegnato 'Altro'")
        return (.altro, 0.1)
    }
    
    // ⭐ GENERAZIONE CONTENUTO POTENZIATA
    static func generateEnhancedContent(originalContent: String, metadata: [String: String], filename: String, detectedType: TipoDocumento, confidence: Double) -> String {
        let timestamp = Date().formatted(date: .abbreviated, time: .shortened)
        
        var content = """
        🔍 DOCUMENTO ANALIZZATO CON SISTEMA AVANZATO
        📅 Elaborato il: \(timestamp)
        📂 File originale: \(filename)
        📊 Tipo rilevato: \(detectedType.rawValue) (Confidence: \(String(format: "%.1f%%", confidence * 100)))
        
        """
        
        // ⭐ METADATI DETTAGLIATI
        if !metadata.isEmpty {
            content += "📋 INFORMAZIONI FILE:\n"
            for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
                content += "• \(key): \(value)\n"
            }
            content += "\n"
        }
        
        // ⭐ ANALISI CONTENUTO
        let wordCount = originalContent.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let lineCount = originalContent.components(separatedBy: .newlines).count
        let charCount = originalContent.count
        
        content += """
        📊 ANALISI CONTENUTO:
        • Caratteri: \(charCount)
        • Parole: \(wordCount)
        • Righe: \(lineCount)
        • Tipo rilevato: \(detectedType.rawValue)
        
        """
        
        content += String(repeating: "=", count: 60) + "\n"
        content += "CONTENUTO ESTRATTO:\n"
        content += String(repeating: "=", count: 60) + "\n\n"
        
        content += originalContent
        
        content += "\n\n" + String(repeating: "-", count: 50)
        content += "\n✨ Elaborato con Sistema di Lettura Documenti Avanzato"
        content += "\n⚡ Qualità estrazione: \(metadata["Qualità estrazione"] ?? "N/A")"
        
        return content
    }
    
    // ⭐ HELPER: Formatta dimensione file
    static func formatFileSize(url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                return formatter.string(fromByteCount: fileSize)
            }
        } catch {
            return "Sconosciuta"
        }
        return "Sconosciuta"
    }
}

// MARK: - ⭐ ENHANCED FILE PROCESSOR AGGIORNATO

class RobustFileProcessor {
    
    // ⭐ NUOVO METODO CON NOME DIVERSO PER EVITARE CONFLITTI
    static func processFileWithRobustAI(url: URL, aiManager: CompatibleAIManager) async -> DocumentoTemplate? {
        let filename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.lowercased()
        
        print("🚀 Inizio elaborazione robusta: \(filename).\(ext)")
        
        var finalContent = ""
        var metadata: [String: String] = [:]
        var detectedType: TipoDocumento = .altro
        var confidence: Double = 0.1
        var success = false
        
        // ⭐ ELABORAZIONE SPECIFICA PER TIPO FILE
        switch ext {
        case "pdf":
            let (content, pdfMetadata, pdfSuccess) = RobustDocumentReader.extractTextFromPDF(url: url)
            if let content = content {
                finalContent = content
                metadata = pdfMetadata
                success = pdfSuccess
                
                // Rileva tipo documento
                let detection = RobustDocumentReader.intelligentDocumentTypeDetection(content, filename: filename)
                detectedType = detection.tipo
                confidence = detection.confidence * 0.9 // Leggero penalty per PDF
            }
            
        case "txt", "rtf":
            let (content, textMetadata, textSuccess) = RobustDocumentReader.extractTextFromFile(url: url)
            if let content = content {
                finalContent = content
                metadata = textMetadata
                success = textSuccess
                
                // Rileva tipo documento
                let detection = RobustDocumentReader.intelligentDocumentTypeDetection(content, filename: filename)
                detectedType = detection.tipo
                confidence = detection.confidence // Nessun penalty per file di testo
            }
            
        case "doc", "docx":
            finalContent = "📄 Documento Microsoft Word: \(filename)\n\n[Il sistema non supporta ancora l'estrazione automatica da file Word.\nPer elaborare questo documento, salvalo come PDF o file di testo.]"
            metadata["Tipo"] = "Microsoft Word"
            metadata["Supporto"] = "Parziale"
            success = false
            confidence = 0.1
            
        default:
            finalContent = "📎 File di tipo sconosciuto: \(filename).\(ext)\n\n[Tipo file non supportato per l'elaborazione automatica.\nTipi supportati: PDF, TXT, RTF]"
            metadata["Tipo"] = ext.uppercased()
            metadata["Supporto"] = "Non supportato"
            success = false
            confidence = 0.1
        }
        
        // ⭐ GENERA TEMPLATE SE SUCCESSO
        if success && !finalContent.isEmpty {
            let enhancedContent = RobustDocumentReader.generateEnhancedContent(
                originalContent: finalContent,
                metadata: metadata,
                filename: filename,
                detectedType: detectedType,
                confidence: confidence
            )
            
            var template = DocumentoTemplate(
                nome: "AI-\(detectedType.rawValue)-\(filename)",
                tipo: detectedType,
                contenuto: enhancedContent,
                operatoreCreazione: "Sistema AI Robusta"
            )
            
            template.markAsAIGenerated(confidence: confidence)
            
            print("✅ Template creato con successo: \(template.nome)")
            return template
        }
        
        print("❌ Elaborazione fallita per: \(filename).\(ext)")
        return nil
    }
}



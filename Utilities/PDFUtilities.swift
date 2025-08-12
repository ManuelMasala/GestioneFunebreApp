//
//  PDFUtilities.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import Foundation
import PDFKit
import Vision
import AppKit

// MARK: - PDF Processing Utilities
class PDFProcessor {
    
    /// Estrae testo da un PDF utilizzando PDFKit
    static func extractTextFromPDF(at url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw AIProcessingError.pdfLoadFailed
        }
        
        var extractedText = ""
        
        // Prova prima con l'estrazione diretta del testo
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    extractedText += pageText + "\n"
                }
            }
        }
        
        // Se il testo estratto è troppo poco, usa OCR
        if extractedText.trimmingCharacters(in: .whitespacesAndNewlines).count < 50 {
            extractedText = try await extractTextFromPDFWithOCR(document: pdfDocument)
        }
        
        return extractedText
    }
    
    /// Estrae testo da PDF usando OCR (per PDF scansionati)
    private static func extractTextFromPDFWithOCR(document: PDFDocument) async throws -> String {
        var allText = ""
        let maxPages = min(document.pageCount, 10) // Limita a 10 pagine per performance
        
        for pageIndex in 0..<maxPages {
            if let page = document.page(at: pageIndex) {
                // Converti la pagina PDF in immagine
                let pageImage = page.thumbnail(of: CGSize(width: 2000, height: 2000), for: .artBox)
                
                // Applica OCR all'immagine
                let text = try await performOCR(on: pageImage)
                allText += text + "\n"
            }
        }
        
        return allText
    }
    
    /// Esegue OCR su un'immagine NSImage
    static func performOCR(on image: NSImage) async throws -> String {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw AIProcessingError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: recognizedText)
            }
            
            // Configurazione OCR per massima accuratezza
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["it-IT", "en-US"]
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Estrae metadati dal PDF
    static func extractPDFMetadata(from url: URL) -> PDFMetadata? {
        guard let pdfDocument = PDFDocument(url: url) else {
            return nil
        }
        
        let documentAttributes = pdfDocument.documentAttributes
        
        return PDFMetadata(
            title: documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String,
            author: documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String,
            subject: documentAttributes?[PDFDocumentAttribute.subjectAttribute] as? String,
            creator: documentAttributes?[PDFDocumentAttribute.creatorAttribute] as? String,
            producer: documentAttributes?[PDFDocumentAttribute.producerAttribute] as? String,
            creationDate: documentAttributes?[PDFDocumentAttribute.creationDateAttribute] as? Date,
            modificationDate: documentAttributes?[PDFDocumentAttribute.modificationDateAttribute] as? Date,
            pageCount: pdfDocument.pageCount,
            isEncrypted: pdfDocument.isEncrypted,
            allowsCopying: pdfDocument.allowsCopying,
            allowsPrinting: pdfDocument.allowsPrinting
        )
    }
    
    /// Ottimizza un'immagine per OCR
    static func optimizeImageForOCR(_ image: NSImage) -> NSImage {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return image
        }
        
        // Crea un contesto con maggiore risoluzione
        let scale: CGFloat = 2.0
        let width = Int(image.size.width * scale)
        let height = Int(image.size.height * scale)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return image
        }
        
        // Disegna l'immagine in scala di grigi per migliorare l'OCR
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let optimizedCGImage = context.makeImage() else {
            return image
        }
        
        let optimizedImage = NSImage(cgImage: optimizedCGImage, size: NSSize(width: CGFloat(width), height: CGFloat(height)))
        return optimizedImage
    }
    
    /// Verifica se un PDF contiene testo estraibile
    static func hasExtractableText(in pdfDocument: PDFDocument) -> Bool {
        // Controlla le prime pagine per vedere se contengono testo
        let pagesToCheck = min(pdfDocument.pageCount, 3)
        
        for pageIndex in 0..<pagesToCheck {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string,
               pageText.trimmingCharacters(in: .whitespacesAndNewlines).count > 20 {
                return true
            }
        }
        
        return false
    }
}

// MARK: - PDF Metadata
struct PDFMetadata {
    let title: String?
    let author: String?
    let subject: String?
    let creator: String?
    let producer: String?
    let creationDate: Date?
    let modificationDate: Date?
    let pageCount: Int
    let isEncrypted: Bool
    let allowsCopying: Bool
    let allowsPrinting: Bool
    
    var formattedInfo: String {
        var info: [String] = []
        
        if let title = title, !title.isEmpty {
            info.append("Titolo: \(title)")
        }
        
        if let author = author, !author.isEmpty {
            info.append("Autore: \(author)")
        }
        
        info.append("Pagine: \(pageCount)")
        
        if let creationDate = creationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            info.append("Creato: \(formatter.string(from: creationDate))")
        }
        
        if isEncrypted {
            info.append("Documento crittografato")
        }
        
        return info.joined(separator: "\n")
    }
}

// MARK: - Image Processing Utilities
class ImageProcessor {
    
    /// Estrae testo da un'immagine
    static func extractTextFromImage(at url: URL) async throws -> String {
        guard let image = NSImage(contentsOf: url) else {
            throw AIProcessingError.imageLoadFailed
        }
        
        // Ottimizza l'immagine per OCR
        let optimizedImage = PDFProcessor.optimizeImageForOCR(image)
        
        return try await PDFProcessor.performOCR(on: optimizedImage)
    }
    
    /// Valida se un'immagine è adatta per OCR
    static func validateImageForOCR(_ image: NSImage) -> ImageValidationResult {
        var issues: [String] = []
        var suggestions: [String] = []
        
        // Controlla risoluzione
        if image.size.width < 800 || image.size.height < 600 {
            issues.append("Risoluzione bassa")
            suggestions.append("Usa un'immagine di almeno 800x600 pixel")
        }
        
        // Controlla formato
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            issues.append("Formato immagine non supportato")
            return ImageValidationResult(isValid: false, issues: issues, suggestions: suggestions)
        }
        
        // Controlla se l'immagine è troppo grande
        if cgImage.width > 4000 || cgImage.height > 4000 {
            suggestions.append("Considera di ridurre la dimensione per velocizzare l'elaborazione")
        }
        
        return ImageValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            suggestions: suggestions
        )
    }
}

// MARK: - Image Validation Result
struct ImageValidationResult {
    let isValid: Bool
    let issues: [String]
    let suggestions: [String]
    
    var hasWarnings: Bool {
        return !suggestions.isEmpty
    }
}

// MARK: - File Utilities
class FileProcessor {
    
    /// Determina il tipo di file e lo elabora di conseguenza
    static func processFile(at url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await PDFProcessor.extractTextFromPDF(at: url)
        case "jpg", "jpeg", "png", "tiff", "tif", "bmp":
            return try await ImageProcessor.extractTextFromImage(at: url)
        default:
            throw AIProcessingError.unsupportedFileType
        }
    }
    
    /// Verifica se un file è supportato
    static func isSupportedFile(_ url: URL) -> Bool {
        let supportedExtensions = ["pdf", "jpg", "jpeg", "png", "tiff", "tif", "bmp"]
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
    
    /// Ottiene informazioni su un file
    static func getFileInfo(for url: URL) -> FileProcessingInfo? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [
                .fileSizeKey,
                .nameKey,
                .typeIdentifierKey,
                .creationDateKey
            ])
            
            return FileProcessingInfo(
                fileURL: url,
                fileName: resourceValues.name ?? url.lastPathComponent,
                fileSize: Int64(resourceValues.fileSize ?? 0),
                fileType: resourceValues.typeIdentifier ?? "unknown",
                processingDate: Date()
            )
        } catch {
            return nil
        }
    }
    
    /// Verifica i limiti di dimensione del file
    static func validateFileSize(_ url: URL, maxSizeMB: Int = 50) throws {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = resourceValues.fileSize ?? 0
            let maxSizeBytes = maxSizeMB * 1024 * 1024
            
            if fileSize > maxSizeBytes {
                throw AIProcessingError.documentTooLarge
            }
        } catch {
            if error is AIProcessingError {
                throw error
            }
            // Se non riusciamo a leggere la dimensione, continuiamo
        }
    }
}

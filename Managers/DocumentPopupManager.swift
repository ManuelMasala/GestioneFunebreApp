//
//  DocumentPopupManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 25/07/25.
//

import SwiftUI
import Foundation

// MARK: - ⭐ DOCUMENT POPUP MANAGER

@MainActor
class DocumentPopupManager: ObservableObject {
    static let shared = DocumentPopupManager()
    
    // ⭐ PUBLISHED PROPERTIES
    @Published var showTemplateSelectionPopup = false
    @Published var showFieldEditingPopup = false
    @Published var showDocumentPreview = false
    @Published var showExtractionResult = false
    
    // ⭐ DOCUMENT STATE
    @Published var extractedContent = ""
    @Published var selectedTemplate: PopupTipoDocumento = .altro
    @Published var documentFields: [String: String] = [:]
    @Published var previewContent = ""
    
    // ⭐ UI STATE
    @Published var isProcessing = false
    @Published var lastProcessedFileName = ""
    
    private init() {}
    
    // MARK: - ⭐ TEMPLATE SELECTION
    
    func showTemplateSelection(for extractedText: String, fileName: String) {
        extractedContent = extractedText
        lastProcessedFileName = fileName
        selectedTemplate = detectTemplateType(from: fileName)
        showTemplateSelectionPopup = true
    }
    
    private func detectTemplateType(from fileName: String) -> PopupTipoDocumento {
        let lowercaseFileName = fileName.lowercased()
        
        if lowercaseFileName.contains("visita") && lowercaseFileName.contains("necroscopica") {
            return .visitaNecroscopica
        } else if lowercaseFileName.contains("trasporto") {
            return .autorizzazioneTrasporto
        } else if lowercaseFileName.contains("parrocchia") {
            return .comunicazioneParrocchia
        } else if lowercaseFileName.contains("fattura") {
            return .fattura
        } else if lowercaseFileName.contains("contratto") {
            return .contratto
        } else if lowercaseFileName.contains("certificato") && lowercaseFileName.contains("morte") {
            return .certificatoMorte
        }
        
        return .altro
    }
    
    // MARK: - ⭐ FIELD MANAGEMENT
    
    func proceedWithTemplate() {
        showTemplateSelectionPopup = false
        setupFieldsForTemplate()
        showFieldEditingPopup = true
    }
    
    private func setupFieldsForTemplate() {
        documentFields.removeAll()
        
        switch selectedTemplate {
        case .visitaNecroscopica:
            setupVisitaNecroscopicaFields()
        case .autorizzazioneTrasporto:
            setupAutorizzazioneTrasportoFields()
        case .comunicazioneParrocchia:
            setupComunicazioneParrocchiaFields()
        case .fattura:
            setupFatturaFields()
        case .contratto:
            setupContrattoFields()
        case .certificatoMorte:
            setupCertificatoMorteFields()
        case .altro:
            setupGenericFields()
        }
        
        // ⭐ POPOLA AUTOMATICAMENTE ALCUNI CAMPI
        autoPopulateCommonFields()
    }
    
    // MARK: - ⭐ TEMPLATE SPECIFIC FIELDS
    
    private func setupVisitaNecroscopicaFields() {
        documentFields = [
            "COMUNE": "Milano",
            "NOME_RICHIEDENTE": "Dr. Mario Rossi",
            "QUALIFICA": "Medico di famiglia",
            "NOME_DEFUNTO": "",
            "COGNOME_DEFUNTO": "",
            "LUOGO_NASCITA": "",
            "DATA_NASCITA": "",
            "DATA_DECESSO": PopupDateFormatter.shortDate.string(from: Date()),
            "ORA_DECESSO": "",
            "LUOGO_DECESSO": "",
            "MOTIVO_RICHIESTA": "Accertamento cause di morte",
            "LUOGO_CUSTODIA": "Obitorio Ospedale San Raffaele",
            "ALTRI_ALLEGATI": "Cartella clinica",
            "DATA_RICHIESTA": PopupDateFormatter.shortDate.string(from: Date())
        ]
    }
    
    private func setupAutorizzazioneTrasportoFields() {
        documentFields = [
            "COMUNE": "Milano",
            "NOME_RICHIEDENTE": "",
            "RESIDENZA_RICHIEDENTE": "",
            "LUOGO_NASCITA_RICHIEDENTE": "",
            "DATA_NASCITA_RICHIEDENTE": "",
            "NOME_DEFUNTO": "",
            "COGNOME_DEFUNTO": "",
            "LUOGO_NASCITA": "",
            "DATA_NASCITA": "",
            "DATA_DECESSO": PopupDateFormatter.shortDate.string(from: Date()),
            "LUOGO_PARTENZA": "",
            "LUOGO_DESTINAZIONE": "",
            "TIPO_VEICOLO": "Carro funebre",
            "TARGA": "",
            "DITTA_TRASPORTO": "Impresa Funebre Milano SRL",
            "MOTIVO_TRASPORTO": "Trasferimento per sepoltura",
            "DATA_TRASPORTO": PopupDateFormatter.shortDate.string(from: Date()),
            "LUOGO": "Milano",
            "DATA": PopupDateFormatter.shortDate.string(from: Date())
        ]
    }
    
    private func setupComunicazioneParrocchiaFields() {
        documentFields = [
            "NOME_PARROCCHIA": "",
            "INDIRIZZO_PARROCCHIA": "",
            "DATA_DECESSO": PopupDateFormatter.shortDate.string(from: Date()),
            "NOME_DEFUNTO": "",
            "COGNOME_DEFUNTO": "",
            "LUOGO_NASCITA": "",
            "DATA_NASCITA": "",
            "TIPO_FUNZIONE": "Messa di suffragio",
            "DATA_FUNZIONE": PopupDateFormatter.shortDate.string(from: Date().addingTimeInterval(86400 * 3)),
            "ORARIO_FUNZIONE": "10:00",
            "NOTE": "",
            "NOME_CONTATTO": "",
            "TELEFONO_CONTATTO": "",
            "NOME_OPERATORE": "Servizi Funebri Milano",
            "IMPRESA_FUNEBRE": "Impresa Funebre Milano SRL"
        ]
    }
    
    private func setupFatturaFields() {
        documentFields = [
            "NUMERO_FATTURA": generateFatturaNumber(),
            "NOME_IMPRESA": "Impresa Funebre Milano SRL",
            "INDIRIZZO_IMPRESA": "Via Roma 123, 20100 Milano",
            "PARTITA_IVA": "12345678901",
            "NOME_CLIENTE": "",
            "INDIRIZZO_CLIENTE": "",
            "CODICE_FISCALE_CLIENTE": "",
            "DATA_FATTURA": PopupDateFormatter.shortDate.string(from: Date()),
            "DESCRIZIONE_SERVIZI": "Servizi funebri completi",
            "IMPONIBILE": "2500,00",
            "ALIQUOTA_IVA": "22",
            "IMPORTO_IVA": "550,00",
            "TOTALE": "3050,00",
            "TERMINI_PAGAMENTO": "30 giorni data fattura",
            "DATA_SCADENZA": PopupDateFormatter.shortDate.string(from: Date().addingTimeInterval(86400 * 30))
        ]
    }
    
    private func setupContrattoFields() {
        documentFields = [
            "TIPO_DOCUMENTO": "Contratto Servizi Funebri",
            "DATA_ELABORAZIONE": PopupDateFormatter.shortDate.string(from: Date()),
            "CONTENUTO_PRINCIPALE": "Contratto per prestazione di servizi funebri completi",
            "NOTE_AGGIUNTIVE": "Clausole standard applicate",
            "OPERATORE": "Staff FunerApp"
        ]
    }
    
    private func setupCertificatoMorteFields() {
        documentFields = [
            "TIPO_DOCUMENTO": "Certificato di Morte",
            "DATA_ELABORAZIONE": PopupDateFormatter.shortDate.string(from: Date()),
            "CONTENUTO_PRINCIPALE": "Certificazione ufficiale del decesso",
            "NOTE_AGGIUNTIVE": "Documento ufficiale",
            "OPERATORE": "Ufficiale Stato Civile"
        ]
    }
    
    private func setupGenericFields() {
        documentFields = [
            "TIPO_DOCUMENTO": "Documento Generico",
            "DATA_ELABORAZIONE": PopupDateFormatter.shortDate.string(from: Date()),
            "CONTENUTO_PRINCIPALE": "",
            "NOTE_AGGIUNTIVE": "",
            "OPERATORE": "Staff FunerApp"
        ]
    }
    
    // MARK: - ⭐ AUTO POPULATION
    
    private func autoPopulateCommonFields() {
        // Popola automaticamente data corrente se non presente
        let currentDate = PopupDateFormatter.shortDate.string(from: Date())
        
        if documentFields["DATA"] == nil || documentFields["DATA"]?.isEmpty == true {
            documentFields["DATA"] = currentDate
        }
        
        if documentFields["DATA_ELABORAZIONE"] == nil || documentFields["DATA_ELABORAZIONE"]?.isEmpty == true {
            documentFields["DATA_ELABORAZIONE"] = currentDate
        }
        
        // Estrai informazioni dal contenuto estratto se possibile
        extractDataFromContent()
    }
    
    private func extractDataFromContent() {
        let content = extractedContent.lowercased()
        
        // Cerca nomi comuni nei documenti
        let namePatterns = [
            "defunto[^a-zA-Z]*([A-Z][a-z]+\\s+[A-Z][a-z]+)",
            "deceduto[^a-zA-Z]*([A-Z][a-z]+\\s+[A-Z][a-z]+)",
            "sig\\.?\\s*([A-Z][a-z]+\\s+[A-Z][a-z]+)"
        ]
        
        for pattern in namePatterns {
            if let match = extractedContent.range(of: pattern, options: .regularExpression) {
                let foundName = String(extractedContent[match])
                if documentFields["NOME_DEFUNTO"]?.isEmpty == true && documentFields["COGNOME_DEFUNTO"]?.isEmpty == true {
                    let nameParts = foundName.components(separatedBy: " ")
                    if nameParts.count >= 2 {
                        documentFields["NOME_DEFUNTO"] = nameParts[0]
                        documentFields["COGNOME_DEFUNTO"] = nameParts[1]
                    }
                }
                break
            }
        }
        
        // Cerca date
        let datePattern = "\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}"
        if let dateMatch = extractedContent.range(of: datePattern, options: .regularExpression) {
            let foundDate = String(extractedContent[dateMatch])
            if documentFields["DATA_DECESSO"]?.isEmpty == true {
                documentFields["DATA_DECESSO"] = foundDate
            }
        }
        
        // Cerca luoghi
        if content.contains("milano") && documentFields["COMUNE"]?.isEmpty == true {
            documentFields["COMUNE"] = "Milano"
        }
        if content.contains("roma") && documentFields["COMUNE"]?.isEmpty == true {
            documentFields["COMUNE"] = "Roma"
        }
    }
    
    // MARK: - ⭐ DOCUMENT GENERATION
    
    func generateFinalDocument() {
        var template = getTemplateContent()
        
        // Sostituisci tutti i placeholder
        for (key, value) in documentFields {
            template = template.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        
        previewContent = template
        showFieldEditingPopup = false
        showDocumentPreview = true
    }
    
    private func getTemplateContent() -> String {
        switch selectedTemplate {
        case .visitaNecroscopica:
            return getVisitaNecroscopicaTemplate()
        case .autorizzazioneTrasporto:
            return getAutorizzazioneTrasportoTemplate()
        case .comunicazioneParrocchia:
            return getComunicazioneParrocchiaTemplate()
        case .fattura:
            return getFatturaTemplate()
        case .contratto:
            return getContrattoTemplate()
        case .certificatoMorte:
            return getCertificatoMorteTemplate()
        case .altro:
            return getGenericTemplate()
        }
    }
    
    // MARK: - ⭐ TEMPLATE STRINGS
    
    private func getVisitaNecroscopicaTemplate() -> String {
        return """
        RICHIESTA VISITA NECROSCOPICA
        
        Al Sindaco del Comune di {{COMUNE}}
        
        Il sottoscritto {{NOME_RICHIEDENTE}}, in qualità di {{QUALIFICA}},
        
        CHIEDE
        
        che venga effettuata visita necroscopica sulla salma di:
        
        Nome e Cognome: {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
        Nato/a a: {{LUOGO_NASCITA}} il {{DATA_NASCITA}}
        Deceduto/a il: {{DATA_DECESSO}} alle ore {{ORA_DECESSO}}
        Presso: {{LUOGO_DECESSO}}
        
        Motivo della richiesta: {{MOTIVO_RICHIESTA}}
        
        La salma è attualmente custodita presso: {{LUOGO_CUSTODIA}}
        
        Si allega:
        - Certificato di morte
        - Documento di identità del richiedente
        - {{ALTRI_ALLEGATI}}
        
        Distinti saluti.
        
        Data: {{DATA_RICHIESTA}}
        
        Firma del richiedente
        {{NOME_RICHIEDENTE}}
        """
    }
    
    private func getAutorizzazioneTrasportoTemplate() -> String {
        return """
        AUTORIZZAZIONE AL TRASPORTO DI SALMA
        
        Al Sindaco del Comune di {{COMUNE}}
        
        Il sottoscritto {{NOME_RICHIEDENTE}}, residente in {{RESIDENZA_RICHIEDENTE}},
        nato/a a {{LUOGO_NASCITA_RICHIEDENTE}} il {{DATA_NASCITA_RICHIEDENTE}},
        
        CHIEDE
        
        l'autorizzazione al trasporto della salma di:
        
        {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
        nato/a a {{LUOGO_NASCITA}} il {{DATA_NASCITA}}
        deceduto/a il {{DATA_DECESSO}}
        
        DA: {{LUOGO_PARTENZA}}
        A: {{LUOGO_DESTINAZIONE}}
        
        Mezzo di trasporto:
        - Tipo veicolo: {{TIPO_VEICOLO}}
        - Targa: {{TARGA}}
        - Ditta di trasporto: {{DITTA_TRASPORTO}}
        
        Motivo del trasporto: {{MOTIVO_TRASPORTO}}
        Data prevista: {{DATA_TRASPORTO}}
        
        Si allega documentazione richiesta.
        
        {{LUOGO}}, {{DATA}}
        
        Firma
        {{NOME_RICHIEDENTE}}
        """
    }
    
    private func getComunicazioneParrocchiaTemplate() -> String {
        return """
        COMUNICAZIONE ALLA PARROCCHIA
        
        Alla Parrocchia di {{NOME_PARROCCHIA}}
        {{INDIRIZZO_PARROCCHIA}}
        
        Reverendo Parroco,
        
        si comunica che il giorno {{DATA_DECESSO}} è deceduto/a:
        
        {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
        nato/a a {{LUOGO_NASCITA}} il {{DATA_NASCITA}}
        
        La famiglia richiede:
        {{TIPO_FUNZIONE}}
        
        Data proposta per la funzione: {{DATA_FUNZIONE}}
        Orario preferito: {{ORARIO_FUNZIONE}}
        
        Note particolari: {{NOTE}}
        
        Per ulteriori informazioni contattare:
        {{NOME_CONTATTO}} - Tel: {{TELEFONO_CONTATTO}}
        
        Cordiali saluti.
        
        {{NOME_OPERATORE}}
        {{IMPRESA_FUNEBRE}}
        """
    }
    
    private func getFatturaTemplate() -> String {
        return """
        FATTURA N. {{NUMERO_FATTURA}}
        
        {{NOME_IMPRESA}}
        {{INDIRIZZO_IMPRESA}}
        P.IVA: {{PARTITA_IVA}}
        
        Cliente:
        {{NOME_CLIENTE}}
        {{INDIRIZZO_CLIENTE}}
        C.F./P.IVA: {{CODICE_FISCALE_CLIENTE}}
        
        Data: {{DATA_FATTURA}}
        
        DESCRIZIONE SERVIZI:
        
        {{DESCRIZIONE_SERVIZI}}
        
        Totale imponibile: €{{IMPONIBILE}}
        IVA ({{ALIQUOTA_IVA}}%): €{{IMPORTO_IVA}}
        
        TOTALE: €{{TOTALE}}
        
        Termini di pagamento: {{TERMINI_PAGAMENTO}}
        Scadenza: {{DATA_SCADENZA}}
        """
    }
    
    private func getContrattoTemplate() -> String {
        return """
        CONTRATTO SERVIZI FUNEBRI
        
        Tra {{NOME_IMPRESA}} e {{NOME_CLIENTE}}
        
        Data: {{DATA_ELABORAZIONE}}
        
        {{CONTENUTO_PRINCIPALE}}
        
        Note: {{NOTE_AGGIUNTIVE}}
        
        Operatore: {{OPERATORE}}
        """
    }
    
    private func getCertificatoMorteTemplate() -> String {
        return """
        CERTIFICATO DI MORTE
        
        {{CONTENUTO_PRINCIPALE}}
        
        Data: {{DATA_ELABORAZIONE}}
        
        Note: {{NOTE_AGGIUNTIVE}}
        
        {{OPERATORE}}
        """
    }
    
    private func getGenericTemplate() -> String {
        return """
        {{TIPO_DOCUMENTO}}
        
        Data elaborazione: {{DATA_ELABORAZIONE}}
        
        {{CONTENUTO_PRINCIPALE}}
        
        Note aggiuntive: {{NOTE_AGGIUNTIVE}}
        
        Elaborato da: {{OPERATORE}}
        Sistema: FunerApp
        """
    }
    
    // MARK: - ⭐ UTILITY FUNCTIONS
    
    private func generateFatturaNumber() -> String {
        let year = Calendar.current.component(.year, from: Date())
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(year)-\(timestamp % 10000)"
    }
    
    func resetState() {
        extractedContent = ""
        selectedTemplate = .altro
        documentFields.removeAll()
        previewContent = ""
        lastProcessedFileName = ""
        
        showTemplateSelectionPopup = false
        showFieldEditingPopup = false
        showDocumentPreview = false
        showExtractionResult = false
    }
    
    func updateField(key: String, value: String) {
        documentFields[key] = value
    }
    
    func getFieldValue(key: String) -> String {
        return documentFields[key] ?? ""
    }
}

// MARK: - ⭐ TIPI SPECIFICI PER POPUP (PER EVITARE CONFLITTI)

enum PopupTipoDocumento: String, CaseIterable {
    case visitaNecroscopica = "Richiesta Visita Necroscopica"
    case autorizzazioneTrasporto = "Autorizzazione Trasporto"
    case comunicazioneParrocchia = "Comunicazione Parrocchia"
    case fattura = "Fattura"
    case contratto = "Contratto"
    case certificatoMorte = "Certificato di Morte"
    case altro = "Altro"
}

// MARK: - ⭐ EXTENSIONS

class PopupDateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }()
}

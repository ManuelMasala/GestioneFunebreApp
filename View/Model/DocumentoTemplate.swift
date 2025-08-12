//
//  DocumentoTemplate.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI
import Foundation

// MARK: - Tipo Documento
enum TipoDocumento: String, CaseIterable, Identifiable, Codable {
    case autorizzazioneTrasporto = "Autorizzazione Trasporto"
    case comunicazioneParrocchia = "Comunicazione Parrocchia"
    case checklistFunerale = "Checklist Funerale"
    case certificatoMorte = "Certificato di Morte"
    case dichiarazioneFamiliare = "Dichiarazione Familiare"
    case autorizzazioneSepoltura = "Autorizzazione Sepoltura"
    case comunicazioneCimitero = "Comunicazione Cimitero"
    case fattura = "Fattura"
    case ricevuta = "Ricevuta"
    case contratto = "Contratto"
    case altro = "Altro"
    
    var id: String { rawValue }
    
    var icona: String {
        switch self {
        case .autorizzazioneTrasporto: return "car.2.fill"
        case .comunicazioneParrocchia: return "building.columns.fill"
        case .checklistFunerale: return "checklist"
        case .certificatoMorte: return "doc.text.fill"
        case .dichiarazioneFamiliare: return "person.2.fill"
        case .autorizzazioneSepoltura: return "leaf.fill"
        case .comunicazioneCimitero: return "building.fill"
        case .fattura: return "eurosign.circle.fill"
        case .ricevuta: return "receipt.fill"
        case .contratto: return "doc.plaintext.fill"
        case .altro: return "doc.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .autorizzazioneTrasporto: return .blue
        case .comunicazioneParrocchia: return .purple
        case .checklistFunerale: return .green
        case .certificatoMorte: return .red
        case .dichiarazioneFamiliare: return .orange
        case .autorizzazioneSepoltura: return .brown
        case .comunicazioneCimitero: return .gray
        case .fattura: return .yellow
        case .ricevuta: return .mint
        case .contratto: return .indigo
        case .altro: return .secondary
        }
    }
    
    var descrizione: String {
        switch self {
        case .autorizzazioneTrasporto: return "Documenti per autorizzare il trasporto della salma"
        case .comunicazioneParrocchia: return "Comunicazioni alla parrocchia per funzioni religiose"
        case .checklistFunerale: return "Lista di controllo per organizzazione funerale"
        case .certificatoMorte: return "Certificati e documenti relativi al decesso"
        case .dichiarazioneFamiliare: return "Dichiarazioni e consensi dei familiari"
        case .autorizzazioneSepoltura: return "Autorizzazioni per sepoltura o cremazione"
        case .comunicazioneCimitero: return "Comunicazioni al cimitero"
        case .fattura: return "Fatture per servizi funebri"
        case .ricevuta: return "Ricevute di pagamento"
        case .contratto: return "Contratti per servizi funebri"
        case .altro: return "Altri tipi di documento"
        }
    }
}

// MARK: - Documento Template
struct DocumentoTemplate: Identifiable, Codable, Hashable {
    let id = UUID()
    var nome: String
    var tipo: TipoDocumento
    var contenuto: String
    var campiCompilabili: [CampoDocumento]
    var isDefault: Bool
    var note: String
    var dataCreazione: Date
    var dataUltimaModifica: Date
    var operatoreCreazione: String
    var versione: String
    var isAttivo: Bool
    
    init(nome: String,
         tipo: TipoDocumento,
         contenuto: String,
         campiCompilabili: [CampoDocumento] = [],
         isDefault: Bool = false,
         note: String = "",
         operatoreCreazione: String = "Sistema",
         versione: String = "1.0") {
        
        self.nome = nome
        self.tipo = tipo
        self.contenuto = contenuto
        self.campiCompilabili = campiCompilabili
        self.isDefault = isDefault
        self.note = note
        self.dataCreazione = Date()
        self.dataUltimaModifica = Date()
        self.operatoreCreazione = operatoreCreazione
        self.versione = versione
        self.isAttivo = true
    }
    
    // MARK: - Computed Properties
    var campiObbligatori: [CampoDocumento] {
        return campiCompilabili.filter { $0.obbligatorio }
    }
    
    var numeroPlaceholder: Int {
        let pattern = "\\{\\{([A-Z_]+)\\}\\}"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: contenuto, range: NSRange(contenuto.startIndex..., in: contenuto))
            return matches.count
        } catch {
            return 0
        }
    }
    
    var dataCreazioneFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCreazione)
    }
    
    var dataModificaFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataUltimaModifica)
    }
    
    // MARK: - Methods
    mutating func aggiornaCampo(_ campo: CampoDocumento) {
        if let index = campiCompilabili.firstIndex(where: { $0.id == campo.id }) {
            campiCompilabili[index] = campo
            dataUltimaModifica = Date()
        }
    }
    
    mutating func aggiungiCampo(_ campo: CampoDocumento) {
        campiCompilabili.append(campo)
        dataUltimaModifica = Date()
    }
    
    mutating func rimuoviCampo(id: UUID) {
        campiCompilabili.removeAll { $0.id == id }
        dataUltimaModifica = Date()
    }
    
    func validaContenuto() -> [String] {
        var errori: [String] = []
        
        if nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il nome del template è obbligatorio")
        }
        
        if contenuto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errori.append("Il contenuto del template è obbligatorio")
        }
        
        return errori
    }
    
    func creaDocumentoVuoto() -> DocumentoCompilato {
        return DocumentoCompilato(template: self, defunto: PersonaDefunta())
    }
    
    // MARK: - Conformità Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DocumentoTemplate, rhs: DocumentoTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Template Predefiniti
extension DocumentoTemplate {
    
    static var autorizzazioneTrasporto: DocumentoTemplate {
        return DocumentoTemplate(
            nome: "Autorizzazione Trasporto Funebre",
            tipo: .autorizzazioneTrasporto,
            contenuto: """
            Prot. N.° _____(Luogo e data emissione documento)
            ____________________
            AL SIGNOR SINDACO DI {{COMUNE_DECESSO}}
            
            Il sottoscritto {{NOME_RICHIEDENTE}} nato a {{LUOGO_NASCITA_RICHIEDENTE}} il {{DATA_NASCITA_RICHIEDENTE}} 
            ivi residente in {{INDIRIZZO_RICHIEDENTE}};
            quale titolare dell' impresa funebre "{{NOME_IMPRESA}}" esercente in {{INDIRIZZO_IMPRESA}}
            
            CHIEDE alla S.V.
            l'autorizzazione al trasporto e alla {{TIPO_CERIMONIA}} della salma di
            {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
            nato in {{LUOGO_NASCITA_DEFUNTO}} il {{DATA_NASCITA_DEFUNTO}}
            deceduto in {{LUOGO_DECESSO}} 
            alle ore {{ORA_DECESSO}} del {{DATA_DECESSO}}
            
            Dichiara la salma verrà trasportata a mezzo auto {{MEZZO_TARGA}} condotta da
            {{NOME_AUTISTA}} con partenza alle ore {{ORARIO_PARTENZA}} da {{LUOGO_PARTENZA}}
            al {{NOME_PARROCCHIA}} per la funzione religiosa e successivamente al {{LUOGO_DESTINAZIONE}}
            per la {{TIPO_SEPOLTURA}} in data {{DATA_TRASPORTO}}.
            
            {{DETTAGLI_CREMAZIONE}}
            
            Ringrazio
            
            {{NOME AGENZIA FUNEBRE}}
            {{VIA  NUMERO CIVICO CAP E CITTà }} 
            {{RECAPITI TELEFONICI}}
            
            ______________________________
            Visto dell'Ufficiale dello Stato Civile
            """,
            campiCompilabili: [
                CampoDocumento(nome: "Comune Decesso", chiave: "COMUNE_DECESSO", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Nome Richiedente", chiave: "NOME_RICHIEDENTE", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Mezzo Targa", chiave: "MEZZO_TARGA", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Nome Autista", chiave: "NOME_AUTISTA", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Orario Partenza", chiave: "ORARIO_PARTENZA", tipo: .ora, obbligatorio: true),
                CampoDocumento(nome: "Nome Parrocchia", chiave: "NOME_PARROCCHIA", tipo: .testo, obbligatorio: true)
            ],
            isDefault: true,
            note: "Template standard per autorizzazione trasporto funebre"
        )
    }
    
    static var comunicazioneParrocchia: DocumentoTemplate {
        return DocumentoTemplate(
            nome: "Comunicazione Parrocchia",
            tipo: .comunicazioneParrocchia,
            contenuto: """
            SPETT. {{NOME_PARROCCHIA}}
            
            Defunto {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
            
            DI fu {{NOME_PADRE}} Di fu {{NOME_COGNOME_MADRE}
            
            nato a {{LUOGO_NASCITA_DEFUNTO}} il {{DATA_NASCITA_DEFUNTO}}
            
            deceduto in data {{DATA_DECESSO}} presso {{LUOGO_DECESSO}}
            
            Stato Civile {{SE_CONIUGATO_NOME_COGNOME_CONIUGE}}
            
            {{CREMAZIONE/TUMULAZIONE}} presso il cimitero di {{NOME_CIMITERO}}
            
            Si ringrazia per la collaborazione.
            
            {{NOME AGENZIA FUNEBRE}}
            {{VIA  NUMERO CIVICO CAP E CITTà }} 
            {{RECAPITI TELEFONICI}}
            """,
            campiCompilabili: [
                CampoDocumento(nome: "Nome Parrocchia", chiave: "NOME_PARROCCHIA", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Nome e cognome defunto", chiave: "NOME_E_COGNOME_DEFUNTO", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Luogo nascita defunto", chiave: "LUOGO_NASCITA_DEFUNTO", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Data di decesso", chiave: "DATA_DECESSO", tipo: .testo, obbligatorio: true),
                CampoDocumento(nome: "Luogo di decesso", chiave: "LUOGO_DECESSO", tipo: .testo, obbligatorio: true)
            ],
            isDefault: true,
            note: "Template standard per comunicazioni alle parrocchie"
        )
    }
    
    static var checklistFunerale: DocumentoTemplate {
        return DocumentoTemplate(
            nome: "Checklist Funerale",
            tipo: .checklistFunerale,
            contenuto: """
            CHECKLIST ORGANIZZAZIONE FUNERALE
            
            Defunto: {{NOME_DEFUNTO}} {{COGNOME_DEFUNTO}}
            Data Funerale: {{DATA_FUNERALE}}
            
            DOCUMENTI E AUTORIZZAZIONI:
            ☐ Certificato di morte
            ☐ Autorizzazione trasporto
            ☐ Autorizzazione sepoltura/cremazione
            ☐ Documento identità defunto
            ☐ Documento identità familiare
            
            PREPARAZIONE:
            ☐ Vestizione salma
            ☐ Preparazione bara
            ☐ Preparazione fiori
            ☐ Coordinamento con parrocchia
            ☐ Prenotazione mezzo trasporto
            
            TRASPORTO:
            ☐ Mezzo: {{MEZZO_TARGA}}
            ☐ Autista: {{NOME_AUTISTA}}
            ☐ Orario partenza: {{ORARIO_PARTENZA}}
            ☐ Destinazione: {{LUOGO_DESTINAZIONE}}
            
            DOPO CERIMONIA:
            ☐ Trasporto al cimitero
            ☐ Operazioni sepoltura
            ☐ Consegna documenti famiglia
            ☐ Fatturazione
            
            Note aggiuntive: {{NOTE_AGGIUNTIVE}}
            
            Operatore responsabile: {{OPERATORE_RESPONSABILE}}
            Data compilazione: {{DATA_COMPILAZIONE}}
            """,
            campiCompilabili: [
                CampoDocumento(nome: "Note Aggiuntive", chiave: "NOTE_AGGIUNTIVE", tipo: .testoLungo),
                CampoDocumento(nome: "Operatore Responsabile", chiave: "OPERATORE_RESPONSABILE", tipo: .testo, obbligatorio: true)
            ],
            isDefault: true,
            note: "Checklist completa per l'organizzazione del funerale"
        )
    }
}

// MARK: - Estensione per Editor Trasporto
extension DocumentoTemplate {
    var supportaEditorTrasporto: Bool {
        return tipo == .autorizzazioneTrasporto ||
               contenuto.contains("trasporto") ||
               contenuto.contains("mezzo auto") ||
               contenuto.contains("{{MEZZO_TARGA}}")
    }
}

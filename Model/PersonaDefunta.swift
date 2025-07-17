//
//  Modello.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 07/07/25.
//
import SwiftUI
import Foundation

// MARK: - Enumerazioni
enum SessoPersona: String, CaseIterable, Codable {
    case maschio = "M"
    case femmina = "F"
    
    var descrizione: String {
        switch self {
        case .maschio: return "Maschio"
        case .femmina: return "Femmina"
        }
    }
    
    var simbolo: String {
        switch self {
        case .maschio: return "♂"
        case .femmina: return "♀"
        }
    }
}

enum StatoCivilePersona: String, CaseIterable, Codable {
    case celibe = "Celibe"
    case nubile = "Nubile"
    case coniugato = "Coniugato/a"
    case vedovo = "Vedovo/a"
    case divorziato = "Divorziato/a"
    case separato = "Separato/a"
    case unione_civile = "Unione Civile"
    
    var richiedeConiuge: Bool {
        switch self {
        case .coniugato, .vedovo, .separato, .unione_civile:
            return true
        default:
            return false
        }
    }
}

enum LuogoMorte: String, CaseIterable, Codable {
    case abitazione = "Abitazione"
    case ospedale = "Ospedale"
    case rsa = "RSA/Casa di Cura"
    case strada = "Via Pubblica"
    case altro = "Altro"
    
    var richiedeDettagli: Bool {
        switch self {
        case .ospedale, .rsa, .altro:
            return true
        default:
            return false
        }
    }
}

enum TipologiaSepoltura: String, CaseIterable, Codable {
    case tumulazione = "Tumulazione"
    case inumazione = "Inumazione"
    case cremazione = "Cremazione"
    
    var descrizione: String {
        switch self {
        case .tumulazione: return "Deposizione in loculo/tomba di famiglia"
        case .inumazione: return "Sepoltura in terra"
        case .cremazione: return "Cremazione del corpo"
        }
    }
    
    var icona: String {
        switch self {
        case .tumulazione: return "building.columns"
        case .inumazione: return "leaf"
        case .cremazione: return "flame"
        }
    }
}

// MARK: - Strutture Dati
struct DocumentoIdentita: Codable, Hashable {
    var tipo: TipoDocumentoIdentita
    var numero: String
    var dataRilascio: Date
    var dataScadenza: Date?
    var enteRilascio: String
    
    enum TipoDocumentoIdentita: String, CaseIterable, Codable {
        case cartaIdentita = "Carta d'Identità"
        case cartaIdentitaElettronica = "Carta d'Identità Elettronica"
        case passaporto = "Passaporto"
        case patente = "Patente di Guida"
        
        var codice: String {
            switch self {
            case .cartaIdentita: return "CI"
            case .cartaIdentitaElettronica: return "CIE"
            case .passaporto: return "PP"
            case .patente: return "PAT"
            }
        }
    }
    
    init() {
        self.tipo = .cartaIdentita
        self.numero = ""
        self.dataRilascio = Date()
        self.dataScadenza = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        self.enteRilascio = ""
    }
}

// MARK: - FamiliareResponsabile MIGLIORATO
struct FamiliareResponsabile: Codable, Hashable {
    var nome: String
    var cognome: String
    var codiceFiscale: String
    var dataNascita: Date
    var luogoNascita: String
    var sesso: SessoPersona
    var indirizzo: String
    var citta: String
    var cap: String
    var telefono: String
    var email: String?
    var parentela: GradoParentela
    var documentoRiconoscimento: DocumentoIdentita
    
    // Nuovi campi aggiunti
    var cellulare: String?
    var note: String?
    
    var nomeCompleto: String { "\(nome.uppercased()) \(cognome.uppercased())" }
    
    var indirizzoCompleto: String {
        var componenti: [String] = []
        
        if !indirizzo.isEmpty {
            componenti.append(indirizzo)
        }
        
        if !citta.isEmpty {
            componenti.append(citta)
        }
        
        if !cap.isEmpty && cap != "00000" {
            componenti.append(cap)
        }
        
        return componenti.joined(separator: ", ")
    }
    
    var eta: Int {
        Calendar.current.dateComponents([.year], from: dataNascita, to: Date()).year ?? 0
    }
    
    var dataNascitaFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataNascita)
    }
    
    enum GradoParentela: String, CaseIterable, Codable {
        case coniuge = "Coniuge"
        case figlio = "Figlio/a"
        case genitore = "Genitore"
        case fratello = "Fratello/Sorella"
        case nipote = "Nipote"
        case zio = "Zio/Zia"
        case cugino = "Cugino/a"
        case nuora = "Nuora/Genero"
        case cognato = "Cognato/a"
        case altro = "Altro parente"
        case amico = "Amico/Conoscente"
        
        // Nuovi tipi di parentela
        case convivente = "Convivente"
        case figlioAdottivo = "Figlio/a Adottivo/a"
        case genitoreAdottivo = "Genitore Adottivo"
        case fratellastro = "Fratellastro/Sorellastra"
        case nonno = "Nonno/Nonna"
        case pronipote = "Pronipote"
        case suocero = "Suocero/Suocera"
        case genero = "Genero/Nuora"
        case tutore = "Tutore/Curatore"
        case rappresentanteLegale = "Rappresentante Legale"
        
        var requiresDetails: Bool {
            switch self {
            case .altro, .amico, .tutore, .rappresentanteLegale:
                return true
            default:
                return false
            }
        }
        
        var icon: String {
            switch self {
            case .coniuge, .convivente: return "heart.fill"
            case .figlio, .figlioAdottivo: return "figure.child.circle"
            case .genitore, .genitoreAdottivo: return "figure.2.and.child.holdinghands"
            case .fratello, .fratellastro: return "figure.2.arms.open"
            case .nonno: return "figure.2.and.child.holdinghands"
            case .nipote, .pronipote: return "figure.child.circle"
            case .zio, .cugino: return "person.2.fill"
            case .suocero, .genero, .nuora, .cognato: return "person.3.fill"
            case .altro, .amico: return "person.crop.circle"
            case .tutore, .rappresentanteLegale: return "person.badge.key.fill"
            }
        }
    }
    
    init() {
        self.nome = ""
        self.cognome = ""
        self.codiceFiscale = ""
        self.dataNascita = Date()
        self.luogoNascita = ""
        self.sesso = .maschio
        self.indirizzo = ""
        self.citta = ""
        self.cap = ""
        self.telefono = ""
        self.email = nil
        self.parentela = .figlio
        self.documentoRiconoscimento = DocumentoIdentita()
        self.cellulare = nil
        self.note = nil
    }
    
    // Validazione dati
    func validate() -> [String] {
        var errors: [String] = []
        
        if nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il nome del familiare è obbligatorio")
        }
        
        if cognome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il cognome del familiare è obbligatorio")
        }
        
        if telefono.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il numero di telefono è obbligatorio")
        }
        
        if luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il luogo di nascita è obbligatorio")
        }
        
        if indirizzo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("L'indirizzo di residenza è obbligatorio")
        }
        
        if citta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("La città di residenza è obbligatoria")
        }
        
        if documentoRiconoscimento.numero.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Il numero del documento di riconoscimento è obbligatorio")
        }
        
        return errors
    }
    
    // Calcolo automatico codice fiscale
    mutating func calculateCodiceFiscale() {
        if !nome.isEmpty && !cognome.isEmpty && !luogoNascita.isEmpty {
            self.codiceFiscale = CalcolatoreCodiceFiscaleItaliano.calcola(
                nome: nome,
                cognome: cognome,
                dataNascita: dataNascita,
                luogoNascita: luogoNascita,
                sesso: sesso
            )
        }
    }
}

// MARK: - Modello Principale Defunto
struct PersonaDefunta: Identifiable, Codable, Hashable {
    let id = UUID()
    var numeroCartella: String
    
    // Dati anagrafici principali
    var nome: String
    var cognome: String
    var sesso: SessoPersona
    var dataNascita: Date
    var luogoNascita: String
    var codiceFiscale: String
    
    // Residenza
    var indirizzoResidenza: String
    var cittaResidenza: String
    var capResidenza: String
    
    // Stato civile e famiglia
    var statoCivile: StatoCivilePersona
    var nomeConiuge: String?
    var paternita: String
    var maternita: String
    
    // Dati decesso
    var dataDecesso: Date
    var oraDecesso: String
    var luogoDecesso: LuogoMorte
    var nomeOspedale: String?
    
    // Documento di riconoscimento
    var documentoRiconoscimento: DocumentoIdentita
    
    // Sepoltura
    var tipoSepoltura: TipologiaSepoltura
    var luogoSepoltura: String
    var dettagliSepoltura: String?
    
    // Familiare per concessione loculo
    var familiareRichiedente: FamiliareResponsabile
    
    // Metadata
    var dataCreazione: Date
    var dataUltimaModifica: Date
    var operatoreCreazione: String
    
    init(numeroCartella: String = "", nome: String = "", cognome: String = "", sesso: SessoPersona = .maschio, dataNascita: Date = Date(), luogoNascita: String = "", indirizzoResidenza: String = "", cittaResidenza: String = "", capResidenza: String = "", statoCivile: StatoCivilePersona = .celibe, paternita: String = "", maternita: String = "", dataDecesso: Date = Date(), oraDecesso: String = "", luogoDecesso: LuogoMorte = .abitazione, documentoRiconoscimento: DocumentoIdentita = DocumentoIdentita(), tipoSepoltura: TipologiaSepoltura = .tumulazione, luogoSepoltura: String = "", familiareRichiedente: FamiliareResponsabile = FamiliareResponsabile(), operatoreCorrente: String = "Operatore") {
        
        self.numeroCartella = numeroCartella
        self.nome = nome.uppercased()
        self.cognome = cognome.uppercased()
        self.sesso = sesso
        self.dataNascita = dataNascita
        self.luogoNascita = luogoNascita.uppercased()
        self.indirizzoResidenza = indirizzoResidenza
        self.cittaResidenza = cittaResidenza.isEmpty ? luogoNascita.uppercased() : cittaResidenza.uppercased()
        self.capResidenza = capResidenza.isEmpty ? "00000" : capResidenza
        self.statoCivile = statoCivile
        self.paternita = paternita.uppercased()
        self.maternita = maternita.uppercased()
        self.dataDecesso = dataDecesso
        self.oraDecesso = oraDecesso
        self.luogoDecesso = luogoDecesso
        self.documentoRiconoscimento = documentoRiconoscimento
        self.tipoSepoltura = tipoSepoltura
        self.luogoSepoltura = luogoSepoltura.uppercased()
        self.familiareRichiedente = familiareRichiedente
        self.operatoreCreazione = operatoreCorrente
        self.dataCreazione = Date()
        self.dataUltimaModifica = Date()
        
        // Calcolo automatico codice fiscale se i dati sono completi
        if !nome.isEmpty && !cognome.isEmpty && !luogoNascita.isEmpty {
            self.codiceFiscale = CalcolatoreCodiceFiscaleItaliano.calcola(
                nome: nome,
                cognome: cognome,
                dataNascita: dataNascita,
                luogoNascita: luogoNascita,
                sesso: sesso
            )
        } else {
            self.codiceFiscale = ""
        }
        
        if statoCivile.richiedeConiuge && nomeConiuge == nil {
            self.nomeConiuge = ""
        }
    }
    
    // Proprietà computate
    var nomeCompleto: String { "\(nome) \(cognome)" }
    var eta: Int { Calendar.current.dateComponents([.year], from: dataNascita, to: dataDecesso).year ?? 0 }
    var nomeCartella: String { "\(numeroCartella) - \(nomeCompleto)" }
    
    var indirizzoCompleto: String {
        var componenti: [String] = []
        
        if !indirizzoResidenza.isEmpty {
            componenti.append(indirizzoResidenza)
        }
        
        if !cittaResidenza.isEmpty {
            componenti.append(cittaResidenza)
        }
        
        if !capResidenza.isEmpty && capResidenza != "00000" {
            componenti.append(capResidenza)
        }
        
        return componenti.isEmpty ? luogoNascita : componenti.joined(separator: ", ")
    }
    
    // Conformità Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PersonaDefunta, rhs: PersonaDefunta) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Extension per formattazione
extension PersonaDefunta {
    var dataNascitaFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataNascita)
    }
    
    var dataDecesoFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataDecesso)
    }
    
    var dataCreazioneFormattata: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCreazione)
    }
}

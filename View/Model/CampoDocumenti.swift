//
//  CampoDocumenti.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import Foundation

// MARK: - Tipo Campo Documento
enum TipoCampoDocumento: String, CaseIterable, Codable {
    case testo = "Testo"
    case numero = "Numero"
    case data = "Data"
    case ora = "Ora"
    case email = "Email"
    case telefono = "Telefono"
    case testoLungo = "Testo Lungo"
    
    var icona: String {
        switch self {
        case .testo: return "textformat"
        case .numero: return "number"
        case .data: return "calendar"
        case .ora: return "clock"
        case .email: return "envelope"
        case .telefono: return "phone"
        case .testoLungo: return "text.alignleft"
        }
    }
}

// MARK: - Campo Documento
struct CampoDocumento: Identifiable, Codable, Hashable {
    let id = UUID()
    var nome: String
    var chiave: String
    var tipo: TipoCampoDocumento
    var obbligatorio: Bool
    var valorePredefinito: String
    var descrizione: String
    
    init(nome: String, chiave: String, tipo: TipoCampoDocumento, obbligatorio: Bool = false, valorePredefinito: String = "", descrizione: String = "") {
        self.nome = nome
        self.chiave = chiave.uppercased()
        self.tipo = tipo
        self.obbligatorio = obbligatorio
        self.valorePredefinito = valorePredefinito
        self.descrizione = descrizione
    }
}

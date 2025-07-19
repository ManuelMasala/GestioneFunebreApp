//
//  DocumentiManager.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import Foundation
import SwiftUI

class DocumentiManager: ObservableObject {
    @Published var templates: [DocumentoTemplate] = []
    @Published var documentiCompilati: [DocumentoCompilato] = []
    
    init() {
        caricaTemplateDefault()
    }
    
    // MARK: - Caricamento Template Default
    private func caricaTemplateDefault() {
        templates = [
            .autorizzazioneTrasporto,
            .comunicazioneParrocchia,
            .checklistFunerale
        ]
    }
    
    // MARK: - Gestione Template
    func aggiungiTemplate(_ template: DocumentoTemplate) {
        templates.append(template)
        salvaDati()
    }
    
    func rimuoviTemplate(_ template: DocumentoTemplate) {
        templates.removeAll { $0.id == template.id }
        salvaDati()
    }
    
    func aggiornaTemplate(_ template: DocumentoTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            salvaDati()
        }
    }
    
    // MARK: - Gestione Documenti Compilati
    func creaDocumentoCompilato(template: DocumentoTemplate, defunto: PersonaDefunta) -> DocumentoCompilato {
        var documento = DocumentoCompilato(template: template, defunto: defunto)
        documento.compilaConDefunto()
        return documento
    }
    
    func salvaDocumentoCompilato(_ documento: DocumentoCompilato) {
        if let index = documentiCompilati.firstIndex(where: { $0.id == documento.id }) {
            documentiCompilati[index] = documento
        } else {
            documentiCompilati.append(documento)
        }
        salvaDati()
    }
    
    func rimuoviDocumentoCompilato(_ documento: DocumentoCompilato) {
        documentiCompilati.removeAll { $0.id == documento.id }
        salvaDati()
    }
    
    // MARK: - Import/Export
    func importaTemplate(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let template = try JSONDecoder().decode(DocumentoTemplate.self, from: data)
        aggiungiTemplate(template)
    }
    
    func esportaTemplate(_ template: DocumentoTemplate) throws -> Data {
        return try JSONEncoder().encode(template)
    }
    
    // MARK: - Persistenza
    private func salvaDati() {
        print("Salvando dati documenti...")
        // Implementa salvataggio su UserDefaults o Core Data
    }
}

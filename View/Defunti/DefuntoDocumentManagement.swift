//
//  DefuntoDocumentManagement.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 22/07/25.
//

import SwiftUI
import Foundation

// MARK: - ⭐ ESTENSIONI DEFUNTO PULITE

extension PersonaDefunta {
    // Path della cartella documenti per questo defunto
    var cartellaDocumentiPath: String {
        let nomeCartella = "\(numeroCartella)_\(cognome)_\(nome)"
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        return nomeCartella
    }
    
    // Nome visualizzabile della cartella
    var nomeCartellaDocumenti: String {
        return "\(numeroCartella) - \(nomeCompleto)"
    }
}

// MARK: - ⭐ UTILITY PER CARTELLE DEFUNTO

class DefuntoFolderUtils {
    
    private static let fileManager = FileManager.default
    
    // URL base per le cartelle defunto
    private static var baseDocumentsURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("GestioneFunebre/DocumentiDefunti")
    }
    
    // Crea directory base se necessario
    static func createBaseDirectoryIfNeeded() {
        do {
            try fileManager.createDirectory(at: baseDocumentsURL, withIntermediateDirectories: true)
            print("✅ Directory base creata: \(baseDocumentsURL.path)")
        } catch {
            print("❌ Errore creazione directory base: \(error)")
        }
    }
    
    // Ottieni URL directory per defunto
    static func getDefuntoDirectoryURL(_ defunto: PersonaDefunta) -> URL {
        return baseDocumentsURL.appendingPathComponent(defunto.cartellaDocumentiPath)
    }
    
    // Crea cartella per defunto
    static func createDefuntoDirectoryIfNeeded(_ defunto: PersonaDefunta) {
        let dirURL = getDefuntoDirectoryURL(defunto)
        
        do {
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true)
            print("✅ Creata cartella per defunto: \(defunto.nomeCartellaDocumenti)")
        } catch {
            print("❌ Errore creazione cartella defunto: \(error)")
        }
    }
    
    // Salva documento nella cartella defunto
    static func saveDocumentToDefuntoFolder(_ documento: DocumentoCompilato) {
        createBaseDirectoryIfNeeded()
        createDefuntoDirectoryIfNeeded(documento.defunto)
        
        let defuntoDir = getDefuntoDirectoryURL(documento.defunto)
        let filename = generateDocumentFilename(documento)
        let fileURL = defuntoDir.appendingPathComponent(filename)
        
        do {
            // Salva il contenuto del documento
            let content = generateDocumentContent(documento)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Salva anche il JSON per backup
            let jsonURL = defuntoDir.appendingPathComponent("\(filename).json")
            let jsonData = try JSONEncoder().encode(documento)
            try jsonData.write(to: jsonURL)
            
            print("💾 Documento salvato: \(fileURL.path)")
        } catch {
            print("❌ Errore salvataggio documento: \(error)")
        }
    }
    
    // Rimuovi documento dalla cartella defunto
    static func removeDocumentFromDefuntoFolder(_ documento: DocumentoCompilato) {
        let defuntoDir = getDefuntoDirectoryURL(documento.defunto)
        let filename = generateDocumentFilename(documento)
        let fileURL = defuntoDir.appendingPathComponent(filename)
        let jsonURL = defuntoDir.appendingPathComponent("\(filename).json")
        
        do {
            try fileManager.removeItem(at: fileURL)
            try fileManager.removeItem(at: jsonURL)
            print("🗑️ File documento rimosso: \(fileURL.path)")
        } catch {
            print("❌ Errore rimozione file: \(error)")
        }
    }
    
    // Genera nome file per documento
    private static func generateDocumentFilename(_ documento: DocumentoCompilato) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateStr = dateFormatter.string(from: documento.dataCreazione)
        
        let templateName = documento.template.nome
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
        
        return "\(dateStr)_\(templateName).txt"
    }
    
    // Genera contenuto file per documento
    private static func generateDocumentContent(_ documento: DocumentoCompilato) -> String {
        var content = ""
        content += "=== DOCUMENTO DEFUNTO ===\n\n"
        content += "Template: \(documento.template.nome)\n"
        content += "Defunto: \(documento.defunto.nomeCompleto)\n"
        content += "Cartella: \(documento.defunto.numeroCartella)\n"
        content += "Data Creazione: \(documento.dataCreazioneFormattata)\n"
        content += "Operatore: \(documento.operatoreCreazione)\n"
        
        if documento.template.isAIGenerated {
            content += "🧠 Generato con AI\n"
            if let confidence = documento.template.aiConfidence {
                content += "Confidence: \(Int(confidence * 100))%\n"
            }
        }
        
        content += "\n" + String(repeating: "=", count: 50) + "\n\n"
        content += documento.contenutoFinale.isEmpty ? documento.template.contenuto : documento.contenutoFinale
        
        if !documento.note.isEmpty {
            content += "\n\n=== NOTE ===\n"
            content += documento.note
        }
        
        return content
    }
    
    // Ottieni statistiche per defunto
    static func getDefuntoStatistics(_ defunto: PersonaDefunta, documenti: [DocumentoCompilato]) -> (total: Int, completed: Int, aiGenerated: Int) {
        let documentiDefunto = documenti.filter { $0.defunto.id == defunto.id }
        let completed = documentiDefunto.filter(\.isCompletato).count
        let aiGenerated = documentiDefunto.filter { $0.template.isAIGenerated }.count
        
        return (documentiDefunto.count, completed, aiGenerated)
    }
    
    // Verifica se cartella defunto esiste
    static func defuntoFolderExists(_ defunto: PersonaDefunta) -> Bool {
        let dirURL = getDefuntoDirectoryURL(defunto)
        return fileManager.fileExists(atPath: dirURL.path)
    }
    
    // Apri cartella defunto nel Finder
    static func openDefuntoFolderInFinder(_ defunto: PersonaDefunta) {
        createDefuntoDirectoryIfNeeded(defunto)
        let dirURL = getDefuntoDirectoryURL(defunto)
        NSWorkspace.shared.open(dirURL)
    }
}

// MARK: - ⭐ MANAGER SEMPLIFICATO

class SimpleDefuntoDocumentManager: ObservableObject {
    @Published var documentiPerDefunto: [UUID: [DocumentoCompilato]] = [:]
    
    init() {
        DefuntoFolderUtils.createBaseDirectoryIfNeeded()
    }
    
    // Aggiungi documento alla cartella defunto
    func addDocumentToDefunto(_ documento: DocumentoCompilato) {
        // Salva su disco (sincrono)
        DefuntoFolderUtils.saveDocumentToDefuntoFolder(documento)
        
        // Aggiorna collezione in memoria
        if documentiPerDefunto[documento.defunto.id] == nil {
            documentiPerDefunto[documento.defunto.id] = []
        }
        
        documentiPerDefunto[documento.defunto.id]?.removeAll { $0.id == documento.id }
        documentiPerDefunto[documento.defunto.id]?.append(documento)
        
        print("📁 Documento '\(documento.template.nome)' aggiunto alla cartella di \(documento.defunto.nomeCompleto)")
    }
    
    // Ottieni documenti per defunto
    func getDocumentsForDefunto(_ defunto: PersonaDefunta) -> [DocumentoCompilato] {
        return documentiPerDefunto[defunto.id] ?? []
    }
    
    // Rimuovi documento da defunto
    func removeDocumentFromDefunto(_ documento: DocumentoCompilato) {
        documentiPerDefunto[documento.defunto.id]?.removeAll { $0.id == documento.id }
        DefuntoFolderUtils.removeDocumentFromDefuntoFolder(documento)
    }
    
    // Ottieni statistiche
    func getStatisticsForDefunto(_ defunto: PersonaDefunta) -> (total: Int, completed: Int, aiGenerated: Int) {
        let documenti = getDocumentsForDefunto(defunto)
        return DefuntoFolderUtils.getDefuntoStatistics(defunto, documenti: documenti)
    }
}

// MARK: - ⭐ ESTENSIONE DOCUMENTI MANAGER

extension DocumentiManager {
    // Salva documento con cartella defunto
    func salvaDocumentoCompilatoConCartella(_ documento: DocumentoCompilato, defuntoManager: SimpleDefuntoDocumentManager? = nil) {
        // Salva normalmente
        salvaDocumentoCompilato(documento)
        
        // Salva anche nella cartella defunto
        DefuntoFolderUtils.saveDocumentToDefuntoFolder(documento)
        
        // Aggiorna manager se fornito
        defuntoManager?.addDocumentToDefunto(documento)
    }
}

// MARK: - ⭐ UI COMPONENTS SEMPLIFICATI

struct DefuntoFolderInfoView: View {
    let defunto: PersonaDefunta
    let documenti: [DocumentoCompilato]
    
    var stats: (total: Int, completed: Int, aiGenerated: Int) {
        DefuntoFolderUtils.getDefuntoStatistics(defunto, documenti: documenti)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(defunto.nomeCompleto)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("Cartella: \(defunto.numeroCartella)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("📁 \(defunto.cartellaDocumentiPath)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Statistiche
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(stats.total)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("Tot")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if stats.completed > 0 {
                    VStack(spacing: 2) {
                        Text("\(stats.completed)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("OK")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                if stats.aiGenerated > 0 {
                    VStack(spacing: 2) {
                        Text("\(stats.aiGenerated)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Text("AI")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                }
            }
            
            Button("📁") {
                DefuntoFolderUtils.openDefuntoFolderInFinder(defunto)
            }
            .help("Apri cartella nel Finder")
            .padding(8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(6)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct DefuntoDocumentsList: View {
    let defunto: PersonaDefunta
    let documenti: [DocumentoCompilato]
    let onDocumentTap: (DocumentoCompilato) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DefuntoFolderInfoView(defunto: defunto, documenti: documenti)
            
            if documenti.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                    Text("Nessun documento per questo defunto")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("I documenti generati appariranno automaticamente qui")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            } else {
                LazyVStack(spacing: 6) {
                    ForEach(documenti) { documento in
                        DefuntoDocumentRow(documento: documento, onTap: onDocumentTap)
                    }
                }
            }
        }
    }
}

struct DefuntoDocumentRow: View {
    let documento: DocumentoCompilato
    let onTap: (DocumentoCompilato) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: documento.template.tipo.icona)
                .font(.title3)
                .foregroundColor(documento.template.tipo.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(documento.template.nome)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if documento.template.isAIGenerated {
                        Text("AI")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(3)
                    }
                }
                
                Text(documento.dataCreazioneFormattata)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Circle()
                    .fill(documento.isCompletato ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(documento.isCompletato ? "Completato" : "In corso")
                    .font(.caption)
                    .foregroundColor(documento.isCompletato ? .green : .orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.1), radius: 1)
        .onTapGesture {
            onTap(documento)
        }
    }
}

// MARK: - ⭐ GESTIONE CARTELLE DEFUNTO VIEW

struct DefuntoFoldersOverview: View {
    let defunti: [PersonaDefunta]
    let documenti: [DocumentoCompilato]
    let onDocumentSelect: (DocumentoCompilato) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var defuntiConDocumenti: [(defunto: PersonaDefunta, documenti: [DocumentoCompilato])] {
        defunti.compactMap { defunto in
            let documentiDefunto = documenti.filter { $0.defunto.id == defunto.id }
            return documentiDefunto.isEmpty ? nil : (defunto, documentiDefunto)
        }
    }
    
    var totalStats: (folders: Int, documents: Int, completed: Int, ai: Int) {
        let folders = defuntiConDocumenti.count
        let totalDocs = defuntiConDocumenti.reduce(0) { $0 + $1.documenti.count }
        let completed = defuntiConDocumenti.reduce(0) { total, item in
            total + item.documenti.filter(\.isCompletato).count
        }
        let aiDocs = defuntiConDocumenti.reduce(0) { total, item in
            total + item.documenti.filter { $0.template.isAIGenerated }.count
        }
        
        return (folders, totalDocs, completed, aiDocs)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header con statistiche
                VStack(spacing: 12) {
                    Text("Cartelle Defunto")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Gestione documenti organizzati per defunto")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Statistiche generali
                    let stats = totalStats
                    HStack(spacing: 30) {
                        StatisticItem(title: "Cartelle Attive", value: "\(stats.folders)", color: .blue)
                        StatisticItem(title: "Documenti Totali", value: "\(stats.documents)", color: .green)
                        StatisticItem(title: "Completati", value: "\(stats.completed)", color: .orange)
                        if stats.ai > 0 {
                            StatisticItem(title: "AI", value: "\(stats.ai)", color: .purple)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                // Lista cartelle
                if defuntiConDocumenti.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Nessuna cartella defunto attiva")
                            .font(.headline)
                        Text("Le cartelle verranno create automaticamente quando generi documenti")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(defuntiConDocumenti, id: \.defunto.id) { item in
                                DefuntoDocumentsList(
                                    defunto: item.defunto,
                                    documenti: item.documenti,
                                    onDocumentTap: onDocumentSelect
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cartelle Defunto")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - ⭐ METODI DI INTEGRAZIONE FINALI

/*
INTEGRAZIONE FINALE - Aggiungi al tuo SezioneGenerazioneDocumentiView:

1. @StateObject private var defuntoDocumentManager = SimpleDefuntoDocumentManager()

2. Sostituisci il metodo di salvataggio nell'editor:
   onSave: { doc in
       // Usa il nuovo metodo che salva anche nella cartella defunto
       documentiManager.salvaDocumentoCompilatoConCartella(doc, defuntoManager: defuntoDocumentManager)
       documentoGenerato = nil
       isEditorOpen = false
       
       mostraAlert(
           titolo: "✅ Documento Salvato",
           messaggio: "Salvato nella cartella: \(doc.defunto.nomeCartellaDocumenti)"
       )
   }

3. Aggiungi sheet per overview cartelle:
   @State private var showingDefuntoFolders = false
   
   .sheet(isPresented: $showingDefuntoFolders) {
       DefuntoFoldersOverview(
           defunti: defuntiManager.defunti,
           documenti: documentiManager.documentiCompilati,
           onDocumentSelect: { documento in
               documentoGenerato = documento
               showingPreview = true
               showingDefuntoFolders = false
           }
       )
   }

4. Nel button "Cartelle Defunto":
   Button("📁 Cartelle Defunto") {
       showingDefuntoFolders = true
   }

FUNZIONALITÀ OTTENUTE:
✅ Cartelle automatiche per ogni defunto nel file system
✅ Salvataggio doppio (sistema + cartella defunto)
✅ Overview completa di tutte le cartelle
✅ Apertura cartelle nel Finder
✅ Statistiche per cartella e globali
✅ UI pulita senza errori di compilazione
✅ Gestione file .txt + .json per backup
✅ Path organizzati: Documents/GestioneFunebre/DocumentiDefunti/119_ROSSI_MARIO/
*/

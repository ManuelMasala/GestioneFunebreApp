//
//  SezioneGenerazioneDocumentiView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 19/07/25.
//

import SwiftUI

struct SezioneGenerazioneDocumentiView: View {
    @StateObject private var defuntiManager = ManagerGestioneDefunti()
    @StateObject private var mezziManager = MezziManager()
    @StateObject private var documentiManager = DocumentiManager()
    
    @State private var defuntoSelezionato: PersonaDefunta?
    @State private var mezzoSelezionato: Mezzo?
    @State private var templateSelezionato: DocumentoTemplate?
    
    @State private var showingDocumentoGenerato = false
    @State private var documentoGenerato: DocumentoCompilato?
    @State private var showingPreview = false
    
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header principale
            headerSection
            
            // Content principale
            ScrollView {
                VStack(spacing: 24) {
                    // Sezione selezione dati
                    selezioneSection
                    
                    // Sezione template disponibili
                    templateSection
                    
                    // Sezione azioni
                    if defuntoSelezionato != nil && templateSelezionato != nil {
                        azioniSection
                    }
                    
                    // Sezione documenti recenti
                    documentiRecentiSection
                }
                .padding()
            }
        }
        .navigationTitle("Generazione Documenti")
        .sheet(isPresented: $showingDocumentoGenerato) {
            if let documento = documentoGenerato {
                DocumentoGeneretoView(documento: documento) { documentoFinale in
                    documentiManager.salvaDocumentoCompilato(documentoFinale)
                    documentoGenerato = nil
                }
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let documento = documentoGenerato {
                DocumentoPreviewView(documento: documento)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Generazione Documenti")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Compila automaticamente documenti utilizzando i dati di defunti e mezzi")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats
                HStack(spacing: 16) {
                    StatisticCard(
                        titolo: "Defunti",
                        valore: "\(defuntiManager.defunti.count)",
                        icona: "person.2.fill",
                        colore: .purple
                    )
                    
                    StatisticCard(
                        titolo: "Mezzi",
                        valore: "\(mezziManager.mezzi.count)",
                        icona: "car.2.fill",
                        colore: .blue
                    )
                    
                    StatisticCard(
                        titolo: "Template",
                        valore: "\(documentiManager.templates.count)",
                        icona: "doc.circle.fill",
                        colore: .green
                    )
                }
            }
            
            // Barra di ricerca
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Cerca defunti, mezzi o template...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
    }
    
    // MARK: - Selezione Section
    private var selezioneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("1. Seleziona Dati")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            HStack(spacing: 20) {
                // Selezione Defunto
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        Text("Defunto")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    if let defunto = defuntoSelezionato {
                        SelectedDefuntoCard(defunto: defunto) {
                            defuntoSelezionato = nil
                        }
                    } else {
                        Menu {
                            ForEach(defuntiFiltrati) { defunto in
                                Button(action: {
                                    defuntoSelezionato = defunto
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(defunto.nomeCompleto)
                                            .fontWeight(.medium)
                                        Text("Cartella: \(defunto.numeroCartella)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if defuntiFiltrati.isEmpty {
                                Text("Nessun defunto disponibile")
                                    .foregroundColor(.secondary)
                            }
                        } label: {
                            Text("Seleziona Defunto")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Selezione Mezzo (opzionale)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "car.2.fill")
                            .foregroundColor(.blue)
                        Text("Mezzo (opzionale)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    if let mezzo = mezzoSelezionato {
                        SelectedMezzoCard(mezzo: mezzo) {
                            mezzoSelezionato = nil
                        }
                    } else {
                        Menu {
                            ForEach(mezziFiltrati) { mezzo in
                                Button(action: {
                                    mezzoSelezionato = mezzo
                                }) {
                                    VStack(alignment: .leading) {
                                        Text("\(mezzo.marca) \(mezzo.modello)")
                                            .fontWeight(.medium)
                                        Text("Targa: \(mezzo.targa)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } label: {
                            Text("Seleziona Mezzo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Template Section
    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("2. Scegli Template")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 280), spacing: 16)
            ], spacing: 16) {
                ForEach(templatesFiltrati) { template in
                    TemplateCard(
                        template: template,
                        isSelected: templateSelezionato?.id == template.id
                    ) {
                        templateSelezionato = template
                    }
                }
            }
            
            if templatesFiltrati.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Nessun template disponibile")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Controlla i filtri applicati")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Azioni Section
    private var azioniSection: some View {
        VStack(spacing: 16) {
            Text("3. Genera Documento")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            HStack(spacing: 16) {
                Button(action: generaDocumento) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Genera e Compila")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: generaEStampa) {
                    HStack {
                        Image(systemName: "printer.fill")
                        Text("Stampa Diretta")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Documenti Recenti Section
    private var documentiRecentiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Documenti Recenti")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.mint)
                
                Spacer()
                
                Text("\(documentiManager.documentiCompilati.count) documenti")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if documentiManager.documentiCompilati.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("Nessun documento generato")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(documentiManager.documentiCompilati.prefix(5)) { documento in
                            DocumentoRecenteCard(documento: documento) {
                                documentoGenerato = documento
                                showingDocumentoGenerato = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    private var defuntiFiltrati: [PersonaDefunta] {
        var risultato = defuntiManager.defunti
        
        if !searchText.isEmpty {
            risultato = risultato.filter { defunto in
                defunto.nome.localizedCaseInsensitiveContains(searchText) ||
                defunto.cognome.localizedCaseInsensitiveContains(searchText) ||
                defunto.numeroCartella.contains(searchText)
            }
        }
        
        return risultato.sorted { $0.dataCreazione > $1.dataCreazione }
    }
    
    private var mezziFiltrati: [Mezzo] {
        var risultato = mezziManager.mezzi.filter { $0.stato == .disponibile || $0.stato == .inUso }
        
        if !searchText.isEmpty {
            risultato = risultato.filter { mezzo in
                mezzo.targa.localizedCaseInsensitiveContains(searchText) ||
                mezzo.marca.localizedCaseInsensitiveContains(searchText) ||
                mezzo.modello.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return risultato
    }
    
    private var templatesFiltrati: [DocumentoTemplate] {
        var risultato = documentiManager.templates
        
        if !searchText.isEmpty {
            risultato = risultato.filter { template in
                template.nome.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return risultato
    }
    
    // MARK: - Actions
    private func generaDocumento() {
        guard let defunto = defuntoSelezionato,
              let template = templateSelezionato else { return }
        
        var documento = documentiManager.creaDocumentoCompilato(template: template, defunto: defunto)
        
        // Se è selezionato un mezzo, aggiungi i dati del mezzo
        if let mezzo = mezzoSelezionato {
            documento.aggiungiDatiMezzo(mezzo)
        }
        
        documentoGenerato = documento
        showingDocumentoGenerato = true
    }
    
    private func generaEStampa() {
        guard let defunto = defuntoSelezionato,
              let template = templateSelezionato else { return }
        
        var documento = documentiManager.creaDocumentoCompilato(template: template, defunto: defunto)
        
        if let mezzo = mezzoSelezionato {
            documento.aggiungiDatiMezzo(mezzo)
        }
        
        // Stampa direttamente
        stampaDocumentoDiretto(documento)
    }
    
    private func stampaDocumentoDiretto(_ documento: DocumentoCompilato) {
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        
        let printView = creaPrintView(per: documento)
        let printOperation = NSPrintOperation(view: printView)
        printOperation.printInfo = printInfo
        printOperation.showsPrintPanel = true
        printOperation.run()
    }
    
    private func creaPrintView(per documento: DocumentoCompilato) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 595, height: 842))
        
        let textView = NSTextView(frame: view.bounds.insetBy(dx: 20, dy: 20))
        textView.string = documento.contenutoFinale
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.isEditable = false
        textView.backgroundColor = NSColor.white
        
        view.addSubview(textView)
        return view
    }
}

// MARK: - Supporting Views

struct StatisticCard: View {
    let titolo: String
    let valore: String
    let icona: String
    let colore: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icona)
                .font(.system(size: 20))
                .foregroundColor(colore)
            
            Text(valore)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(titolo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

struct SelectedDefuntoCard: View {
    let defunto: PersonaDefunta
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(defunto.nomeCompleto)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("N° \(defunto.numeroCartella)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(defunto.dataDecesoFormattata)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SelectedMezzoCard: View {
    let mezzo: Mezzo
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(mezzo.marca) \(mezzo.modello)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Targa: \(mezzo.targa)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Stato: \(mezzo.stato.rawValue)")
                    .font(.caption)
                    .foregroundColor(mezzo.stato.color)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct TemplateCard: View {
    let template: DocumentoTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: template.tipo.icona)
                        .font(.title2)
                        .foregroundColor(template.tipo.color)
                    
                    Spacer()
                    
                    if template.isDefault {
                        Text("Default")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.nome)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    Text(template.tipo.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(template.campiCompilabili.count) campi")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 120)
            .background(isSelected ? template.tipo.color.opacity(0.1) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? template.tipo.color : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DocumentoRecenteCard: View {
    let documento: DocumentoCompilato
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: documento.template.tipo.icona)
                        .foregroundColor(documento.template.tipo.color)
                    
                    Spacer()
                    
                    Circle()
                        .fill(documento.isCompletato ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                }
                
                Text(documento.template.nome)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(documento.defunto.nomeCompleto)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(documento.dataCreazione.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .frame(width: 120, height: 100)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions per DocumentoCompilato
extension DocumentoCompilato {
    mutating func aggiungiDatiMezzo(_ mezzo: Mezzo) {
        let campiMezzo = [
            "MEZZO_TARGA": mezzo.targa,
            "MEZZO_MARCA": mezzo.marca,
            "MEZZO_MODELLO": mezzo.modello,
            "MEZZO_KM": mezzo.km,
            "AUTISTA": "Marco Lecca",
            "ORARIO_PARTENZA": "ore da definire"
        ]
        
        for (chiave, valore) in campiMezzo {
            aggiornaCampo(chiave: chiave, valore: valore)
        }
    }
}

#Preview {
    SezioneGenerazioneDocumentiView()
}

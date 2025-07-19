//
//  TemplateManagerView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI

struct TemplateManagerView: View {
    @StateObject private var documentiManager = DocumentiManager()
    @State private var showingNuovoTemplate = false
    @State private var templateSelezionato: DocumentoTemplate?
    @State private var searchText = ""
    @State private var filtroTipo: TipoDocumento?
    @State private var showingDeleteAlert = false
    @State private var templateDaEliminare: DocumentoTemplate?
    
    var body: some View {
        NavigationView {
            VStack {
                // Header e ricerca
                headerSection
                
                // Lista template
                templateListSection
            }
            .navigationTitle("Gestione Template")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Importa") {
                        importaTemplate()
                    }
                    
                    Button("Nuovo Template") {
                        showingNuovoTemplate = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingNuovoTemplate) {
            NuovoTemplateView { template in
                documentiManager.aggiungiTemplate(template)
            }
        }
        .sheet(item: $templateSelezionato) { template in
            TemplateDetailView(template: template) { templateAggiornato in
                documentiManager.aggiornaTemplate(templateAggiornato)
            }
        }
        .alert("Elimina Template", isPresented: $showingDeleteAlert) {
            Button("Elimina", role: .destructive) {
                if let template = templateDaEliminare {
                    documentiManager.rimuoviTemplate(template)
                    templateDaEliminare = nil
                }
            }
            Button("Annulla", role: .cancel) {
                templateDaEliminare = nil
            }
        } message: {
            if let template = templateDaEliminare {
                Text("Sei sicuro di voler eliminare il template '\(template.nome)'?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gestione Template")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Gestisci i template per la generazione documenti")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Statistiche rapide
                HStack(spacing: 16) {
                    QuickStatsCard(
                        titolo: "Totale",
                        valore: "\(documentiManager.templates.count)",
                        icona: "doc.text.fill",
                        colore: .blue
                    )
                    
                    QuickStatsCard(
                        titolo: "Default",
                        valore: "\(documentiManager.templates.filter { $0.isDefault }.count)",
                        icona: "star.fill",
                        colore: .yellow
                    )
                    
                    QuickStatsCard(
                        titolo: "Personalizzati",
                        valore: "\(documentiManager.templates.filter { !$0.isDefault }.count)",
                        icona: "pencil.circle.fill",
                        colore: .green
                    )
                }
            }
            
            // Barra di ricerca e filtri
            HStack {
                // Ricerca
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Cerca template...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Filtro tipo
                Menu {
                    Button("Tutti i tipi") {
                        filtroTipo = nil
                    }
                    Divider()
                    ForEach(TipoDocumento.allCases) { tipo in
                        Button(action: {
                            filtroTipo = tipo
                        }) {
                            HStack {
                                Image(systemName: tipo.icona)
                                Text(tipo.rawValue)
                                if filtroTipo == tipo {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let tipo = filtroTipo {
                            Image(systemName: tipo.icona)
                                .foregroundColor(tipo.color)
                        }
                        Text(filtroTipo?.rawValue ?? "Tipo")
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Reset filtri
                if filtroTipo != nil || !searchText.isEmpty {
                    Button("Reset") {
                        filtroTipo = nil
                        searchText = ""
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Template List Section
    private var templateListSection: some View {
        Group {
            if templatesFiltrati.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(templatesFiltrati) { template in
                            TemplateRowView(template: template,
                                          onSelect: { templateSelezionato = template },
                                          onDelete: {
                                              templateDaEliminare = template
                                              showingDeleteAlert = true
                                          },
                                          onExport: { esportaTemplate(template) })
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "doc.text" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Nessun template" : "Nessun risultato")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(searchText.isEmpty ?
                     "Inizia creando il primo template personalizzato" :
                     "Prova a modificare i criteri di ricerca")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                Button("Crea Template") {
                    showingNuovoTemplate = true
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var templatesFiltrati: [DocumentoTemplate] {
        var risultato = documentiManager.templates
        
        if let filtro = filtroTipo {
            risultato = risultato.filter { $0.tipo == filtro }
        }
        
        if !searchText.isEmpty {
            risultato = risultato.filter {
                $0.nome.localizedCaseInsensitiveContains(searchText) ||
                $0.tipo.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return risultato.sorted { template1, template2 in
            if template1.isDefault != template2.isDefault {
                return template1.isDefault
            }
            return template1.nome < template2.nome
        }
    }
    
    // MARK: - Actions
    private func importaTemplate() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                try documentiManager.importaTemplate(from: url)
            } catch {
                print("Errore importazione: \(error)")
            }
        }
    }
    
    private func esportaTemplate(_ template: DocumentoTemplate) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "\(template.nome).json"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                let data = try documentiManager.esportaTemplate(template)
                try data.write(to: url)
            } catch {
                print("Errore esportazione: \(error)")
            }
        }
    }
}

// MARK: - Quick Stats Card
struct QuickStatsCard: View {
    let titolo: String
    let valore: String
    let icona: String
    let colore: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icona)
                .font(.title3)
                .foregroundColor(colore)
            
            Text(valore)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(titolo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2)
    }
}

// MARK: - Template Row View
struct TemplateRowView: View {
    let template: DocumentoTemplate
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icona e indicatori
            VStack(spacing: 8) {
                Image(systemName: template.tipo.icona)
                    .font(.title2)
                    .foregroundColor(template.tipo.color)
                    .frame(width: 40, height: 40)
                    .background(template.tipo.color.opacity(0.1))
                    .cornerRadius(8)
                
                if template.isDefault {
                    Text("Default")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            // Informazioni principali
            VStack(alignment: .leading, spacing: 6) {
                Text(template.nome)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(template.tipo.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(template.campiCompilabili.count) campi",
                          systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(template.dataCreazione.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Note se presenti
            if !template.note.isEmpty {
                VStack {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Note")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            // Azioni
            HStack(spacing: 8) {
                Button(action: onSelect) {
                    Image(systemName: "eye")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onExport) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.green)
                        .frame(width: 28, height: 28)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                if !template.isDefault {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 28, height: 28)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Nuovo Template View
struct NuovoTemplateView: View {
    let onSave: (DocumentoTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var tipo: TipoDocumento = .comunicazioneParrocchia
    @State private var contenuto = ""
    @State private var note = ""
    @State private var campi: [CampoDocumento] = []
    @State private var showingAggiungiCampo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Informazioni base
                    informazioniBaseSection
                    
                    // Contenuto template
                    contenutoSection
                    
                    // Campi configurabili
                    campiSection
                    
                    // Note
                    noteSection
                }
                .padding()
            }
            .navigationTitle("Nuovo Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        salvaTemplate()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 800, height: 700)
        .sheet(isPresented: $showingAggiungiCampo) {
            AggiungiCampoView { campo in
                campi.append(campo)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("Crea Nuovo Template")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Crea un template personalizzato per generare documenti")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var informazioniBaseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informazioni Base")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome Template")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Nome del template", text: $nome)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo Documento")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Tipo", selection: $tipo) {
                        ForEach(TipoDocumento.allCases) { tipoDoc in
                            HStack {
                                Image(systemName: tipoDoc.icona)
                                Text(tipoDoc.rawValue)
                            }
                            .tag(tipoDoc)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var contenutoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Contenuto Template")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Inserisci Placeholder") {
                    // Mostra menu con placeholder comuni
                    insertPlaceholderMenu()
                }
                .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Usa {{NOME_PLACEHOLDER}} per inserire campi dinamici")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $contenuto)
                    .frame(minHeight: 200)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var campiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Campi Configurabili")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("(\(campi.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Aggiungi Campo") {
                    showingAggiungiCampo = true
                }
                .font(.caption)
            }
            
            if campi.isEmpty {
                Text("Nessun campo configurato")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(campi.indices, id: \.self) { index in
                        CampoRow(campo: campi[index]) {
                            campi.remove(at: index)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Note")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $note)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var isFormValid: Bool {
        !nome.isEmpty && !contenuto.isEmpty
    }
    
    private func insertPlaceholderMenu() {
        // Implementazione menu placeholder
        print("Mostra menu placeholder")
    }
    
    private func salvaTemplate() {
        let template = DocumentoTemplate(
            nome: nome,
            tipo: tipo,
            contenuto: contenuto,
            campiCompilabili: campi,
            isDefault: false,
            note: note
        )
        
        onSave(template)
        dismiss()
    }
}

// MARK: - Campo Row
struct CampoRow: View {
    let campo: CampoDocumento
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: campo.tipo.icona)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(campo.nome)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("{{" + campo.chiave + "}}")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
            
            Spacer()
            
            if campo.obbligatorio {
                Text("Obbligatorio")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(4)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - Aggiungi Campo View
struct AggiungiCampoView: View {
    let onSave: (CampoDocumento) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var chiave = ""
    @State private var tipo: TipoCampoDocumento = .testo
    @State private var obbligatorio = false
    @State private var valorePredefinito = ""
    @State private var descrizione = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informazioni Base") {
                    TextField("Nome campo", text: $nome)
                    TextField("Chiave (MAIUSCOLO_UNDERSCORE)", text: $chiave)
                        .onChange(of: nome) { _, newValue in
                            if chiave.isEmpty {
                                chiave = newValue.uppercased()
                                    .replacingOccurrences(of: " ", with: "_")
                                    .filter { $0.isLetter || $0 == "_" }
                            }
                        }
                    
                    Picker("Tipo", selection: $tipo) {
                        ForEach(TipoCampoDocumento.allCases, id: \.self) { tipoCampo in
                            HStack {
                                Image(systemName: tipoCampo.icona)
                                Text(tipoCampo.rawValue)
                            }
                            .tag(tipoCampo)
                        }
                    }
                    
                    Toggle("Campo obbligatorio", isOn: $obbligatorio)
                }
                
                Section("Opzionale") {
                    TextField("Valore predefinito", text: $valorePredefinito)
                    TextField("Descrizione", text: $descrizione)
                }
            }
            .navigationTitle("Nuovo Campo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        let campo = CampoDocumento(
                            nome: nome,
                            chiave: chiave,
                            tipo: tipo,
                            obbligatorio: obbligatorio,
                            valorePredefinito: valorePredefinito,
                            descrizione: descrizione
                        )
                        onSave(campo)
                        dismiss()
                    }
                    .disabled(nome.isEmpty || chiave.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - Template Detail View
struct TemplateDetailView: View {
    let template: DocumentoTemplate
    let onUpdate: (DocumentoTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: template.tipo.icona)
                            .font(.system(size: 40))
                            .foregroundColor(template.tipo.color)
                        
                        Text(template.nome)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(template.tipo.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(template.tipo.color.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Informazioni
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informazioni")
                            .font(.headline)
                        
                        InfoDetailRow(label: "Campi configurati", value: "\(template.campiCompilabili.count)")
                        InfoDetailRow(label: "Campi obbligatori", value: "\(template.campiObbligatori.count)")
                        InfoDetailRow(label: "Creato il", value: template.dataCreazione.formatted(date: .abbreviated, time: .shortened))
                        InfoDetailRow(label: "Modificato il", value: template.dataUltimaModifica.formatted(date: .abbreviated, time: .shortened))
                        InfoDetailRow(label: "Tipo", value: template.isDefault ? "Template di sistema" : "Template personalizzato")
                    }
                    
                    // Contenuto
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contenuto Template")
                            .font(.headline)
                        
                        Text(template.contenuto)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                    }
                    
                    // Campi
                    if !template.campiCompilabili.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Campi Configurabili")
                                .font(.headline)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(template.campiCompilabili) { campo in
                                    HStack {
                                        Image(systemName: campo.tipo.icona)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading) {
                                            Text(campo.nome)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text("{{\(campo.chiave)}}")
                                                .font(.caption)
                                                .fontDesign(.monospaced)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if campo.obbligatorio {
                                            Text("Obbligatorio")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.red.opacity(0.2))
                                                .foregroundColor(.red)
                                                .cornerRadius(4)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Note
                    if !template.note.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Note")
                                .font(.headline)
                            
                            Text(template.note)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dettaglio Template")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 700, height: 600)
    }
}

struct InfoDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TemplateManagerView()
}

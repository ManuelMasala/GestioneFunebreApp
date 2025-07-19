//
//  SezioneDefuntoTemplateView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//
import SwiftUI

struct SelezionaDefuntoTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    let defunti: [PersonaDefunta]  // ✅ CAMBIATO da Defunto a PersonaDefunta
    let templates: [DocumentoTemplate]
    let onSelection: (PersonaDefunta, DocumentoTemplate) -> Void  // ✅ CAMBIATO
    
    @State private var defuntoSelezionato: PersonaDefunta?  // ✅ CAMBIATO
    @State private var templateSelezionato: DocumentoTemplate?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Selezione Defunto
                        selezioneDefuntoSection
                        
                        if defuntoSelezionato != nil {
                            // Selezione Template
                            selezioneTemplateSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Nuovo Documento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Continua") {
                        if let defunto = defuntoSelezionato,
                           let template = templateSelezionato {
                            onSelection(defunto, template)
                            dismiss()
                        }
                    }
                    .disabled(defuntoSelezionato == nil || templateSelezionato == nil)
                }
            }
        }
        .frame(width: 800, height: 600)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nuovo Documento")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Seleziona defunto e template")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Selezione Defunto Section
    private var selezioneDefuntoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Seleziona Defunto")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 250), spacing: 12)
            ], spacing: 12) {
                ForEach(defunti) { defunto in
                    DefuntoSelectionCard(
                        defunto: defunto,
                        isSelected: defuntoSelezionato?.id == defunto.id
                    ) {
                        defuntoSelezionato = defunto
                    }
                }
            }
        }
    }
    
    // MARK: - Selezione Template Section
    private var selezioneTemplateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. Seleziona Template")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 280), spacing: 12)
            ], spacing: 12) {
                ForEach(templates) { template in
                    TemplateSelectionCard(
                        template: template,
                        isSelected: templateSelezionato?.id == template.id
                    ) {
                        templateSelezionato = template
                    }
                }
            }
        }
    }
}

struct DefuntoSelectionCard: View {
    let defunto: PersonaDefunta  // ✅ CAMBIATO da Defunto a PersonaDefunta
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(defunto.nomeCompleto)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cartella N° \(defunto.numeroCartella)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Nato: \(defunto.dataNascitaFormattata)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Luogo: \(defunto.luogoNascita)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Deceduto: \(defunto.dataDecesoFormattata)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TemplateSelectionCard: View {
    let template: DocumentoTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: template.tipo.icona)
                        .foregroundColor(template.tipo.color)  // ✅ CAMBIATO da .colore a .color
                    
                    Text(template.nome)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(template.tipo.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                HStack {
                    Text("Campi: \(template.campiCompilabili.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if template.isDefault {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("Default")
                                .font(.caption2)
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let defunti = [
        PersonaDefunta(),  // ✅ CAMBIATO da Defunto a PersonaDefunta
        PersonaDefunta()   // ✅ CAMBIATO da Defunto a PersonaDefunta
    ]
    
    let templates = [
        DocumentoTemplate.autorizzazioneTrasporto,
        DocumentoTemplate.comunicazioneParrocchia
    ]
    
    return SelezionaDefuntoTemplateView(
        defunti: defunti,
        templates: templates
    ) { defunto, template in
        print("Selezionati: \(defunto.nomeCompleto) - \(template.nome)")
    }
}

//
//  DocumentoPreviuwView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI
import AppKit

struct DocumentoPreviewView: View {
    let documento: DocumentoCompilato
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Contenuto del documento
                    contenutoSection
                    
                    // Info documento
                    if !documento.placeholderNonSostituiti.isEmpty {
                        placeholderSection
                    }
                    
                    // Informazioni aggiuntive
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Anteprima Documento")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Copia") {
                        copiaTesto()
                    }
                    
                    Button("Stampa") {
                        stampaDocumento()
                    }
                    
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: documento.template.tipo.icona)
                    .font(.title)
                    .foregroundColor(documento.template.tipo.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(documento.template.nome)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Defunto: \(documento.defunto.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Cartella N° \(documento.defunto.numeroCartella)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(documento.isCompletato ? Color.green : Color.orange)
                            .frame(width: 12, height: 12)
                        
                        Text(documento.isCompletato ? "Completato" : "Bozza")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(documento.isCompletato ? .green : .orange)
                    }
                    
                    Text("Generato: \(documento.dataCreazione.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if documento.dataUltimaModifica != documento.dataCreazione {
                        Text("Modificato: \(documento.dataUltimaModifica.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
        }
    }
    
    // MARK: - Contenuto Section
    private var contenutoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Contenuto Documento")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Contatore caratteri
                Text("\(documento.contenutoFinale.count) caratteri")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                Text(documento.contenutoFinale)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 400)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Placeholder Section
    private var placeholderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Placeholder Non Sostituiti")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(documento.placeholderNonSostituiti.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(documento.placeholderNonSostituiti, id: \.self) { placeholder in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("{{\(placeholder)}}")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Informazioni Documento")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InfoCard(
                    titolo: "Template",
                    valore: documento.template.nome,
                    icona: "doc.text.fill",
                    colore: .blue
                )
                
                InfoCard(
                    titolo: "Tipo",
                    valore: documento.template.tipo.rawValue,
                    icona: documento.template.tipo.icona,
                    colore: documento.template.tipo.color
                )
                
                InfoCard(
                    titolo: "Campi Compilati",
                    valore: "\(documento.valoriCampi.count)/\(documento.template.campiCompilabili.count)",
                    icona: "list.bullet",
                    colore: .green
                )
                
                InfoCard(
                    titolo: "Stato",
                    valore: documento.isCompletato ? "Completato" : "Bozza",
                    icona: documento.isCompletato ? "checkmark.circle.fill" : "clock.fill",
                    colore: documento.isCompletato ? .green : .orange
                )
            }
            
            // Note se presenti
            if !documento.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.purple)
                        
                        Text("Note")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    
                    Text(documento.note)
                        .font(.body)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    private func copiaTesto() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documento.contenutoFinale, forType: .string)
    }
    
    private func stampaDocumento() {
        // Implementa funzionalità di stampa
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        
        let printOperation = NSPrintOperation(view: createPrintView())
        printOperation.printInfo = printInfo
        printOperation.showsPrintPanel = true
        printOperation.run()
    }
    
    private func createPrintView() -> NSView {
        // Crea una view per la stampa
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 595, height: 842)) // A4 size
        
        let textView = NSTextView(frame: view.bounds)
        textView.string = documento.contenutoFinale
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.isEditable = false
        
        view.addSubview(textView)
        return view
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let titolo: String
    let valore: String
    let icona: String
    let colore: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icona)
                .font(.title3)
                .foregroundColor(colore)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titolo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(valore)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

#Preview {
    DocumentoPreviewView(
        documento: DocumentoCompilato(
            template: DocumentoTemplate(
                nome: "Comunicazione Parrocchia",
                tipo: .comunicazioneParrocchia,
                contenuto: "SPETT. Santa Maria\n\nDefunto Mario Rossi\n\nNato in Cagliari il 01/01/1950\n\nDeceduto il 15/07/2024"
            ),
            defunto: PersonaDefunta()
        )
    )
}

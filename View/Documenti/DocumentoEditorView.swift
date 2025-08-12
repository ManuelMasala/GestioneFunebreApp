//
//  DocumentoEditorView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import SwiftUI
import AppKit

struct DocumentoEditorView: View {
    @Binding var documento: DocumentoCompilato
    let onSave: (DocumentoCompilato) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var testoModificabile: String
    @State private var showingPreview = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isModified = false
    @State private var fontSize: CGFloat = 12
    @State private var showingFontPanel = false
    
    // Toolbar states
    @State private var isBold = false
    @State private var isItalic = false
    @State private var textAlignment: NSTextAlignment = .left
    
    init(documento: Binding<DocumentoCompilato>, onSave: @escaping (DocumentoCompilato) -> Void) {
        self._documento = documento
        self.onSave = onSave
        
        // Assicuriamoci che il testo sia inizializzato correttamente
        let doc = documento.wrappedValue
        let contenuto = doc.contenutoFinale.isEmpty ? doc.template.contenuto : doc.contenutoFinale
        
        print("🔍 Debug Editor - Contenuto iniziale: \(contenuto.prefix(100))...")
        self._testoModificabile = State(initialValue: contenuto)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con info documento
                headerSection
                
                // Toolbar editor
                editorToolbar
                
                Divider()
                
                // Editor principale
                HSplitView {
                    // Editor di testo
                    textEditorSection
                    
                    // Pannello laterale info
                    if showingPreview {
                        previewSection
                            .frame(minWidth: 300, maxWidth: 400)
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Editor Documento")
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Annulla") {
                    if isModified {
                        showUnsavedChangesAlert()
                    } else {
                        dismiss()
                    }
                }
            }
            
            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Anteprima") {
                    showingPreview.toggle()
                }
                .keyboardShortcut("p", modifiers: .command)
                
                Button("Salva") {
                    salvaDocumento()
                }
                .keyboardShortcut("s", modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("Documento Editor", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: testoModificabile) { _ in
            isModified = true
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: documento.template.tipo.icona)
                    .font(.title2)
                    .foregroundColor(documento.template.tipo.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(documento.template.nome)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Defunto: \(documento.defunto.nomeCompleto)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicators
                HStack(spacing: 12) {
                    if isModified {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            Text("Modificato")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(documento.isCompletato ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(documento.isCompletato ? "Completato" : "In lavorazione")
                            .font(.caption)
                            .foregroundColor(documento.isCompletato ? .green : .orange)
                    }
                    
                    Text("Caratteri: \(testoModificabile.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Editor Toolbar
    private var editorToolbar: some View {
        HStack(spacing: 16) {
            // Font controls
            HStack(spacing: 8) {
                Button(action: { decreaseFontSize() }) {
                    Image(systemName: "textformat.size.smaller")
                }
                .disabled(fontSize <= 8)
                
                Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .frame(width: 30)
                
                Button(action: { increaseFontSize() }) {
                    Image(systemName: "textformat.size.larger")
                }
                .disabled(fontSize >= 24)
            }
            
            Divider()
                .frame(height: 20)
            
            // Text formatting
            HStack(spacing: 4) {
                Button(action: { toggleBold() }) {
                    Image(systemName: "bold")
                        .foregroundColor(isBold ? .blue : .primary)
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button(action: { toggleItalic() }) {
                    Image(systemName: "italic")
                        .foregroundColor(isItalic ? .blue : .primary)
                }
                .keyboardShortcut("i", modifiers: .command)
            }
            
            Divider()
                .frame(height: 20)
            
            // Alignment
            HStack(spacing: 4) {
                Button(action: { setAlignment(.left) }) {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(textAlignment == .left ? .blue : .primary)
                }
                
                Button(action: { setAlignment(.center) }) {
                    Image(systemName: "text.aligncenter")
                        .foregroundColor(textAlignment == .center ? .blue : .primary)
                }
                
                Button(action: { setAlignment(.right) }) {
                    Image(systemName: "text.alignright")
                        .foregroundColor(textAlignment == .right ? .blue : .primary)
                }
            }
            
            Divider()
                .frame(height: 20)
            
            // Actions
            HStack(spacing: 8) {
                Button("Ripristina") {
                    ripristinaOriginale()
                }
                .foregroundColor(.orange)
                
                Button("Compila Campi") {
                    compilaCampiAutomatici()
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Word count and validation
            HStack(spacing: 12) {
                Text("Parole: \(contaParole())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                let placeholders = documento.placeholderNonSostituiti
                if !placeholders.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("\(placeholders.count) campi mancanti")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - Text Editor Section
    private var textEditorSection: some View {
        VStack(spacing: 0) {
            // NSTextView wrapper per editing avanzato
            DocumentTextEditor(
                text: $testoModificabile,
                fontSize: fontSize,
                isBold: isBold,
                isItalic: isItalic,
                alignment: textAlignment
            )
            .frame(minWidth: 400)
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Anteprima")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Preview del documento
                    Text(testoModificabile)
                        .font(.system(size: 10))
                        .padding(12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Info documento
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informazioni")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        infoRow("Template", documento.template.nome)
                        infoRow("Tipo", documento.template.tipo.rawValue)
                        infoRow("Defunto", documento.defunto.nomeCompleto)
                        infoRow("Cartella", documento.defunto.numeroCartella)
                        infoRow("Data Creazione", documento.dataCreazioneFormattata)
                        
                        if !documento.note.isEmpty {
                            infoRow("Note", documento.note)
                        }
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Placeholder mancanti
                    let placeholders = documento.placeholderNonSostituiti
                    if !placeholders.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Campi da completare")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            ForEach(placeholders, id: \.self) { placeholder in
                                Text("• \(placeholder)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.02))
    }
    
    // MARK: - Helper Methods
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .trailing)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private func contaParole() -> Int {
        let words = testoModificabile.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private func increaseFontSize() {
        fontSize = min(fontSize + 1, 24)
    }
    
    private func decreaseFontSize() {
        fontSize = max(fontSize - 1, 8)
    }
    
    private func toggleBold() {
        isBold.toggle()
    }
    
    private func toggleItalic() {
        isItalic.toggle()
    }
    
    private func setAlignment(_ alignment: NSTextAlignment) {
        textAlignment = alignment
    }
    
    private func ripristinaOriginale() {
        testoModificabile = documento.template.contenuto
        isModified = true
    }
    
    private func compilaCampiAutomatici() {
        var documentoTemp = documento
        documentoTemp.compilaConDefunto()
        testoModificabile = documentoTemp.contenutoFinale
        isModified = true
    }
    
    private func salvaDocumento() {
        print("💾 Salvando documento...")
        documento.contenutoFinale = testoModificabile
        documento.dataUltimaModifica = Date()
        
        // Marca come completato se non ci sono placeholder
        if documento.placeholderNonSostituiti.isEmpty {
            documento.marcaCompletato()
        }
        
        onSave(documento)
        isModified = false
        alertMessage = "Documento salvato con successo!"
        showingAlert = true
        
        // Chiudi dopo 1.5 secondi
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func showUnsavedChangesAlert() {
        // TODO: Implementa alert per modifiche non salvate
        dismiss()
    }
}

// MARK: - NSTextView Wrapper (VERSIONE CORRETTA E MINIMALE)
struct DocumentTextEditor: NSViewRepresentable {
    @Binding var text: String
    let fontSize: CGFloat
    let isBold: Bool
    let isItalic: Bool
    let alignment: NSTextAlignment
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: fontSize)
        textView.alignment = alignment
        textView.string = text
        textView.delegate = context.coordinator
        
        print("🔍 Debug NSTextView - Testo iniziale: \(text.prefix(100))...")
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
        }
        
        // Aggiorna font
        var font = NSFont.systemFont(ofSize: fontSize)
        if isBold && isItalic {
            font = NSFont.boldSystemFont(ofSize: fontSize)
            // Per italic + bold useremo il font manager
        } else if isBold {
            font = NSFont.boldSystemFont(ofSize: fontSize)
        } else if isItalic {
            font = NSFont.systemFont(ofSize: fontSize)
            // Per italic useremo il font manager
        }
        
        textView.font = font
        textView.alignment = alignment
        
        // Applica allineamento al testo esistente
        let range = NSRange(location: 0, length: textView.string.count)
        textView.setAlignment(alignment, range: range)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: DocumentTextEditor
        
        init(_ parent: DocumentTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

#Preview {
    @State var sampleDoc = DocumentoCompilato(
        template: DocumentoTemplate.autorizzazioneTrasporto,
        defunto: PersonaDefunta()
    )
    
    return DocumentoEditorView(documento: $sampleDoc) { doc in
        print("Documento salvato: \(doc.template.nome)")
    }
}

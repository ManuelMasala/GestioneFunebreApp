//
//  NovoDefuntoView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 09/07/25.
//

import SwiftUI

struct NuovoDefuntoBasicView: View {
    @EnvironmentObject var manager: ManagerGestioneDefunti
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var cognome = ""
    @State private var luogoNascita = ""
    @State private var dataNascita = Date()
    @State private var dataDecesso = Date()
    @State private var sesso: SessoPersona = .maschio
    @State private var tipoSepoltura: TipologiaSepoltura = .tumulazione
    
    // Familiare responsabile
    @State private var nomeFamiliare = ""
    @State private var cognomeFamiliare = ""
    @State private var telefonoFamiliare = ""
    @State private var parentela: FamiliareResponsabile.GradoParentela = .figlio
    
    @State private var showingValidationAlert = false
    @State private var validationErrors: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dati Principali Defunto") {
                    HStack {
                        Text("Nome:")
                        TextField("Nome", text: $nome)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Cognome:")
                        TextField("Cognome", text: $cognome)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Luogo Nascita:")
                        TextField("Luogo di nascita", text: $luogoNascita)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    DatePicker("Data Nascita:", selection: $dataNascita, displayedComponents: .date)
                    DatePicker("Data Decesso:", selection: $dataDecesso, displayedComponents: .date)
                    
                    Picker("Sesso:", selection: $sesso) {
                        Text("Maschio").tag(SessoPersona.maschio)
                        Text("Femmina").tag(SessoPersona.femmina)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Tipo Sepoltura:", selection: $tipoSepoltura) {
                        ForEach(TipologiaSepoltura.allCases, id: \.self) { tipo in
                            Text(tipo.rawValue).tag(tipo)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Familiare Responsabile") {
                    HStack {
                        Text("Nome:")
                        TextField("Nome familiare", text: $nomeFamiliare)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Cognome:")
                        TextField("Cognome familiare", text: $cognomeFamiliare)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Telefono:")
                        TextField("Numero telefono", text: $telefonoFamiliare)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Picker("Parentela:", selection: $parentela) {
                        ForEach(FamiliareResponsabile.GradoParentela.allCases) { grado in
                            Text(grado.rawValue).tag(grado)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Nuovo Defunto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        salvaDefunto()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 600, height: 500)
        .alert("Errori di Validazione", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationErrors.joined(separator: "\n"))
        }
    }
    
    private var isFormValid: Bool {
        !nome.isEmpty && !cognome.isEmpty && !luogoNascita.isEmpty &&
        !nomeFamiliare.isEmpty && !cognomeFamiliare.isEmpty && !telefonoFamiliare.isEmpty
    }
    
    private func salvaDefunto() {
        // Validazione
        validationErrors = []
        
        if nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il nome è obbligatorio")
        }
        
        if cognome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il cognome è obbligatorio")
        }
        
        if luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il luogo di nascita è obbligatorio")
        }
        
        if dataNascita >= dataDecesso {
            validationErrors.append("La data di nascita deve essere precedente alla data di decesso")
        }
        
        if nomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il nome del familiare è obbligatorio")
        }
        
        if cognomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il cognome del familiare è obbligatorio")
        }
        
        if telefonoFamiliare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append("Il telefono del familiare è obbligatorio")
        }
        
        if !validationErrors.isEmpty {
            showingValidationAlert = true
            return
        }
        
        // Crea nuovo defunto
        var nuovoDefunto = PersonaDefunta(
            numeroCartella: manager.generaNuovoNumeroCartella(),
            nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
            cognome: cognome.trimmingCharacters(in: .whitespacesAndNewlines),
            sesso: sesso,
            dataNascita: dataNascita,
            luogoNascita: luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines),
            dataDecesso: dataDecesso,
            tipoSepoltura: tipoSepoltura,
            operatoreCorrente: "Operatore Manuale"
        )
        
        // Configura familiare responsabile
        nuovoDefunto.familiareRichiedente.nome = nomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.cognome = cognomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.telefono = telefonoFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.parentela = parentela
        
        // Genera codice fiscale se possibile (usando il calcolatore esterno)
        if !nome.isEmpty && !cognome.isEmpty && !luogoNascita.isEmpty {
            nuovoDefunto.codiceFiscale = CalcolatoreCodiceFiscaleItaliano.calcola(
                nome: nome,
                cognome: cognome,
                dataNascita: dataNascita,
                luogoNascita: luogoNascita,
                sesso: sesso
            )
        }
        
        // Salva
        manager.aggiungiDefunto(nuovoDefunto)
        dismiss()
    }
}

#Preview {
    NuovoDefuntoBasicView()
        .environmentObject(ManagerGestioneDefunti())
}

//
//  NovoDefuntoView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 09/07/25.
//

import SwiftUI

struct NuovoDefuntoBasicView: View {
    @EnvironmentObject private var manager: ManagerGestioneDefunti
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome = ""
    @State private var cognome = ""
    @State private var sesso: SessoPersona = .maschio
    @State private var dataNascita = Date()
    @State private var luogoNascita = ""
    @State private var codiceFiscale = ""
    @State private var statoCivile: StatoCivilePersona = .celibe
    @State private var nomeConiuge = ""
    @State private var paternita = ""
    @State private var maternita = ""
    
    @State private var dataDecesso = Date()
    @State private var oraDecesso = ""
    @State private var luogoDecesso = LuogoMorte.allCases.first!
    @State private var nomeOspedale = ""
    
    @State private var tipoSepoltura: TipologiaSepoltura = .tumulazione
    @State private var luogoSepoltura = ""
    @State private var dettagliSepoltura = ""
    
    @State private var nomeFamiliare = ""
    @State private var cognomeFamiliare = ""
    @State private var parentela: FamiliareResponsabile.GradoParentela = .figlio
    @State private var telefonoFamiliare = ""
    @State private var emailFamiliare = ""
    @State private var indirizzoFamiliare = ""
    
    @State private var numeroCartella = ""
    @State private var showingSaveAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Nuovo Defunto - Cartella N° \(numeroCartella)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Completamento: \(Int(formCompletionPercentage * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isFormValid ? .green : .orange)
                    }
                    
                    ProgressView(value: formCompletionPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: isFormValid ? .green : .blue))
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Tab Selector
                Picker("Sezione", selection: $selectedTab) {
                    Text("Anagrafico").tag(0)
                    Text("Decesso").tag(1)
                    Text("Sepoltura").tag(2)
                    Text("Familiare").tag(3)
                    Text("Riepilogo").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    anagraficoSection.tag(0)
                    decesoSection.tag(1)
                    sepolturaSection.tag(2)
                    familiareSection.tag(3)
                    riepilogoSection.tag(4)
                }
                .tabViewStyle(DefaultTabViewStyle())
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
                    .foregroundColor(isFormValid ? .blue : .gray)
                }
            }
        }
        .frame(minWidth: 800, minHeight: 700)
        .onAppear {
            numeroCartella = manager.generaNuovoNumeroCartella()
        }
        .alert("Defunto Salvato", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Il defunto \(nome) \(cognome) è stato salvato con successo!")
        }
    }
    
    // MARK: - Anagrafico Section
    private var anagraficoSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("1. Dati Anagrafici")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Nome *")
                                .fontWeight(.semibold)
                            TextField("Nome", text: $nome)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Cognome *")
                                .fontWeight(.semibold)
                            TextField("Cognome", text: $cognome)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Sesso")
                                .fontWeight(.semibold)
                            Picker("Sesso", selection: $sesso) {
                                ForEach(SessoPersona.allCases, id: \.self) { sessoItem in
                                    Text(sessoItem.descrizione).tag(sessoItem)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Data di Nascita")
                                .fontWeight(.semibold)
                            DatePicker("", selection: $dataNascita, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Luogo di Nascita *")
                                .fontWeight(.semibold)
                            TextField("Città di nascita", text: $luogoNascita)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Codice Fiscale")
                                .fontWeight(.semibold)
                            TextField("Auto-calcolato se vuoto", text: $codiceFiscale)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Stato Civile")
                                .fontWeight(.semibold)
                            Picker("Stato Civile", selection: $statoCivile) {
                                ForEach(StatoCivilePersona.allCases, id: \.self) { stato in
                                    Text(stato.rawValue).tag(stato)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Nome Coniuge")
                                .fontWeight(.semibold)
                            TextField("Se applicabile", text: $nomeConiuge)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Paternità")
                                .fontWeight(.semibold)
                            TextField("Nome del padre", text: $paternita)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Maternità")
                                .fontWeight(.semibold)
                            TextField("Nome della madre", text: $maternita)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Button("Vai al Decesso →") {
                    selectedTab = 1
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Deceso Section
    private var decesoSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("2. Decesso")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Data Decesso")
                                .fontWeight(.semibold)
                            DatePicker("", selection: $dataDecesso, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Ora Decesso *")
                                .fontWeight(.semibold)
                            TextField("es. 14:30", text: $oraDecesso)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Luogo Decesso")
                                .fontWeight(.semibold)
                            Picker("Luogo", selection: $luogoDecesso) {
                                ForEach(LuogoMorte.allCases, id: \.self) { luogo in
                                    Text(luogo.rawValue).tag(luogo)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Nome Ospedale")
                                .fontWeight(.semibold)
                            TextField("Se applicabile", text: $nomeOspedale)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                HStack {
                    Button("← Anagrafico") {
                        selectedTab = 0
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Sepoltura →") {
                        selectedTab = 2
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Sepoltura Section
    private var sepolturaSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("3. Sepoltura")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Tipo Sepoltura")
                            .fontWeight(.semibold)
                        Picker("Tipo", selection: $tipoSepoltura) {
                            ForEach(TipologiaSepoltura.allCases, id: \.self) { tipo in
                                Text(tipo.rawValue).tag(tipo)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Luogo Sepoltura *")
                            .fontWeight(.semibold)
                        TextField("Cimitero o luogo", text: $luogoSepoltura)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Dettagli Sepoltura")
                            .fontWeight(.semibold)
                        TextField("Note, settore, numero...", text: $dettagliSepoltura)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                HStack {
                    Button("← Decesso") {
                        selectedTab = 1
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Familiare →") {
                        selectedTab = 3
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Familiare Section
    private var familiareSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("4. Familiare Responsabile")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Nome Familiare *")
                                .fontWeight(.semibold)
                            TextField("Nome", text: $nomeFamiliare)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Cognome Familiare")
                                .fontWeight(.semibold)
                            TextField("Cognome", text: $cognomeFamiliare)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Parentela")
                                .fontWeight(.semibold)
                            Picker("Parentela", selection: $parentela) {
                                ForEach(FamiliareResponsabile.GradoParentela.allCases, id: \.self) { grado in
                                    Text(grado.rawValue).tag(grado)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Telefono *")
                                .fontWeight(.semibold)
                            TextField("+39 333 123 4567", text: $telefonoFamiliare)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Email")
                                .fontWeight(.semibold)
                            TextField("email@esempio.it", text: $emailFamiliare)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Indirizzo")
                                .fontWeight(.semibold)
                            TextField("Indirizzo completo", text: $indirizzoFamiliare)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                HStack {
                    Button("← Sepoltura") {
                        selectedTab = 2
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Riepilogo →") {
                        selectedTab = 4
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Riepilogo Section
    private var riepilogoSection: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("5. Riepilogo e Salvataggio")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.mint)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Cartella N°:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(numeroCartella)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Completamento:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(formCompletionPercentage * 100))%")
                            .fontWeight(.bold)
                            .foregroundColor(isFormValid ? .green : .orange)
                    }
                    
                    HStack {
                        Text("Stato:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(isFormValid ? "✅ Pronto per salvare" : "⚠️ Completa i campi")
                            .fontWeight(.medium)
                            .foregroundColor(isFormValid ? .green : .orange)
                    }
                    
                    if !nome.isEmpty && !cognome.isEmpty {
                        HStack {
                            Text("Defunto:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(nome) \(cognome)")
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(spacing: 12) {
                    Text("Campi Obbligatori:")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RequiredFieldRow(label: "Nome", isComplete: !nome.isEmpty)
                        RequiredFieldRow(label: "Cognome", isComplete: !cognome.isEmpty)
                        RequiredFieldRow(label: "Luogo Nascita", isComplete: !luogoNascita.isEmpty)
                        RequiredFieldRow(label: "Ora Decesso", isComplete: !oraDecesso.isEmpty)
                        RequiredFieldRow(label: "Luogo Sepoltura", isComplete: !luogoSepoltura.isEmpty)
                        RequiredFieldRow(label: "Nome Familiare", isComplete: !nomeFamiliare.isEmpty)
                        RequiredFieldRow(label: "Telefono Familiare", isComplete: !telefonoFamiliare.isEmpty)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                
                Button(action: salvaDefunto) {
                    HStack {
                        Image(systemName: isFormValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        Text("Salva Defunto")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.green : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid)
                
                Button("← Familiare") {
                    selectedTab = 3
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var isFormValid: Bool {
        return !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !cognome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !oraDecesso.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !luogoSepoltura.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !nomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !telefonoFamiliare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var formCompletionPercentage: Double {
        let requiredFields = [nome, cognome, luogoNascita, oraDecesso, luogoSepoltura, nomeFamiliare, telefonoFamiliare]
        let completedFields = requiredFields.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        return Double(completedFields) / Double(requiredFields.count)
    }
    
    private func salvaDefunto() {
        var nuovoDefunto = PersonaDefunta()
        
        nuovoDefunto.numeroCartella = numeroCartella
        nuovoDefunto.nome = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.cognome = cognome.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.sesso = sesso
        nuovoDefunto.dataNascita = dataNascita
        nuovoDefunto.luogoNascita = luogoNascita.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.statoCivile = statoCivile
        nuovoDefunto.nomeConiuge = nomeConiuge.isEmpty ? nil : nomeConiuge
        nuovoDefunto.paternita = paternita
        nuovoDefunto.maternita = maternita
        
        nuovoDefunto.dataDecesso = dataDecesso
        nuovoDefunto.oraDecesso = oraDecesso.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.luogoDecesso = luogoDecesso
        nuovoDefunto.nomeOspedale = nomeOspedale.isEmpty ? nil : nomeOspedale
        
        nuovoDefunto.tipoSepoltura = tipoSepoltura
        nuovoDefunto.luogoSepoltura = luogoSepoltura.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.dettagliSepoltura = dettagliSepoltura.isEmpty ? nil : dettagliSepoltura
        
        nuovoDefunto.familiareRichiedente.nome = nomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.cognome = cognomeFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.parentela = parentela
        nuovoDefunto.familiareRichiedente.telefono = telefonoFamiliare.trimmingCharacters(in: .whitespacesAndNewlines)
        nuovoDefunto.familiareRichiedente.email = emailFamiliare.isEmpty ? nil : emailFamiliare
        nuovoDefunto.familiareRichiedente.indirizzo = indirizzoFamiliare
        
        if codiceFiscale.isEmpty {
            nuovoDefunto.codiceFiscale = CalcolatoreCodiceFiscaleItaliano.calcola(
                nome: nuovoDefunto.nome,
                cognome: nuovoDefunto.cognome,
                dataNascita: nuovoDefunto.dataNascita,
                luogoNascita: nuovoDefunto.luogoNascita,
                sesso: nuovoDefunto.sesso
            )
        } else {
            nuovoDefunto.codiceFiscale = codiceFiscale
        }
        
        nuovoDefunto.operatoreCreazione = "Demo Operatore"
        nuovoDefunto.dataCreazione = Date()
        nuovoDefunto.dataUltimaModifica = Date()
        
        manager.aggiungiDefunto(nuovoDefunto)
        showingSaveAlert = true
    }
}

// MARK: - Required Field Row
struct RequiredFieldRow: View {
    let label: String
    let isComplete: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .orange)
            
            Text(label)
                .foregroundColor(isComplete ? .green : .primary)
            
            Spacer()
        }
    }
}

#Preview {
    NuovoDefuntoBasicView()
        .environmentObject(ManagerGestioneDefunti())
}

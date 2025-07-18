//
//  NuovoMezzoView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI

struct NuovoMezzoView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Mezzo) -> Void
    
    @State private var targa = ""
    @State private var marca = ""
    @State private var modello = ""
    @State private var stato: StatoMezzo = .disponibile
    @State private var km = "0"
    @State private var dataRevisione = Date()
    @State private var tipoProprietà: TipoProprietaMezzo = .proprio
    @State private var dataAcquisto = Date()
    @State private var dataScadenzaNoleggio = Date()
    @State private var costoNoleggio: Double = 0.0
    @State private var note = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var isFormValid: Bool {
        !targa.isEmpty && !marca.isEmpty && !modello.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Form content in VStack instead of Form
                    VStack(spacing: 20) {
                        datiPrincipaliSection
                        statoERevisioneSection
                        tipoProprietaSection
                        noteSection
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Nuovo Veicolo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        salvaMezzo()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Errore", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .frame(width: 700, height: 600)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Image(systemName: "car.2.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nuovo Veicolo")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Aggiungi un nuovo mezzo alla flotta")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Dati Principali Section
    private var datiPrincipaliSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dati Principali")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Targa")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Targa", text: $targa)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Marca")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Marca", text: $marca)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Modello")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Modello", text: $modello)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chilometri")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Chilometri", text: $km)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Stato e Revisione Section
    private var statoERevisioneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stato e Revisione")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stato Iniziale")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Stato Iniziale", selection: $stato) {
                        ForEach(StatoMezzo.allCases) { stato in
                            HStack {
                                Circle()
                                    .fill(stato.color)
                                    .frame(width: 12, height: 12)
                                Text(stato.rawValue)
                            }
                            .tag(stato)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Revisione")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "",
                        selection: $dataRevisione,
                        displayedComponents: .date
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Tipo Proprietà Section
    private var tipoProprietaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tipo Proprietà")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                Picker("Tipo", selection: $tipoProprietà) {
                    Text("Proprio")
                        .tag(TipoProprietaMezzo.proprio)
                    
                    Text("Noleggio")
                        .tag(TipoProprietaMezzo.noleggio)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Campi condizionali
                if tipoProprietà == .proprio {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Acquisto")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "",
                            selection: $dataAcquisto,
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    }
                } else {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Scadenza Noleggio")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            DatePicker(
                                "",
                                selection: $dataScadenzaNoleggio,
                                displayedComponents: .date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Costo Mensile")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField(
                                    "Costo",
                                    value: $costoNoleggio,
                                    format: .currency(code: "EUR")
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 200)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Note Section
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
                .overlay(
                    HStack {
                        if note.isEmpty {
                            Text("Note aggiuntive (opzionale)")
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                        }
                        Spacer()
                    },
                    alignment: .topLeading
                )
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    private func salvaMezzo() {
        // Validazione avanzata
        guard validaForm() else { return }
        
        // Crea il nuovo mezzo
        var nuovoMezzo = Mezzo(
            targa: targa.uppercased().trimmingCharacters(in: .whitespacesAndNewlines),
            modello: modello.trimmingCharacters(in: .whitespacesAndNewlines),
            marca: marca.trimmingCharacters(in: .whitespacesAndNewlines),
            stato: stato,
            km: km.trimmingCharacters(in: .whitespacesAndNewlines),
            dataRevisione: dataRevisione,
            tipoProprietà: tipoProprietà
        )
        
        // Imposta dati specifici per tipo proprietà
        if tipoProprietà == .proprio {
            nuovoMezzo.dataAcquisto = dataAcquisto
            print("🏠 Impostando come PROPRIO - Data acquisto: \(dataAcquisto)")
        } else {
            nuovoMezzo.dataScadenzaNoleggio = dataScadenzaNoleggio
            nuovoMezzo.costoNoleggio = costoNoleggio
            print("🏢 Impostando come NOLEGGIO - Scadenza: \(dataScadenzaNoleggio), Costo: \(costoNoleggio)")
        }
        
        // Imposta note se non vuote
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nuovoMezzo.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        print("💾 Salvando mezzo: \(nuovoMezzo.targa) - Tipo: \(nuovoMezzo.tipoProprietà.rawValue)")
        
        // Salva e chiudi
        onSave(nuovoMezzo)
        dismiss()
    }
    
    private func validaForm() -> Bool {
        // Controlla targa
        let targaTrimmed = targa.trimmingCharacters(in: .whitespacesAndNewlines)
        if targaTrimmed.isEmpty {
            alertMessage = "La targa è obbligatoria"
            showingAlert = true
            return false
        }
        
        if targaTrimmed.count < 6 || targaTrimmed.count > 8 {
            alertMessage = "La targa deve essere di 6-8 caratteri"
            showingAlert = true
            return false
        }
        
        // Controlla marca
        if marca.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "La marca è obbligatoria"
            showingAlert = true
            return false
        }
        
        // Controlla modello
        if modello.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Il modello è obbligatorio"
            showingAlert = true
            return false
        }
        
        // Controlla km
        let kmTrimmed = km.trimmingCharacters(in: .whitespacesAndNewlines)
        if !kmTrimmed.isEmpty {
            // Rimuovi punti e virgole per controllo numerico
            let kmNumeric = kmTrimmed.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
            if Int(kmNumeric) == nil {
                alertMessage = "I chilometri devono essere un numero valido"
                showingAlert = true
                return false
            }
        }
        
        // Controlla date per noleggio
        if tipoProprietà == .noleggio {
            if dataScadenzaNoleggio <= Date() {
                alertMessage = "La scadenza del noleggio deve essere futura"
                showingAlert = true
                return false
            }
            
            if costoNoleggio <= 0 {
                alertMessage = "Il costo del noleggio deve essere maggiore di zero"
                showingAlert = true
                return false
            }
        }
        
        return true
    }
}

#Preview {
    NuovoMezzoView { mezzo in
        print("Nuovo mezzo: \(mezzo.targa)")
    }
}

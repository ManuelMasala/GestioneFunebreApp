//
//  ModificaMezzoView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 18/07/25.
//

import SwiftUI

struct ModificaMezzoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mezzo: Mezzo
    @State private var showingManutenzioniView = false
    @State private var showingNuovaManutenzione = false
    @State private var showingDeleteAlert = false
    
    let onSave: (Mezzo) -> Void
    
    init(mezzo: Mezzo, onSave: @escaping (Mezzo) -> Void) {
        self._mezzo = State(initialValue: mezzo)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con info mezzo
                    headerSection
                    
                    // Dati principali
                    datiPrincipaliSection
                    
                    // Tipo proprietà
                    tipoProprietaSection
                    
                    // Manutenzioni
                    manutenzioniSection
                    
                    // Note
                    noteSection
                }
                .padding()
            }
            .navigationTitle("Modifica Mezzo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Salva") {
                        onSave(mezzo)
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 900, height: 700)
        .sheet(isPresented: $showingManutenzioniView) {
            ManutenzioniView(mezzo: $mezzo)
        }
        .sheet(isPresented: $showingNuovaManutenzione) {
            NuovaManutenzioneView(mezzo: $mezzo)
        }
        .alert("Elimina Mezzo", isPresented: $showingDeleteAlert) {
            Button("Elimina", role: .destructive) {
                // Implementa eliminazione
                dismiss()
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Sei sicuro di voler eliminare questo mezzo? L'azione non può essere annullata.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "car.2.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mezzo.targa)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(mezzo.marca) \(mezzo.modello)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Stato mezzo
                Menu {
                    ForEach(StatoMezzo.allCases, id: \.self) { stato in
                        Button(action: { mezzo.stato = stato }) {
                            HStack {
                                Circle()
                                    .fill(stato.color)
                                    .frame(width: 12, height: 12)
                                Text(stato.rawValue)
                                if mezzo.stato == stato {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(mezzo.stato.color)
                            .frame(width: 12, height: 12)
                        Text(mezzo.stato.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(mezzo.stato.color.opacity(0.1))
                    .foregroundColor(mezzo.stato.color)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
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
                    TextField("Targa", text: $mezzo.targa)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Marca")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Marca", text: $mezzo.marca)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Modello")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Modello", text: $mezzo.modello)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chilometri")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Chilometri", text: $mezzo.km)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // keyboardType rimosso per macOS
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Revisione")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $mezzo.dataRevisione, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                
                if mezzo.isRevisioneScaduta {
                    Label("Revisione scaduta", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
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
            
            Picker("Tipo Proprietà", selection: $mezzo.tipoProprietà) {
                Text("Proprio")
                    .tag(TipoProprietaMezzo.proprio)
                
                Text("Noleggio")
                    .tag(TipoProprietaMezzo.noleggio)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: mezzo.tipoProprietà) { newValue in
                // Reset campi quando si cambia tipo
                if newValue == .proprio {
                    if mezzo.dataAcquisto == nil {
                        mezzo.dataAcquisto = Date()
                    }
                    mezzo.dataScadenzaNoleggio = nil
                    mezzo.costoNoleggio = nil
                } else {
                    if mezzo.dataScadenzaNoleggio == nil {
                        mezzo.dataScadenzaNoleggio = Date()
                    }
                    if mezzo.costoNoleggio == nil {
                        mezzo.costoNoleggio = 0.0
                    }
                    mezzo.dataAcquisto = nil
                }
            }
            
            // Campi condizionali basati sul tipo
            if mezzo.tipoProprietà == .proprio {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Acquisto")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: Binding(
                        get: { mezzo.dataAcquisto ?? Date() },
                        set: { newValue in
                            mezzo.dataAcquisto = newValue
                        }
                    ), displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                }
            } else {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Scadenza Noleggio")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: Binding(
                            get: { mezzo.dataScadenzaNoleggio ?? Date() },
                            set: { newValue in
                                mezzo.dataScadenzaNoleggio = newValue
                            }
                        ), displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        
                        if mezzo.isScadutoNoleggio {
                            Label("Noleggio scaduto", systemImage: "calendar.badge.exclamationmark")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Costo Noleggio Mensile")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Costo", value: Binding(
                                get: { mezzo.costoNoleggio ?? 0.0 },
                                set: { newValue in
                                    mezzo.costoNoleggio = newValue
                                }
                            ), format: .currency(code: "EUR"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            // keyboardType rimosso per macOS
                            .frame(maxWidth: 200)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Manutenzioni Section
    private var manutenzioniSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Manutenzioni")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Vedi Tutte") {
                    showingManutenzioniView = true
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
            
            // Statistiche manutenzioni
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Totale")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(mezzo.manutenzioni.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Costo Totale")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mezzo.costoTotaleManutenzioni, format: .currency(code: "EUR"))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button("Nuova Manutenzione") {
                    showingNuovaManutenzione = true
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            // Ultime manutenzioni (max 3)
            if !mezzo.manutenzioni.isEmpty {
                VStack(spacing: 8) {
                    let ultimeManutenzioni = Array(mezzo.manutenzioni.sorted { $0.data > $1.data }.prefix(3))
                    
                    ForEach(ultimeManutenzioni) { manutenzione in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(manutenzione.tipo.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(manutenzione.data.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(manutenzione.costo, format: .currency(code: "EUR"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(6)
                    }
                    
                    if mezzo.manutenzioni.count > 3 {
                        Button("Vedi altre \(mezzo.manutenzioni.count - 3) manutenzioni") {
                            showingManutenzioniView = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("Nessuna manutenzione registrata")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Aggiungi la prima manutenzione") {
                        showingNuovaManutenzione = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
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
            
            TextEditor(text: $mezzo.note)
                .frame(minHeight: 100)
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
}

#Preview {
    let mezzoEsempio = Mezzo(
        targa: "AA123BB",
        modello: "Classe E",
        marca: "Mercedes",
        dataRevisione: Date()
    )
    
    return ModificaMezzoView(mezzo: mezzoEsempio) { mezzo in
        print("Mezzo aggiornato: \(mezzo.targa)")
    }
}

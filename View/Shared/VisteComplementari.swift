//
//  VisteComplementari.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 17/07/25.
//

import SwiftUI

// MARK: - Contabilità View
struct ContabilitaModernaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contabilità")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Gestisci fatture e pagamenti")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Tab Selector
                    Picker("Sezione", selection: $selectedTab) {
                        Text("Fatture").tag(0)
                        Text("Pagamenti").tag(1)
                        Text("Statistiche").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    fattureView.tag(0)
                    pagamentiView.tag(1)
                    statisticheView.tag(2)
                }
                .tabViewStyle(DefaultTabViewStyle())
            }
            .navigationTitle("Contabilità")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuova Fattura") {
                        // Azione nuova fattura
                    }
                }
            }
        }
        .frame(width: 900, height: 700)
    }
    
    private var fattureView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<10) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fattura #2024-\(String(format: "%03d", index + 1))")
                                .font(.headline)
                            
                            Text("Cliente: Mario Rossi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("€2.450,00")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Pagata")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private var pagamentiView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<8) { index in
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pagamento ricevuto")
                                .font(.headline)
                            
                            Text("Bonifico bancario")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("€1.200,00")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Oggi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private var statisticheView: some View {
        ScrollView {
            VStack(spacing: 20) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ContabilitaStatCard(
                        title: "Fatturato Mese",
                        value: "€45.230",
                        icon: "eurosign.circle.fill",
                        color: .green
                    )
                    
                    ContabilitaStatCard(
                        title: "Incassato",
                        value: "€38.450",
                        icon: "checkmark.circle.fill",
                        color: .blue
                    )
                    
                    ContabilitaStatCard(
                        title: "In Attesa",
                        value: "€6.780",
                        icon: "clock.fill",
                        color: .orange
                    )
                    
                    ContabilitaStatCard(
                        title: "Scadute",
                        value: "€2.100",
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Inventario View
struct InventarioModernoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Inventario")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Magazzino e scorte")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Categories
                    Picker("Categoria", selection: $selectedCategory) {
                        Text("Bare").tag(0)
                        Text("Fiori").tag(1)
                        Text("Accessori").tag(2)
                        Text("Materiali").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
                // Content
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(inventarioItems, id: \.id) { item in
                            InventarioCard(item: item)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Inventario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuovo Articolo") {
                        // Azione nuovo articolo
                    }
                }
            }
        }
        .frame(width: 900, height: 700)
    }
    
    private var inventarioItems: [InventarioItem] {
        [
            InventarioItem(id: 1, nome: "Bara Standard", quantita: 12, minimo: 5, categoria: .bare, prezzo: 850.0),
            InventarioItem(id: 2, nome: "Bara Deluxe", quantita: 3, minimo: 2, categoria: .bare, prezzo: 1200.0),
            InventarioItem(id: 3, nome: "Corona Fiori", quantita: 25, minimo: 10, categoria: .fiori, prezzo: 75.0),
            InventarioItem(id: 4, nome: "Bouquet Rose", quantita: 8, minimo: 15, categoria: .fiori, prezzo: 45.0),
            InventarioItem(id: 5, nome: "Cuscino Funebre", quantita: 18, minimo: 8, categoria: .accessori, prezzo: 35.0),
            InventarioItem(id: 6, nome: "Candele Cera", quantita: 45, minimo: 20, categoria: .materiali, prezzo: 12.0)
        ]
    }
}

// MARK: - Fornitori View
struct FornitoriModerniView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.indigo)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fornitori")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Gestisci i fornitori")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Fornitori List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(fornitori, id: \.id) { fornitore in
                            FornitoreCard(fornitore: fornitore)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Fornitori")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuovo Fornitore") {
                        // Azione nuovo fornitore
                    }
                }
            }
        }
        .frame(width: 800, height: 600)
    }
    
    private var fornitori: [Fornitore] {
        [
            Fornitore(id: 1, nome: "Fiori Bella Vista", categoria: .fiori, contatto: "Mario Verdi", telefono: "0123 456789", email: "info@fioriBV.it", stato: .attivo),
            Fornitore(id: 2, nome: "Bare Artigianali SRL", categoria: .bare, contatto: "Giuseppe Rossi", telefono: "0123 987654", email: "vendite@bareartigianali.it", stato: .attivo),
            Fornitore(id: 3, nome: "Trasporti Funebri", categoria: .trasporti, contatto: "Antonio Bianchi", telefono: "0123 555666", email: "trasporti@funeral.it", stato: .sospeso),
            Fornitore(id: 4, nome: "Accessori Liturgici", categoria: .accessori, contatto: "Maria Neri", telefono: "0123 333444", email: "info@liturgici.it", stato: .attivo)
        ]
    }
}

// MARK: - Supporting Views

// Contabilità Stat Card
struct ContabilitaStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Inventario Card
struct InventarioCard: View {
    let item: InventarioItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: item.categoria.icon)
                    .foregroundColor(item.categoria.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.nome)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("€\(item.prezzo, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Disponibili")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(item.quantita)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(item.quantita <= item.minimo ? .red : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Minimo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(item.minimo)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            if item.quantita <= item.minimo {
                Text("⚠️ Scorta minima")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Fornitore Card
struct FornitoreCard: View {
    let fornitore: Fornitore
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: fornitore.categoria.icon)
                .font(.title2)
                .foregroundColor(fornitore.categoria.color)
                .frame(width: 50, height: 50)
                .background(fornitore.categoria.color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fornitore.nome)
                    .font(.headline)
                
                Text(fornitore.contatto)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text(fornitore.telefono)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(fornitore.stato.rawValue)
                    .font(.caption)
                    .foregroundColor(fornitore.stato.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(fornitore.stato.color.opacity(0.1))
                    .cornerRadius(8)
                
                Button("Contatta") {
                    // Azione contatta
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Data Models

struct InventarioItem {
    let id: Int
    let nome: String
    let quantita: Int
    let minimo: Int
    let categoria: CategoriaInventario
    let prezzo: Double
}

enum CategoriaInventario: String, CaseIterable {
    case bare = "Bare"
    case fiori = "Fiori"
    case accessori = "Accessori"
    case materiali = "Materiali"
    
    var icon: String {
        switch self {
        case .bare: return "archivebox.fill"
        case .fiori: return "leaf.fill"
        case .accessori: return "star.fill"
        case .materiali: return "cube.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bare: return .brown
        case .fiori: return .green
        case .accessori: return .purple
        case .materiali: return .gray
        }
    }
}

struct Fornitore {
    let id: Int
    let nome: String
    let categoria: CategoriaFornitore
    let contatto: String
    let telefono: String
    let email: String
    let stato: StatoFornitore
}

enum CategoriaFornitore: String, CaseIterable {
    case fiori = "Fiori"
    case bare = "Bare"
    case trasporti = "Trasporti"
    case accessori = "Accessori"
    
    var icon: String {
        switch self {
        case .fiori: return "leaf.fill"
        case .bare: return "archivebox.fill"
        case .trasporti: return "car.fill"
        case .accessori: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .fiori: return .green
        case .bare: return .brown
        case .trasporti: return .blue
        case .accessori: return .purple
        }
    }
}

enum StatoFornitore: String, CaseIterable {
    case attivo = "Attivo"
    case sospeso = "Sospeso"
    case inattivo = "Inattivo"
    
    var color: Color {
        switch self {
        case .attivo: return .green
        case .sospeso: return .orange
        case .inattivo: return .red
        }
    }
}

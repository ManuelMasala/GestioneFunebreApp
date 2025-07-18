//
//  DashboardView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 17/07/25.
//

import SwiftUI

// MARK: - Dashboard Moderna e Completa
struct DashboardView: View {
    @StateObject private var defuntiManager = ManagerGestioneDefunti()
    @State private var showingNuovoDefunto = false
    @State private var showingContabilita = false
    @State private var showingMezzi = false
    @State private var showingInventario = false
    @State private var showingFornitori = false
    @State private var selectedTimeRange: TimeRange = .settimana
    
    enum TimeRange: String, CaseIterable {
        case oggi = "Oggi"
        case settimana = "Settimana"
        case mese = "Mese"
        case anno = "Anno"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header con gradiente
                headerSection
                
                // Statistiche principali
                statsSection
                
                // Grafici e metriche
                chartsSection
                
                // Azioni rapide
                quickActionsSection
                
                // Attività recenti
                recentActivitySection
                
                // Promemoria e notifiche
                notificationsSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.controlBackgroundColor),
                    Color(NSColor.controlBackgroundColor).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingNuovoDefunto) {
            NuovoDefuntoBasicView()
                .environmentObject(defuntiManager)
        }
        .sheet(isPresented: $showingContabilita) {
            ContabilitaModernaView()
        }
        .sheet(isPresented: $showingMezzi) {
            GestioneMezziView()
        }
        .sheet(isPresented: $showingInventario) {
            InventarioModernoView()
        }
        .sheet(isPresented: $showingFornitori) {
            FornitoriModerniView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Header con gradiente
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Panoramica generale dell'attività")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Aggiornato: \(Date().formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time Range Selector
                VStack(spacing: 8) {
                    Text("Periodo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Periodo", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
            }
            .padding(.top, 20)
        }
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ModernStatCard(
                title: "Defunti Totali",
                value: "\(defuntiManager.defunti.count)",
                subtitle: "Questo mese: +\(defuntiManager.defunti.count)",
                icon: "person.3.fill",
                color: .blue,
                trend: "+12%"
            )
            
            ModernStatCard(
                title: "Cremazioni",
                value: "\(cremazioni)",
                subtitle: "47% del totale",
                icon: "flame.fill",
                color: .orange,
                trend: "+8%"
            )
            
            ModernStatCard(
                title: "Tumulazioni",
                value: "\(tumulazioni)",
                subtitle: "53% del totale",
                icon: "building.columns.fill",
                color: .green,
                trend: "-3%"
            )
            
            ModernStatCard(
                title: "Fatturato",
                value: "€45.2K",
                subtitle: "Target: €50K",
                icon: "eurosign.circle.fill",
                color: .purple,
                trend: "+15%"
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Analisi e Metriche")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Vedi Dettagli") {
                    // Azione per dettagli
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 16) {
                // Grafico andamento mensile
                VStack(alignment: .leading, spacing: 12) {
                    Text("Andamento Mensile")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Simulazione grafico
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<12) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.8), .blue.opacity(0.3)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 12, height: CGFloat.random(in: 20...80))
                        }
                    }
                    .frame(height: 80)
                    
                    Text("Trend positivo del 12%")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                
                // Distribuzione per tipo
                VStack(alignment: .leading, spacing: 12) {
                    Text("Distribuzione Servizi")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 12, height: 12)
                            Text("Cremazioni")
                                .font(.caption)
                            Spacer()
                            Text("47%")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Tumulazioni")
                                .font(.caption)
                            Spacer()
                            Text("53%")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Barra di progresso
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(height: 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(height: 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .cornerRadius(4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Azioni Rapide")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // Riga 1
                QuickActionButton(
                    title: "Nuovo Defunto",
                    description: "Registra un nuovo defunto",
                    icon: "person.badge.plus",
                    color: .blue,
                    gradient: [.blue, .cyan]
                ) {
                    showingNuovoDefunto = true
                }
                
                QuickActionButton(
                    title: "Contabilità",
                    description: "Gestisci fatture e pagamenti",
                    icon: "creditcard.fill",
                    color: .green,
                    gradient: [.green, .mint]
                ) {
                    showingContabilita = true
                }
                
                QuickActionButton(
                    title: "Gestione Mezzi",
                    description: "Veicoli e attrezzature",
                    icon: "car.2.fill",
                    color: .orange,
                    gradient: [.orange, .yellow]
                ) {
                    showingMezzi = true
                }
                
                // Riga 2
                QuickActionButton(
                    title: "Inventario",
                    description: "Magazzino e scorte",
                    icon: "archivebox.fill",
                    color: .purple,
                    gradient: [.purple, .pink]
                ) {
                    showingInventario = true
                }
                
                QuickActionButton(
                    title: "Fornitori",
                    description: "Gestisci i fornitori",
                    icon: "building.2.fill",
                    color: .indigo,
                    gradient: [.indigo, .blue]
                ) {
                    showingFornitori = true
                }
                
                QuickActionButton(
                    title: "Rapporti",
                    description: "Stampa e esporta",
                    icon: "doc.text.fill",
                    color: .teal,
                    gradient: [.teal, .cyan]
                ) {
                    // Azione rapporti
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Attività Recenti")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Vedi Tutto") {
                    // Azione per vedere tutto
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                ForEach(recentActivities, id: \.id) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }
    
    private var notificationsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Promemoria e Notifiche")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Gestisci") {
                    // Azione per gestire notifiche
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                NotificationCard(
                    title: "Scadenza Documenti",
                    message: "3 certificati in scadenza questa settimana",
                    type: .warning,
                    action: "Verifica"
                )
                
                NotificationCard(
                    title: "Manutenzione Veicoli",
                    message: "Revisione auto funebre prevista per domani",
                    type: .info,
                    action: "Pianifica"
                )
                
                NotificationCard(
                    title: "Pagamenti in Sospeso",
                    message: "2 fatture da incassare entro fine mese",
                    type: .error,
                    action: "Sollecita"
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var cremazioni: Int {
        defuntiManager.defunti.filter { $0.tipoSepoltura == .cremazione }.count
    }
    
    private var tumulazioni: Int {
        defuntiManager.defunti.filter { $0.tipoSepoltura == .tumulazione }.count
    }
    
    private var recentActivities: [Activity] {
        [
            Activity(id: 1, type: .nuovo, title: "Nuovo defunto registrato", description: "Mario Rossi - Cartella 0045", time: "2 ore fa", icon: "person.badge.plus"),
            Activity(id: 2, type: .pagamento, title: "Pagamento ricevuto", description: "Fattura #2024-156 - €2.450", time: "4 ore fa", icon: "creditcard.fill"),
            Activity(id: 3, type: .servizio, title: "Servizio completato", description: "Cremazione - Giuseppe Verdi", time: "1 giorno fa", icon: "flame.fill"),
            Activity(id: 4, type: .manutenzione, title: "Manutenzione veicolo", description: "Auto funebre - Tagliando", time: "2 giorni fa", icon: "car.fill")
        ]
    }
}

// MARK: - Modern Stat Card
struct ModernStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(trend.contains("+") ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend.contains("+") ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.type.color)
                .frame(width: 40, height: 40)
                .background(activity.type.color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Notification Card
struct NotificationCard: View {
    let title: String
    let message: String
    let type: NotificationType
    let action: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(type.color)
                .frame(width: 40, height: 40)
                .background(type.color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action) {
                // Azione
            }
            .font(.caption)
            .foregroundColor(type.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(type.color.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Types
struct Activity {
    let id: Int
    let type: ActivityType
    let title: String
    let description: String
    let time: String
    let icon: String
}

enum ActivityType {
    case nuovo, pagamento, servizio, manutenzione
    
    var color: Color {
        switch self {
        case .nuovo: return .blue
        case .pagamento: return .green
        case .servizio: return .orange
        case .manutenzione: return .purple
        }
    }
}

enum NotificationType {
    case warning, info, error
    
    var color: Color {
        switch self {
        case .warning: return .orange
        case .info: return .blue
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

#Preview {
    DashboardView()
}

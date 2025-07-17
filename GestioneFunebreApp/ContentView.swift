//
//  ContentView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 07/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // App principale
                MainAppView()
                    .environmentObject(authManager)
            } else {
                // Schermata di login
                AccessoOperatoreView()
                    .environmentObject(authManager)
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedSection: AppSection = .dashboard
    
    enum AppSection: String, CaseIterable {
        case dashboard = "Dashboard"
        case defunti = "Defunti"
        // Rimuoviamo mezzi per ora
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .defunti: return "person.3.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .dashboard: return .blue
            case .defunti: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("Gestione Funebre")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Operatore: \(authManager.currentUser?.username ?? "Demo")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .background(Color.blue.opacity(0.1))
                
                // Menu
                VStack(spacing: 8) {
                    ForEach(AppSection.allCases, id: \.self) { section in
                        Button(action: {
                            selectedSection = section
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: section.icon)
                                    .font(.title3)
                                    .foregroundColor(selectedSection == section ? .white : section.color)
                                    .frame(width: 24)
                                
                                Text(section.rawValue)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedSection == section ? .white : .primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                selectedSection == section ?
                                section.color : Color.clear
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 20)
                
                Spacer()
                
                // Logout button
                Button("Logout") {
                    authManager.logout()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
            .frame(width: 250)
            .background(Color(NSColor.controlBackgroundColor))
        } detail: {
            // Main content
            Group {
                switch selectedSection {
                case .dashboard:
                    DashboardView()
                case .defunti:
                    GestioneDefuntiView()
                }
            }
        }
    }
}

// MARK: - Dashboard Semplice
struct DashboardView: View {
    @StateObject private var defuntiManager = ManagerGestioneDefunti()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Panoramica generale dell'attività")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Stats Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatsCard(
                        title: "Defunti Totali",
                        value: "\(defuntiManager.defunti.count)",
                        icon: "person.3.fill",
                        color: .purple
                    )
                    
                    StatsCard(
                        title: "Cremazioni",
                        value: "\(cremazioni)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    StatsCard(
                        title: "Tumulazioni",
                        value: "\(tumulazioni)",
                        icon: "building.columns.fill",
                        color: .blue
                    )
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Azioni Rapide")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        QuickActionCard(
                            title: "Nuovo Defunto",
                            description: "Registra un nuovo defunto",
                            icon: "person.badge.plus",
                            color: .blue
                        ) {
                            // Azione nuovo defunto
                        }
                        
                        QuickActionCard(
                            title: "Cerca Defunti",
                            description: "Cerca tra i defunti registrati",
                            icon: "magnifyingglass",
                            color: .green
                        ) {
                            // Azione ricerca
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var cremazioni: Int {
        defuntiManager.defunti.filter { $0.tipoSepoltura == .cremazione }.count
    }
    
    private var tumulazioni: Int {
        defuntiManager.defunti.filter { $0.tipoSepoltura == .tumulazione }.count
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .frame(height: 120)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}

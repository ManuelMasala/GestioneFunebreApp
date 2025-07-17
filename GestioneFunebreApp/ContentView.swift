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
        case contabilita = "Contabilità"
        case mezzi = "Mezzi"
        case inventario = "Inventario"
        case fornitori = "Fornitori"
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .defunti: return "person.3.fill"
            case .contabilita: return "creditcard.fill"
            case .mezzi: return "car.2.fill"
            case .inventario: return "archivebox.fill"
            case .fornitori: return "building.2.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .dashboard: return .blue
            case .defunti: return .purple
            case .contabilita: return .green
            case .mezzi: return .orange
            case .inventario: return .indigo
            case .fornitori: return .teal
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .dashboard: return [.blue, .cyan]
            case .defunti: return [.purple, .pink]
            case .contabilita: return [.green, .mint]
            case .mezzi: return [.orange, .yellow]
            case .inventario: return [.indigo, .purple]
            case .fornitori: return [.teal, .blue]
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar moderna
            VStack(spacing: 0) {
                // Header con gradiente
                VStack(spacing: 16) {
                    // Logo con gradiente
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 4) {
                        Text("Gestione Funebre")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Sistema Integrato")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // User info con badge
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authManager.currentUser?.username ?? "Admin")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text("Operatore")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        colors: [Color(NSColor.controlBackgroundColor), Color.gray.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Menu con animazioni
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(AppSection.allCases, id: \.self) { section in
                            ModernSidebarButton(
                                section: section,
                                isSelected: selectedSection == section
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedSection = section
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Logout button con stile moderno
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authManager.logout()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.title3)
                        
                        Text("Logout")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 280)
            .background(Color(NSColor.controlBackgroundColor))
        } detail: {
            // Main content con transizioni
            Group {
                switch selectedSection {
                case .dashboard:
                    DashboardView()
                case .defunti:
                    GestioneDefuntiView()
                case .contabilita:
                    ContabilitaModernaView()
                case .mezzi:
                    MezziModerniView()
                case .inventario:
                    InventarioModernoView()
                case .fornitori:
                    FornitoriModerniView()
                }
            }
            .transition(.opacity.combined(with: .slide))
            .animation(.easeInOut(duration: 0.3), value: selectedSection)
        }
    }
}

// MARK: - Modern Sidebar Button
struct ModernSidebarButton: View {
    let section: MainAppView.AppSection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon con gradiente
                Image(systemName: section.icon)
                    .font(.title3)
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: section.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                
                // Text
                Text(section.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                // Indicator
                if isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: section.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color.clear, Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(
                color: isSelected ? section.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ContentView()
}

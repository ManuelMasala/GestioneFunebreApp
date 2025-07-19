//
//  DashboardManager.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 16/07/25.
//

import SwiftUI
import Foundation

// MARK: - Dashboard Manager
class DashboardManager: ObservableObject {
    @Published var defuntiCount: Int = 0
    @Published var mezziDisponibili: Int = 0
    @Published var mezziInManutenzione: Int = 0
    @Published var fatturato: String = "0"
    @Published var materialiTotali: Int = 0
    @Published var materialiBassa: Int = 0
    @Published var fattureInsolute: Int = 0
    @Published var unreadNotifications: Int = 0
    @Published var recentActivities: [DashboardActivity] = []
    @Published var alerts: [DashboardAlert] = []
    
    init() {
        loadDashboardData()
    }
    
    private func loadDashboardData() {
        // Simulazione dati - da sostituire con dati reali
        defuntiCount = 45
        mezziDisponibili = 8
        mezziInManutenzione = 2
        fatturato = "125,340"
        materialiTotali = 156
        materialiBassa = 3
        fattureInsolute = 2
        unreadNotifications = 5
        
        // Carica attività recenti
        recentActivities = [
            DashboardActivity(
                id: 1,
                title: "Nuovo defunto registrato",
                subtitle: "Mario Rossi - Cartella #2024-156",
                timeAgo: "2 ore fa",
                color: AppDesign.Colors.defunto
            ),
            DashboardActivity(
                id: 2,
                title: "Manutenzione completata",
                subtitle: "Mercedes GY840MC - Tagliando",
                timeAgo: "5 ore fa",
                color: AppDesign.Colors.mezzi
            ),
            DashboardActivity(
                id: 3,
                title: "Fattura pagata",
                subtitle: "Ar Service - €2,150",
                timeAgo: "1 giorno fa",
                color: AppDesign.Colors.contabilita
            ),
            DashboardActivity(
                id: 4,
                title: "Materiale in esaurimento",
                subtitle: "Maniglie bronzo - 5 pezzi rimasti",
                timeAgo: "2 giorni fa",
                color: AppDesign.Colors.inventario
            ),
            DashboardActivity(
                id: 5,
                title: "Nuovo fornitore aggiunto",
                subtitle: "Fiori & Decorazioni srl",
                timeAgo: "3 giorni fa",
                color: AppDesign.Colors.success
            )
        ]
        
        // Carica avvisi
        alerts = [
            DashboardAlert(
                id: 1,
                title: "Revisione in scadenza",
                message: "Jaguar FY559DJ - Revisione scade il 25/07/2025",
                icon: "exclamationmark.triangle.fill",
                severity: .warning,
                timeLeft: "9 giorni"
            ),
            DashboardAlert(
                id: 2,
                title: "Materiale in esaurimento",
                message: "Maniglie bronzo - Solo 5 pezzi rimasti",
                icon: "exclamationmark.circle.fill",
                severity: .error,
                timeLeft: "Critico"
            ),
            DashboardAlert(
                id: 3,
                title: "Fattura in scadenza",
                message: "Coraddu - Fattura #2024-089 scade domani",
                icon: "clock.fill",
                severity: .warning,
                timeLeft: "1 giorno"
            ),
            DashboardAlert(
                id: 4,
                title: "Bollo auto",
                message: "Mercedes GV589TV - Bollo scade il 31/07/2025",
                icon: "doc.text.fill",
                severity: .info,
                timeLeft: "15 giorni"
            )
        ]
    }
    
    func refreshData() {
        loadDashboardData()
    }
    
    func markNotificationAsRead() {
        if unreadNotifications > 0 {
            unreadNotifications -= 1
        }
    }
}

// MARK: - Dashboard Activity Model
struct DashboardActivity: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let timeAgo: String
    let color: Color
}

// MARK: - Dashboard Alert Model
struct DashboardAlert: Identifiable {
    let id: Int
    let title: String
    let message: String
    let icon: String
    let severity: AlertSeverity
    let timeLeft: String
    
    enum AlertSeverity {
        case info, warning, error
        
        var color: Color {
            switch self {
            case .info: return AppDesign.Colors.info
            case .warning: return AppDesign.Colors.warning
            case .error: return AppDesign.Colors.error
            }
        }
    }
}

// MARK: - Extensions per compatibilità
extension DashboardAlert {
    var severityColor: Color {
        return severity.color
    }
}

extension DashboardActivity {
    var activityColor: Color {
        return color
    }
}

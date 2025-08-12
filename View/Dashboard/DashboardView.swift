//
//  DashboardView.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 24/07/25.
//

import SwiftUI

// MARK: - ⭐ Dashboard Integrata - Versione Finale Corretta

struct DashboardView: View {
    @StateObject private var defuntiManager = ManagerGestioneDefunti()
    @StateObject private var dashboardManager = DashboardManager()
    @StateObject private var documentiManager = DocumentiManager()
    @StateObject private var adobeManager = AdobePDFManager.shared
    
    @State private var showingNuovoDefunto = false
    @State private var showingDocumenti = false
    @State private var showingAdobeImport = false
    @State private var selectedTimeRange: DashboardTimeRange = .settimana
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Statistiche principali
                statsSection
                
                // Adobe Integration Panel
                adobeSection
                
                // Azioni rapide
                quickActionsSection
                
                // Attività recenti
                recentActivitySection
                
                // Notifiche
                notificationsSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            setupDashboard()
        }
        .refreshable {
            refreshAllData()
        }
        .sheet(isPresented: $showingNuovoDefunto) {
            NuovoDefuntoBasicView()
                .environmentObject(defuntiManager)
        }
        .sheet(isPresented: $showingDocumenti) {
            TemplateManagerView()
                .environmentObject(documentiManager)
        }
        .sheet(isPresented: $showingAdobeImport) {
            AdobeImportView()
                .environmentObject(documentiManager)
        }
    }
    
    // MARK: - Setup
    
    private func setupDashboard() {
        dashboardManager.connectDefuntiManager(defuntiManager)
        dashboardManager.connectDocumentiManager(documentiManager)
        dashboardManager.refreshData()
    }
    
    private func refreshAllData() {
        dashboardManager.refreshData()
        documentiManager.ricaricaDocumenti()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Panoramica generale dell'attività")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        Text("Aggiornato: \(Date().formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(adobeManager.isProcessing ? .orange : .green)
                                .frame(width: 8, height: 8)
                            Text("Adobe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Picker("Periodo", selection: $selectedTimeRange) {
                        ForEach(DashboardTimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 240)
                    
                    HStack(spacing: 8) {
                        Button("📄 Import Adobe") {
                            showingAdobeImport = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        
                        Button("📊 Documenti") {
                            showingDocumenti = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                }
            }
            .frame(minHeight: 120)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        let stats = dashboardManager.getStatsForPeriod(selectedTimeRange)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
            RealStatCard(
                title: "Defunti",
                value: "\(dashboardManager.defuntiCount)",
                subtitle: "Periodo: +\(stats.defunti)",
                icon: "person.3.fill",
                color: .blue,
                trend: stats.trendFormatted
            )
            
            RealStatCard(
                title: "Mezzi",
                value: "\(dashboardManager.mezziDisponibili)",
                subtitle: "Manutenzione: \(dashboardManager.mezziInManutenzione)",
                icon: "car.2.fill",
                color: .orange,
                trend: "+5%"
            )
            
            let adobeTemplatesCount = documentiManager.templates.filter { $0.operatoreCreazione.contains("Adobe") }.count
            RealStatCard(
                title: "Documenti",
                value: "\(documentiManager.documentiCompilati.count)",
                subtitle: "Adobe: \(adobeTemplatesCount)",
                icon: "doc.fill",
                color: .green,
                trend: "+\(stats.documenti)"
            )
            
            RealStatCard(
                title: "Fatturato",
                value: "€\(dashboardManager.fatturato)",
                subtitle: stats.fatturatoFormatted,
                icon: "eurosign.circle.fill",
                color: .purple,
                trend: stats.trendFormatted
            )
        }
    }
    
    // MARK: - Adobe Section
    
    private var adobeSection: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "doc.badge.gearshape")
                        .foregroundColor(.red)
                    Text("Adobe PDF Services")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if adobeManager.isProcessing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(adobeManager.currentTask)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        AdobeStatView(
                            title: "Operazioni Oggi",
                            value: "\(adobeManager.todayOperations)",
                            color: .red
                        )
                        
                        AdobeStatView(
                            title: "Success Rate",
                            value: "\(Int(adobeManager.successRate * 100))%",
                            color: .green
                        )
                        
                        let templatesCount = documentiManager.templates.filter { $0.operatoreCreazione.contains("Adobe") }.count
                        AdobeStatView(
                            title: "Templates Adobe",
                            value: "\(templatesCount)",
                            color: .blue
                        )
                    }
                    
                    if adobeManager.isProcessing {
                        ProgressView(value: adobeManager.progress)
                            .tint(.red)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    AdobeActionButton(
                        title: "Import Template",
                        icon: "square.and.arrow.down",
                        color: .red
                    ) {
                        performAdobeImport()
                    }
                    
                    AdobeActionButton(
                        title: "Analizza Documenti",
                        icon: "magnifyingglass",
                        color: .purple
                    ) {
                        performBulkAnalysis()
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Azioni Rapide")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                QuickActionCard(
                    title: "Nuovo Defunto",
                    description: "Registra un nuovo defunto",
                    icon: "person.badge.plus",
                    color: .blue
                ) {
                    showingNuovoDefunto = true
                }
                
                QuickActionCard(
                    title: "Gestione Documenti",
                    description: "Crea e gestisci documenti",
                    icon: "doc.text.fill",
                    color: .green
                ) {
                    showingDocumenti = true
                }
                
                QuickActionCard(
                    title: "Import Adobe",
                    description: "Importa con OCR Adobe",
                    icon: "square.and.arrow.down.fill",
                    color: .red
                ) {
                    showingAdobeImport = true
                }
            }
        }
    }
    
    // MARK: - Recent Activity
    
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Attività Recenti")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Vedi Tutto") {
                    showingDocumenti = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                if dashboardManager.recentActivities.isEmpty {
                    Text("Nessuna attività recente")
                        .foregroundColor(.secondary)
                        .frame(height: 100)
                } else {
                    ForEach(dashboardManager.recentActivities.prefix(5)) { activity in
                        RealActivityRow(activity: activity)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Notifications
    
    private var notificationsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Promemoria e Notifiche")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if dashboardManager.unreadNotifications > 0 {
                    Text("\(dashboardManager.unreadNotifications)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(.red)
                        .cornerRadius(10)
                }
            }
            
            VStack(spacing: 12) {
                if dashboardManager.alerts.isEmpty {
                    Text("Nessun avviso attivo")
                        .foregroundColor(.secondary)
                        .frame(height: 80)
                } else {
                    ForEach(dashboardManager.alerts.prefix(4)) { alert in
                        RealAlertCard(alert: alert) {
                            dashboardManager.dismissAlert(alert.id)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Adobe Actions
    
    private func performAdobeImport() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf, .image]
        panel.title = "Seleziona file per Import Adobe"
        panel.allowsMultipleSelection = true
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                Task {
                    do {
                        let template = try await documentiManager.importaTemplateConAdobe(da: url)
                        
                        await MainActor.run {
                            print("✅ Template Adobe importato: \(template.nome)")
                            
                            // Forza refresh dei manager
                            documentiManager.forzaRefreshTemplates()
                            dashboardManager.refreshData()
                            
                            // Debug per verificare
                            documentiManager.debugTemplates()
                        }
                    } catch {
                        print("❌ Errore import Adobe: \(error)")
                    }
                }
            }
        }
    }
    
    private func performBulkAnalysis() {
        Task {
            for template in documentiManager.templates.prefix(5) {
                do {
                    let _ = try await documentiManager.analizzaTemplate(template)
                } catch {
                    print("❌ Errore analisi: \(error)")
                }
            }
            
            await MainActor.run {
                dashboardManager.refreshData()
            }
        }
    }
}

// MARK: - ⭐ Componenti

struct RealStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(trend.contains("+") ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend.contains("+") ? Color.green : Color.red).opacity(0.15))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 6) {
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
        .padding(16)
        .frame(height: 160)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AdobeStatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

struct AdobeActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(AdobePDFManager.shared.isProcessing)
    }
}

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
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .frame(height: 180)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RealActivityRow: View {
    let activity: DashboardActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(activity.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .fill(activity.color.opacity(0.3))
                        .frame(width: 12, height: 12)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct RealAlertCard: View {
    let alert: DashboardAlert
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.icon)
                .font(.title3)
                .foregroundColor(alert.severity.color)
                .frame(width: 40, height: 40)
                .background(alert.severity.color.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(alert.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(alert.timeLeft)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(alert.severity.color)
                
                Button("×") {
                    onDismiss()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(alert.severity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - ⭐ Adobe Import View

struct AdobeImportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var documentiManager: DocumentiManager
    @StateObject private var adobeManager = AdobePDFManager.shared
    
    @State private var selectedFiles: [URL] = []
    @State private var importResults: [ImportResult] = []
    
    struct ImportResult: Identifiable {
        let id = UUID()
        let fileName: String
        let status: ImportStatus
        let template: DocumentoTemplate?
        
        enum ImportStatus {
            case processing, success, failed(String)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.badge.gearshape")
                        .font(.title)
                        .foregroundColor(.red)
                    
                    Text("Import Adobe")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Text("Importa documenti utilizzando Adobe OCR")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // File Selection
            VStack(spacing: 16) {
                Button("Seleziona File") {
                    selectFiles()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if !selectedFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File selezionati:")
                            .font(.headline)
                        
                        ForEach(selectedFiles, id: \.self) { url in
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(.blue)
                                Text(url.lastPathComponent)
                                    .font(.caption)
                                Spacer()
                                Button("×") {
                                    selectedFiles.removeAll { $0 == url }
                                }
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
                    }
                }
                
                if !selectedFiles.isEmpty {
                    Button("Avvia Import") {
                        startImport()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(adobeManager.isProcessing)
                }
            }
            
            // Results
            if !importResults.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risultati Import:")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(importResults) { result in
                                ImportResultRow(result: result)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Close Button
            Button("Chiudi") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .frame(minWidth: 600, minHeight: 500)
    }
    
    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf, .image]
        panel.allowsMultipleSelection = true
        panel.title = "Seleziona file per Import Adobe"
        
        if panel.runModal() == .OK {
            selectedFiles = panel.urls
        }
    }
    
    private func startImport() {
        importResults = selectedFiles.map { url in
            ImportResult(fileName: url.lastPathComponent, status: .processing, template: nil)
        }
        
        for (index, url) in selectedFiles.enumerated() {
            Task {
                do {
                    let template = try await documentiManager.importaTemplateConAdobe(da: url)
                    
                    await MainActor.run {
                        importResults[index] = ImportResult(
                            fileName: url.lastPathComponent,
                            status: .success,
                            template: template
                        )
                        
                        print("✅ Template Adobe creato: \(template.nome)")
                        
                        // Forza refresh per assicurare che il template sia visibile
                        documentiManager.forzaRefreshTemplates()
                        documentiManager.debugTemplates()
                    }
                } catch {
                    await MainActor.run {
                        importResults[index] = ImportResult(
                            fileName: url.lastPathComponent,
                            status: .failed(error.localizedDescription),
                            template: nil
                        )
                        
                        print("❌ Errore import: \(error)")
                    }
                }
            }
        }
    }
}

struct ImportResultRow: View {
    let result: AdobeImportView.ImportResult
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.fileName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if case .processing = result.status {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch result.status {
        case .processing: return "clock"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch result.status {
        case .processing: return .orange
        case .success: return .green
        case .failed: return .red
        }
    }
    
    private var statusText: String {
        switch result.status {
        case .processing: return "Elaborazione in corso..."
        case .success: return "Template creato con successo"
        case .failed(let error): return "Errore: \(error)"
        }
    }
}

#Preview {
    DashboardView()
}

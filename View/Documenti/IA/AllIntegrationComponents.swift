//
//  AllIntegrationComponents.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 20/07/25.
//

import SwiftUI

// MARK: - AI Integration Components - VERSIONE BASE

struct AIQuickActions: View {
    let onScanDocument: () -> Void
    let onAutoFill: () -> Void
    let onSmartSuggest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button("📄 Scansiona") {
                onScanDocument()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(8)
            
            Button("🧠 Auto-Fill") {
                onAutoFill()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.2))
            .foregroundColor(.purple)
            .cornerRadius(8)
            
            Button("💡 Suggerisci") {
                onSmartSuggest()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(8)
        }
    }
}

struct AIIntegrationButton: View {
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "brain.head.profile")
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AIStatusIndicator: View {
    let isProcessing: Bool
    let confidence: Double?
    
    var body: some View {
        HStack(spacing: 6) {
            if isProcessing {
                ProgressView()
                    .scaleEffect(0.6)
                Text("AI Processing...")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else if let confidence = confidence {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("AI: \(Int(confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.gray)
                Text("AI Ready")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Extensions
extension View {
    func withFloatingAI() -> some View {
        self.overlay(
            FloatingAIButton(),
            alignment: .bottomTrailing
        )
    }
}

struct FloatingAIButton: View {
    @State private var showingUpload = false
    
    var body: some View {
        Button(action: { showingUpload = true }) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.purple)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .padding(20)
        .sheet(isPresented: $showingUpload) {
            AIDocumentUploadView { data in
                print("Dati AI ricevuti: \(data)")
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AIQuickActions(
            onScanDocument: { print("Scan") },
            onAutoFill: { print("Auto-fill") },
            onSmartSuggest: { print("Suggest") }
        )
        
        AIIntegrationButton(title: "AI Assistant") {
            print("AI tapped")
        }
        
        AIStatusIndicator(isProcessing: false, confidence: 0.85)
    }
    .padding()
}

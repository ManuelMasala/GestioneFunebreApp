//
//  AccessoOperatoreView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 07/07/25.
//

import SwiftUI

struct AccessoOperatoreView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 24) {
                // Logo e titolo
                VStack(spacing: 16) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Gestione Funebre")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Sistema di gestione per imprese funebri")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Form di login
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Accesso Operatore")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Username")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Inserisci username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 40)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            SecureField("Inserisci password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 40)
                        }
                    }
                    
                    // Pulsante di login
                    Button(action: {
                        performLogin()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(isLoading ? "Accesso in corso..." : "Accedi")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(loginButtonColor)
                        .cornerRadius(8)
                    }
                    .disabled(isLoading || username.isEmpty || password.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(24)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .frame(maxWidth: 400)
            
            Spacer()
            
            // Footer
            VStack(spacing: 8) {
                Text("Versione 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("© 2024 Gestione Funebre. Tutti i diritti riservati.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .alert("Errore di accesso", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onSubmit {
            if !username.isEmpty && !password.isEmpty {
                performLogin()
            }
        }
    }
    
    private var loginButtonColor: Color {
        if isLoading || username.isEmpty || password.isEmpty {
            return Color.gray.opacity(0.5)
        } else {
            return Color.blue
        }
    }
    
    private func performLogin() {
        guard !username.isEmpty && !password.isEmpty else { return }
        
        // Login semplificato senza creare User direttamente
        if username == "admin" && password == "admin" {
            // Login riuscito - lascia che AuthManager gestisca tutto
            authManager.isAuthenticated = true
        } else {
            // Login fallito
            authManager.isAuthenticated = false
            alertMessage = "Credenziali non valide. Usa admin/admin"
            showingAlert = true
            password = ""
        }
    }
}

// MARK: - Preview
#Preview {
    AccessoOperatoreView()
        .environmentObject(AuthManager.shared)
}

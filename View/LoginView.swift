//
//  LoginView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 07/07/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showingForgotPassword = false
    @State private var resetEmail = ""
    @State private var showingResetSuccess = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Login form
                VStack(spacing: 0) {
                    Spacer()
                    
                    loginForm
                        .frame(maxWidth: 400)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(AppDesign.Colors.background)
                
                // Right side - Branding
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo/Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        Text("Gestione Funebre")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Sistema integrato per la gestione completa dell'agenzia funebre")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Company info
                    VStack(spacing: 8) {
                        Text("Agenzia Funebre Paradiso")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Via Palabanda n. 21 - 09123 Cagliari")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [AppDesign.Colors.primary, AppDesign.Colors.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Carica username salvato se presente
            if let savedUsername = authManager.getRememberedUsername() {
                username = savedUsername
                rememberMe = true
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            forgotPasswordSheet
        }
        .alert("Reset Password", isPresented: $showingResetSuccess) {
            Button("OK") { }
        } message: {
            Text("Se l'email esiste nel sistema, riceverai le istruzioni per reimpostare la password.")
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Accesso")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppDesign.Colors.textPrimary)
                
                Text("Inserisci le tue credenziali per accedere")
                    .font(.system(size: 14))
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }
            
            // Form fields
            VStack(spacing: 16) {
                // Username field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    TextField("Inserisci username", text: $username)
                        .textFieldStyle(ModernTextFieldStyle())
                        .onSubmit {
                            if !password.isEmpty {
                                Task { await performLogin() }
                            }
                        }
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    SecureField("Inserisci password", text: $password)
                        .textFieldStyle(ModernTextFieldStyle())
                        .onSubmit {
                            if !username.isEmpty {
                                Task { await performLogin() }
                            }
                        }
                }
            }
            
            // Remember me & Forgot password
            HStack {
                Toggle("Ricordami", isOn: $rememberMe)
                    .font(.system(size: 14))
                    .foregroundColor(AppDesign.Colors.textSecondary)
                
                Spacer()
                
                Button("Password dimenticata?") {
                    showingForgotPassword = true
                }
                .font(.system(size: 14))
                .foregroundColor(AppDesign.Colors.accent)
            }
            
            // Error message
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(AppDesign.Colors.error)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppDesign.Colors.error.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Login button
            Button(action: {
                Task { await performLogin() }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    
                    Text(authManager.isLoading ? "Accesso in corso..." : "Accedi")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [AppDesign.Colors.primary, AppDesign.Colors.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: AppDesign.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(authManager.isLoading || username.isEmpty || password.isEmpty)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var forgotPasswordSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 40))
                        .foregroundColor(AppDesign.Colors.primary)
                    
                    Text("Recupera Password")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    Text("Inserisci la tua email per ricevere le istruzioni di reset")
                        .font(.system(size: 14))
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppDesign.Colors.textPrimary)
                    
                    TextField("inserisci@email.com", text: $resetEmail)
                        .textFieldStyle(ModernTextFieldStyle())
                        .autocorrectionDisabled()
                }
                
                Button(action: {
                    Task { await performPasswordReset() }
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        
                        Text(authManager.isLoading ? "Invio in corso..." : "Invia Reset")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppDesign.Colors.primary)
                    .cornerRadius(12)
                }
                .disabled(authManager.isLoading || resetEmail.isEmpty)
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationTitle("Recupera Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        showingForgotPassword = false
                        resetEmail = ""
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    private func performLogin() async {
        let result = await authManager.login(username: username, password: password, rememberMe: rememberMe)
        
        switch result {
        case .success:
            // Login successful, ContentView will handle the navigation
            break
        case .failure:
            // Error message is already set in AuthManager
            break
        }
    }
    
    private func performPasswordReset() async {
        let success = await authManager.requestPasswordReset(email: resetEmail)
        
        if success {
            showingForgotPassword = false
            showingResetSuccess = true
            resetEmail = ""
        }
    }
}

// MARK: - Custom TextField Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppDesign.Colors.surfaceSecondary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppDesign.Colors.primary.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}

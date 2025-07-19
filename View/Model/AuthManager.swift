//
//  AuthManager.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 08/07/25.
//

import SwiftUI
import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id = UUID()
    var username: String
    var fullName: String
    var role: UserRole
    var dateCreated: Date
    var lastLogin: Date?
    var email: String = ""
    
    var initials: String {
        let names = fullName.split(separator: " ")
        return names.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
    }
    
    enum UserRole: String, CaseIterable, Codable {
        case admin = "Amministratore"
        case operatore = "Operatore"
        case viewer = "Visualizzatore"
        
        var permissions: [Permission] {
            switch self {
            case .admin:
                return Permission.allCases
            case .operatore:
                return [.read, .write, .generateDocuments, .manageVehicles, .manageDeceased]
            case .viewer:
                return [.read, .viewReports]
            }
        }
        
        var color: Color {
            switch self {
            case .admin: return .red
            case .operatore: return .blue
            case .viewer: return .green
            }
        }
    }
    
    enum Permission: String, CaseIterable, Codable {
        case read = "Lettura"
        case write = "Scrittura"
        case delete = "Eliminazione"
        case generateDocuments = "Generazione Documenti"
        case manageUsers = "Gestione Utenti"
        case manageTemplates = "Gestione Template"
        case backup = "Backup e Ripristino"
        case export = "Esportazione Dati"
        case manageVehicles = "Gestione Mezzi"
        case manageDeceased = "Gestione Defunti"
        case manageAccounting = "Contabilità"
        case viewReports = "Visualizza Report"
        case manageSettings = "Impostazioni"
    }
}

// MARK: - Auth Error
enum AuthError: Error {
    case invalidCredentials
    case networkError
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Username o password non validi"
        case .networkError:
            return "Errore di connessione"
        case .unknownError:
            return "Errore sconosciuto"
        }
    }
}

// MARK: - Authentication Manager
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // Versione aggiornata della funzione login per compatibilità con LoginView
    func login(username: String, password: String, rememberMe: Bool = false) async -> Result<User, AuthError> {
        isLoading = true
        errorMessage = nil
        
        // Simula delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if !username.isEmpty && !password.isEmpty {
            let user = User(
                username: username,
                fullName: username.capitalized,
                role: .admin,
                dateCreated: Date(),
                lastLogin: Date()
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            // Simula logica rememberMe (potresti salvare in UserDefaults)
            if rememberMe {
                // Salva credenziali per ricordare l'utente
                UserDefaults.standard.set(username, forKey: "remembered_username")
            }
            
            return .success(user)
        } else {
            errorMessage = "Username e password obbligatori"
            isLoading = false
            return .failure(.invalidCredentials)
        }
    }
    
    // Funzione per il reset della password
    func requestPasswordReset(email: String) async -> Bool {
        isLoading = true
        
        // Simula chiamata API per reset password
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isLoading = false
        
        // Simula successo se l'email non è vuota
        return !email.isEmpty
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
        
        // Rimuovi credenziali salvate
        UserDefaults.standard.removeObject(forKey: "remembered_username")
    }
    
    func hasPermission(_ permission: User.Permission) -> Bool {
        return currentUser?.role.permissions.contains(permission) ?? false
    }
    
    var userDisplayName: String {
        return currentUser?.fullName ?? "Utente"
    }
    
    var userRole: String {
        return currentUser?.role.rawValue ?? "Nessun Ruolo"
    }
    
    // Funzione per recuperare username salvato
    func getRememberedUsername() -> String? {
        return UserDefaults.standard.string(forKey: "remembered_username")
    }
}

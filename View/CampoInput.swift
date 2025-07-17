//
//  CampoInput.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 08/07/25.
//

import SwiftUI

// MARK: - CampoInput
struct CampoInput: View {
    let titolo: String
    @Binding var testo: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titolo)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $testo)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                #endif
        }
        .padding(.vertical, 5)
    }
}

// MARK: - CampoSecureInput
struct CampoSecureInput: View {
    let titolo: String
    @Binding var testo: String
    let placeholder: String
    @State private var mostraPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(titolo)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                if mostraPassword {
                    TextField(placeholder, text: $testo)
                        #if os(iOS)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        #endif
                } else {
                    SecureField(placeholder, text: $testo)
                }
                
                Button(action: {
                    mostraPassword.toggle()
                }) {
                    Image(systemName: mostraPassword ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}

// MARK: - PasswordStrengthView
struct PasswordStrengthView: View {
    let password: String
    
    private var strength: PasswordStrength {
        if password.isEmpty {
            return .empty
        } else if password.count < 6 {
            return .weak
        } else if password.count < 8 {
            return .medium
        } else if password.count >= 8 && password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            return .strong
        } else {
            return .medium
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Forza Password")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(colorForStrength(at: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            Text(strength.description)
                .font(.caption)
                .foregroundColor(strength.color)
        }
    }
    
    private func colorForStrength(at index: Int) -> Color {
        switch strength {
        case .empty:
            return .gray.opacity(0.3)
        case .weak:
            return index == 0 ? .red : .gray.opacity(0.3)
        case .medium:
            return index <= 1 ? .orange : .gray.opacity(0.3)
        case .strong:
            return index <= 2 ? .green : .gray.opacity(0.3)
        }
    }
}

enum PasswordStrength {
    case empty, weak, medium, strong
    
    var description: String {
        switch self {
        case .empty: return ""
        case .weak: return "Debole"
        case .medium: return "Media"
        case .strong: return "Forte"
        }
    }
    
    var color: Color {
        switch self {
        case .empty: return .clear
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
}

// MARK: - RiepilogoUtenteView
struct RiepilogoUtenteView: View {
    let utente: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Riepilogo Utente")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text(utente)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Operatore del Sistema")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    VStack {
        CampoInput(titolo: "Email", testo: .constant(""), placeholder: "Inserisci email")
        CampoSecureInput(titolo: "Password", testo: .constant(""), placeholder: "Inserisci password")
        PasswordStrengthView(password: "test123")
    }
    .padding()
}

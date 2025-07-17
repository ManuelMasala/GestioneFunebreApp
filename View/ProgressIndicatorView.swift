//
//  ProgressIndicatorView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 08/07/25.
//

import SwiftUI

struct ProgressIndicatorView: View {
    let message: String
    
    init(_ message: String = "Caricamento...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    ProgressIndicatorView("Caricamento dati...")
}

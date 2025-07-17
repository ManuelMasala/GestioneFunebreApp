//
//  GestioneMezziView.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 14/07/25.
//

import SwiftUI

struct GestioneMezziView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Gestione Mezzi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Funzionalità in sviluppo")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("🚗 Gestione flotta veicoli")
                    Text("🔧 Tracciamento manutenzioni")
                    Text("📋 Scadenze revisioni e bolli")
                    Text("💰 Controllo costi operativi")
                    Text("📊 Report e statistiche")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Gestione Mezzi")
        }
    }
}

#Preview {
    GestioneMezziView()
}

//
//  EnhancedDocumentViewerPopup.swift
//  GestioneFunebreApp
//
//  Created by Manuel Masala on 24/07/25.
//

import SwiftUI

// ✅ CORREZIONE ERRORE 771: Init specifico per evitare ambiguità
struct FixedEnhancedImportDocumentSheetView: View {
    let onImportTemplate: (DocumentoTemplate) -> Void  // ✅ Nome parametro specifico
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Enhanced Import Sheet - Fixed Version")
            .padding()
    }
}

// Esempio per evitare ambiguità nell'init
struct DocumentTemplateImportView: View {
    let onTemplateImport: (DocumentoTemplate) -> Void  // ✅ Nome diverso
    
    var body: some View {
        Text("Document Template Import")
    }
}

#Preview {
    FixedEnhancedImportDocumentSheetView { template in
        print("Template imported: \(template.nome)")
    }
}

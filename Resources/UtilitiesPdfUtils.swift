//
//  UtilitiesPdfUtils.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 07/07/25.
//

import Foundation
import PDFKit
import SwiftUI

struct PDFUtility {
    static func creaPDF(
        nome: String,
        cognome: String,
        utente: String,
        numeroCartella: String,
        parrocchia: String,
        tipoCarro: String,
        targa: String,
        autista: String,
        percorso: String
    ) -> URL? {
        let pdfMeta = [
            kCGPDFContextCreator: "Gestione Funebre App",
            kCGPDFContextAuthor: utente
        ]

        let fileName = "Riepilogo_\(nome)_\(cognome)_\(numeroCartella).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMeta as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .paragraphStyle: paragraphStyle
                ]

                let contenuto = """
                Riepilogo Pratica Funebre

                Defunto: \(nome) \(cognome)
                Cartella: \(numeroCartella)
                Operatore: \(utente)

                Parrocchia: \(parrocchia)
                Carro funebre: \(tipoCarro)
                Targa: \(targa)
                Autista: \(autista)
                Percorso: \(percorso)
                """

                contenuto.draw(in: CGRect(x: 30, y: 40, width: 550, height: 700), withAttributes: attributes)
            }

            return url
        } catch {
            print("Errore generazione PDF: \(error)")
            return nil
        }
    }
}

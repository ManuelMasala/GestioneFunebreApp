//
//  AppDesign.swift
//  GestioneFunebreApp
//
//  Created by Marco Lecca on 16/07/25.
//

import SwiftUI

// MARK: - Design System
struct AppDesign {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color(red: 0.2, green: 0.4, blue: 0.8)
        static let primaryLight = Color(red: 0.3, green: 0.5, blue: 0.9)
        static let primaryDark = Color(red: 0.1, green: 0.3, blue: 0.6)
        
        // Secondary Colors
        static let secondary = Color(red: 0.5, green: 0.7, blue: 0.9)
        static let accent = Color(red: 0.0, green: 0.6, blue: 1.0)
        
        // Status Colors
        static let success = Color(red: 0.0, green: 0.7, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
        static let info = Color(red: 0.2, green: 0.6, blue: 0.9)
        
        // Neutral Colors
        static let background = Color(NSColor.controlBackgroundColor)
        static let surface = Color(NSColor.controlBackgroundColor)
        static let surfaceSecondary = Color(NSColor.separatorColor).opacity(0.1)
        
        // Text Colors
        static let textPrimary = Color(NSColor.labelColor)
        static let textSecondary = Color(NSColor.secondaryLabelColor)
        static let textTertiary = Color(NSColor.tertiaryLabelColor)
        
        // Functional Colors
        static let defunto = Color(red: 0.4, green: 0.2, blue: 0.6)
        static let mezzi = Color(red: 0.0, green: 0.6, blue: 0.4)
        static let contabilita = Color(red: 0.8, green: 0.4, blue: 0.0)
        static let inventario = Color(red: 0.6, green: 0.0, blue: 0.4)
        static let mint = Color(red: 0.0, green: 0.8, blue: 0.6)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.medium)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let caption = Font.caption
        static let captionMedium = Font.caption.weight(.medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let small = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.15)
        static let large = Color.black.opacity(0.2)
    }
}

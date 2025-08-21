//
//  ColorThemes.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct ColorThemes {
    // MARK: - Primary Colors (Tech-Forward Futuristic Theme)
    static let primaryBlue = Color(red: 0.1, green: 0.6, blue: 1.0)
    static let primaryPurple = Color(red: 0.5, green: 0.2, blue: 1.0)
    static let primaryTeal = Color(red: 0.0, green: 0.8, blue: 0.8)
    
    // MARK: - Accent Colors
    static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let accentPink = Color(red: 1.0, green: 0.3, blue: 0.7)
    static let accentGreen = Color(red: 0.2, green: 0.9, blue: 0.5)
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(red: 0.05, green: 0.05, blue: 0.12)
    static let backgroundSecondary = Color(red: 0.1, green: 0.1, blue: 0.18)
    static let backgroundTertiary = Color(red: 0.15, green: 0.15, blue: 0.25)
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.8, green: 0.8, blue: 0.9)
    static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.7)
    
    // MARK: - Surface Colors
    static let surfacePrimary = Color(red: 0.12, green: 0.12, blue: 0.22)
    static let surfaceSecondary = Color(red: 0.18, green: 0.18, blue: 0.28)
    static let surfaceElevated = Color(red: 0.22, green: 0.22, blue: 0.35)
    
    // MARK: - Status Colors
    static let success = Color(red: 0.2, green: 0.9, blue: 0.5)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let info = Color(red: 0.3, green: 0.7, blue: 1.0)
    
    // MARK: - Gradient Definitions
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentOrange, accentPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [backgroundPrimary, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [surfacePrimary.opacity(0.8), surfaceSecondary.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Financial Colors
    static let financialGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let financialRed = Color(red: 1.0, green: 0.4, blue: 0.4)
    static let financialBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    static let financialGold = Color(red: 1.0, green: 0.8, blue: 0.2)
    
    // MARK: - Difficulty Level Colors
    static let beginnerColor = success
    static let intermediateColor = warning
    static let advancedColor = error
}

// MARK: - Design System Extensions
extension ColorThemes {
    // MARK: - Shadow Styles
    static let cardShadow = Color.black.opacity(0.3)
    static let elevatedShadow = Color.black.opacity(0.5)
    
    // MARK: - Border Colors
    static let borderPrimary = Color.white.opacity(0.1)
    static let borderSecondary = Color.white.opacity(0.05)
    static let borderAccent = primaryBlue.opacity(0.3)
}

// MARK: - Typography System
struct Typography {
    // MARK: - Font Weights
    static let thin = Font.Weight.thin
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    static let heavy = Font.Weight.heavy
    
    // MARK: - Font Sizes (iOS 15.6 compatible)
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    static let headline = Font.headline.weight(.semibold)
    static let subheadline = Font.subheadline.weight(.medium)
    static let body = Font.body.weight(.regular)
    static let callout = Font.callout.weight(.regular)
    static let footnote = Font.footnote.weight(.regular)
    static let caption1 = Font.caption.weight(.regular)
    static let caption2 = Font.caption2.weight(.regular)
}

// MARK: - Spacing System
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius System
struct CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let circle: CGFloat = 50
}

// MARK: - Animation System
struct AnimationPresets {
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let easeInOut = Animation.easeInOut(duration: 0.3)
    static let easeOut = Animation.easeOut(duration: 0.25)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let smooth = Animation.easeInOut(duration: 0.4)
}

// MARK: - View Modifiers for Consistent Styling
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ColorThemes.cardGradient)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(ColorThemes.borderPrimary, lineWidth: 1)
            )
            .shadow(color: ColorThemes.cardShadow, radius: 8, x: 0, y: 4)
    }
}

struct GlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ColorThemes.surfacePrimary.opacity(0.8))
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(ColorThemes.borderPrimary, lineWidth: 1)
            )
    }
}

struct ButtonPrimaryStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(ColorThemes.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(ColorThemes.primaryGradient)
            .cornerRadius(CornerRadius.medium)
            .shadow(color: ColorThemes.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct ButtonSecondaryStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(ColorThemes.primaryBlue)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(ColorThemes.surfacePrimary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(ColorThemes.primaryBlue, lineWidth: 2)
            )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func glassStyle() -> some View {
        modifier(GlassStyle())
    }
    
    func primaryButton() -> some View {
        modifier(ButtonPrimaryStyle())
    }
    
    func secondaryButton() -> some View {
        modifier(ButtonSecondaryStyle())
    }
}

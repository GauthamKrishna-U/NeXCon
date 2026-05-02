// DesignSystem.swift
// NeXCon — Design System
// Centralized design tokens: colors, gradients, typography, spacing

import SwiftUI

// MARK: - Color Palette

extension Color {
    
    // MARK: Adaptive backgrounds
    static let nexBackground    = Color("NexBackground")
    static let nexSurface       = Color("NexSurface")
    
    // MARK: Brand gradient colors
    static let nexPrimary       = Color(red: 0.40, green: 0.45, blue: 1.0)   // Rich violet-blue
    static let nexSecondary     = Color(red: 0.65, green: 0.38, blue: 1.0)   // Vivid purple
    static let nexAccent        = Color(red: 1.0,  green: 0.55, blue: 0.35)  // Warm coral
    
    // MARK: Semantic
    static let nexText          = Color.primary
    static let nexSubtext       = Color.secondary
    static let nexCardBg        = Color(UIColor.secondarySystemBackground)
    static let nexDivider       = Color(UIColor.separator)
}

// MARK: - Gradient Definitions

struct NexGradients {
    
    /// Hero background gradient — deep to vibrant
    static var heroBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.08, blue: 0.18),
                Color(red: 0.12, green: 0.10, blue: 0.28),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Dashboard header gradient
    static var headerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.nexPrimary,
                Color.nexSecondary,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Progress ring gradient
    static var progressRing: AngularGradient {
        AngularGradient(
            colors: [Color.nexPrimary, Color.nexAccent, Color.nexPrimary],
            center: .center,
            startAngle: .degrees(-90),
            endAngle: .degrees(270)
        )
    }
    
    /// Streak badge gradient
    static var streakGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.65, blue: 0.1),
                Color(red: 1.0, green: 0.35, blue: 0.1),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Shadow Helpers

struct NexShadow: ViewModifier {
    var color: Color = .black.opacity(0.12)
    var radius: CGFloat = 12
    var y: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: 0, y: y)
    }
}

extension View {
    func nexCardShadow() -> some View {
        self.modifier(NexShadow())
    }
    
    func nexLiftShadow() -> some View {
        self.modifier(NexShadow(color: .black.opacity(0.18), radius: 20, y: 10))
    }
}

// MARK: - Button Press Modifier

/// Applies a spring scale press effect to any button
struct ButtonPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Card Appear Modifier

/// Animates a card sliding up and fading in
struct CardAppear: ViewModifier {
    let appeared: Bool
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)
            .animation(
                .spring(response: 0.55, dampingFraction: 0.78)
                .delay(delay),
                value: appeared
            )
    }
}

extension View {
    func cardAppear(appeared: Bool, delay: Double = 0) -> some View {
        self.modifier(CardAppear(appeared: appeared, delay: delay))
    }
}

// MARK: - Typography Scale

struct NexFont {
    static let largeTitle  = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1      = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2      = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3      = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline    = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body        = Font.system(size: 16, weight: .regular, design: .rounded)
    static let callout     = Font.system(size: 15, weight: .medium, design: .rounded)
    static let subhead     = Font.system(size: 14, weight: .medium, design: .rounded)
    static let caption     = Font.system(size: 12, weight: .regular, design: .rounded)
    static let micro       = Font.system(size: 11, weight: .medium, design: .rounded)
}

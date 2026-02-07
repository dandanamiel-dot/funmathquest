import SwiftUI

enum Theme {
    // MARK: - Gradients
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.88, blue: 0.98),  // Soft lavender
            Color(red: 0.88, green: 0.94, blue: 0.98),  // Soft sky
            Color(red: 0.98, green: 0.92, blue: 0.88)   // Soft peach
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let celebrationGradient = LinearGradient(
        colors: [
            Color(red: 0.6, green: 0.5, blue: 0.95),
            Color(red: 0.8, green: 0.6, blue: 0.95),
            Color(red: 0.95, green: 0.8, blue: 0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Base Colors
    
    static let card = Color(red: 1.00, green: 0.99, blue: 0.97)
    static let accent = Color(red: 0.98, green: 0.44, blue: 0.26)
    static let secondary = Color(red: 0.18, green: 0.54, blue: 0.84)
    static let highlight = Color(red: 0.98, green: 0.82, blue: 0.24)
    static let ink = Color(red: 0.18, green: 0.16, blue: 0.20)

    // MARK: - Mode Colors (Vibrant)
    
    static let modePink = Color(red: 0.98, green: 0.46, blue: 0.64)
    static let modeOrange = Color(red: 0.98, green: 0.56, blue: 0.24)
    static let modeBlue = Color(red: 0.28, green: 0.56, blue: 0.95)
    static let modePurple = Color(red: 0.55, green: 0.40, blue: 0.94)
    static let modeTeal = Color(red: 0.18, green: 0.72, blue: 0.66)
    static let modeGreen = Color(red: 0.46, green: 0.84, blue: 0.46)
    
    // MARK: - Star & Reward Colors
    
    static let starGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let starGoldLight = Color(red: 1.0, green: 0.94, blue: 0.4)
    static let starGoldDark = Color(red: 0.9, green: 0.7, blue: 0.0)
    
    // MARK: - Confetti Palette
    
    static let confettiColors: [Color] = [
        starGold,
        modePink,
        modePurple,
        modeBlue,
        modeTeal,
        modeOrange,
        modeGreen
    ]
    
    // MARK: - Feedback Colors
    
    static let correct = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let incorrect = Color(red: 0.95, green: 0.4, blue: 0.4)

    // MARK: - Typography
    
    static func titleFont(_ size: CGFloat) -> Font {
        .custom("Chalkboard SE", size: size)
    }

    static func bodyFont(_ size: CGFloat) -> Font {
        .custom("Chalkboard SE", size: size)
    }
}


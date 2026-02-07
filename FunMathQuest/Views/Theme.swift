import SwiftUI

enum Theme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.92, blue: 0.82),
            Color(red: 0.88, green: 0.94, blue: 0.98),
            Color(red: 0.93, green: 0.90, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = Color(red: 1.00, green: 0.99, blue: 0.97)
    static let accent = Color(red: 0.98, green: 0.44, blue: 0.26)
    static let secondary = Color(red: 0.18, green: 0.54, blue: 0.84)
    static let highlight = Color(red: 0.98, green: 0.82, blue: 0.24)

    static let modePink = Color(red: 0.98, green: 0.46, blue: 0.64)
    static let modeOrange = Color(red: 0.98, green: 0.56, blue: 0.24)
    static let modeBlue = Color(red: 0.28, green: 0.56, blue: 0.95)
    static let modePurple = Color(red: 0.55, green: 0.40, blue: 0.94)
    static let modeTeal = Color(red: 0.18, green: 0.72, blue: 0.66)

    static let ink = Color(red: 0.18, green: 0.16, blue: 0.20)

    static func titleFont(_ size: CGFloat) -> Font {
        .custom("Chalkboard SE", size: size)
    }

    static func bodyFont(_ size: CGFloat) -> Font {
        .custom("Chalkboard SE", size: size)
    }
}

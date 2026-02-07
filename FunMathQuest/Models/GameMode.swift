import Foundation
import SwiftUI

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case table = "Multiplication Table"
    case by10 = "Multiply by 10"
    case by100 = "Multiply by 100"
    case by1000 = "Multiply by 1000"
    case div10 = "Divide by 10"
    case div100 = "Divide by 100"
    case random = "Random Drills"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .table:
            return "Learn the full 1–12 table in a colorful grid."
        case .by10:
            return "Practice multiplying any number by 10."
        case .by100:
            return "Practice multiplying any number by 100."
        case .by1000:
            return "Practice multiplying any number by 1000."
        case .div10:
            return "Practice dividing by 10 with clean answers."
        case .div100:
            return "Practice dividing by 100 with clean answers."
        case .random:
            return "Quick-fire random multiplication questions."
        }
    }

    var iconName: String {
        switch self {
        case .table:
            return "square.grid.3x3.fill"
        case .by10:
            return "10.square.fill"
        case .by100:
            return "100.square.fill"
        case .by1000:
            return "1000.square.fill"
        case .div10:
            return "divide.circle.fill"
        case .div100:
            return "divide.circle.fill"
        case .random:
            return "wand.and.stars"
        }
    }

    var tint: Color {
        switch self {
        case .table:
            return Theme.modeTeal
        case .by10:
            return Theme.modeOrange
        case .by100:
            return Theme.modePurple
        case .by1000:
            return Theme.modeBlue
        case .div10:
            return Theme.modePink
        case .div100:
            return Theme.modeTeal
        case .random:
            return Theme.modePink
        }
    }

    var isDrill: Bool {
        switch self {
        case .table:
            return false
        default:
            return true
        }
    }
}

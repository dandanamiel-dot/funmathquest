import SwiftUI
import Combine

final class LanguageStore: ObservableObject {
    private let storageKey = "funmath.language"

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        }
    }

    var isHebrew: Bool { language == .hebrew }

    func t(_ key: LocalizedKey) -> String {
        language == .hebrew ? key.hebrew : key.english
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: storageKey)
        language = AppLanguage(rawValue: stored ?? AppLanguage.english.rawValue) ?? .english
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case hebrew = "he"

    var id: String { rawValue }
}

enum LocalizedKey {
    case appTitle
    case tagline
    case latestScore
    case viewAll
    case playRound
    case start
    case questionOf
    case whatIsAnswer
    case typeAnswer
    case check
    case streak
    case best
    case questionsCount
    case roundComplete
    case done
    case gotScore
    case results
    case close
    case clear
    case noScores
    case share
    case accuracy
    case bestStreak
    case time
    case multiplicationTable
    case tapRowColumn
    case language
    case english
    case hebrew
    case dashboard
    case openDashboard
}

extension LocalizedKey {
    var english: String {
        switch self {
        case .appTitle: return "Fun Math Quest"
        case .tagline: return "Choose a challenge and collect stars!"
        case .latestScore: return "Latest Score"
        case .viewAll: return "View All"
        case .playRound: return "Play a round to see your first score!"
        case .start: return "Start"
        case .questionOf: return "Question %d of %d"
        case .whatIsAnswer: return "What is the answer?"
        case .typeAnswer: return "Type answer"
        case .check: return "Check"
        case .streak: return "Streak"
        case .best: return "Best"
        case .questionsCount: return "%d questions"
        case .roundComplete: return "Round Complete!"
        case .done: return "Done"
        case .gotScore: return "You got %d out of %d correct."
        case .results: return "Results"
        case .close: return "Close"
        case .clear: return "Clear"
        case .noScores: return "No scores yet"
        case .share: return "Share"
        case .accuracy: return "Accuracy"
        case .bestStreak: return "Best Streak"
        case .time: return "Time"
        case .multiplicationTable: return "Multiplication Table"
        case .tapRowColumn: return "Tap a row and column to highlight a fact."
        case .language: return "Language"
        case .english: return "English"
        case .hebrew: return "Hebrew"
        case .dashboard: return "Score Dashboard"
        case .openDashboard: return "Open Dashboard"
        }
    }

    var hebrew: String {
        switch self {
        case .appTitle: return "מסע מתמטיקה"
        case .tagline: return "בחרו אתגר ואספו כוכבים!"
        case .latestScore: return "ניקוד אחרון"
        case .viewAll: return "הצג הכל"
        case .playRound: return "שחקו סבב כדי לראות ניקוד ראשון!"
        case .start: return "התחל"
        case .questionOf: return "שאלה %d מתוך %d"
        case .whatIsAnswer: return "מה התשובה?"
        case .typeAnswer: return "הקלד תשובה"
        case .check: return "בדוק"
        case .streak: return "רצף"
        case .best: return "הטוב ביותר"
        case .questionsCount: return "%d שאלות"
        case .roundComplete: return "הסבב הושלם!"
        case .done: return "סיום"
        case .gotScore: return "עניתם נכון על %d מתוך %d."
        case .results: return "תוצאות"
        case .close: return "סגור"
        case .clear: return "נקה"
        case .noScores: return "אין תוצאות עדיין"
        case .share: return "שתף"
        case .accuracy: return "דיוק"
        case .bestStreak: return "רצף שיא"
        case .time: return "זמן"
        case .multiplicationTable: return "טבלת כפל"
        case .tapRowColumn: return "לחצו על שורה ועמודה כדי להדגיש."
        case .language: return "שפה"
        case .english: return "אנגלית"
        case .hebrew: return "עברית"
        case .dashboard: return "לוח תוצאות"
        case .openDashboard: return "פתח לוח"
        }
    }
}

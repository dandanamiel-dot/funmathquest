import Foundation
import Combine

final class ScoreStore: ObservableObject {
    @Published private(set) var sessions: [SessionResult] = []

    private let storageKey = "funmath.sessions"

    init() {
        load()
    }

    func add(_ session: SessionResult) {
        sessions.insert(session, at: 0)
        save()
    }

    func clear() {
        sessions = []
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            sessions = try JSONDecoder().decode([SessionResult].self, from: data)
        } catch {
            sessions = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Ignore write failures; the app can still run.
        }
    }
}

extension ScoreStore {
    static var mock: ScoreStore {
        let store = ScoreStore()
        store.sessions = [
            SessionResult(mode: .random, totalQuestions: 12, correctAnswers: 10, bestStreak: 6, durationSeconds: 95),
            SessionResult(mode: .by10, totalQuestions: 8, correctAnswers: 8, bestStreak: 8, durationSeconds: 60)
        ]
        return store
    }
}

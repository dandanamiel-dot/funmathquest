import Foundation
import Combine

/// Manages daily challenge progress and star rewards
final class DailyChallengeStore: ObservableObject {
    // MARK: - Published Properties
    
    /// Number of drills completed today
    @Published private(set) var drillsCompletedToday: Int = 0
    
    /// Total stars earned (persistent across days)
    @Published private(set) var totalStars: Int = 0
    
    /// Whether the daily challenge is complete
    var isDailyComplete: Bool {
        drillsCompletedToday >= dailyGoal
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        min(Double(drillsCompletedToday) / Double(dailyGoal), 1.0)
    }
    
    /// Number of star milestones reached today
    var milestonesReached: Int {
        drillsCompletedToday / drillsPerMilestone
    }
    
    // MARK: - Constants
    
    /// Daily drill goal
    let dailyGoal = 100
    
    /// Drills required per milestone (star reward)
    let drillsPerMilestone = 10
    
    /// Stars awarded per milestone
    let starsPerMilestone = 5
    
    /// Maximum stars that can be earned per day
    var maxDailyStars: Int {
        (dailyGoal / drillsPerMilestone) * starsPerMilestone
    }
    
    // MARK: - Private Properties
    
    private let drillsKey = "funmath.dailyDrills"
    private let starsKey = "funmath.totalStars"
    private let lastDateKey = "funmath.lastChallengeDate"
    
    private var previousMilestoneCount = 0
    
    // MARK: - Initialization
    
    init() {
        load()
        checkForNewDay()
    }
    
    // MARK: - Public Methods
    
    /// Record completion of drills
    /// - Parameter count: Number of drills completed
    /// - Returns: Number of new stars earned (if any)
    @discardableResult
    func completeDrills(_ count: Int) -> Int {
        previousMilestoneCount = milestonesReached
        drillsCompletedToday += count
        
        let newMilestoneCount = milestonesReached
        let milestonesEarned = newMilestoneCount - previousMilestoneCount
        let starsEarned = milestonesEarned * starsPerMilestone
        
        if starsEarned > 0 {
            totalStars += starsEarned
        }
        
        save()
        return starsEarned
    }
    
    /// Record completion of a single drill
    /// - Parameter wasCorrect: Whether the answer was correct
    /// - Returns: Number of new stars earned (if any)
    @discardableResult
    func recordDrill(wasCorrect: Bool) -> Int {
        if wasCorrect {
            return completeDrills(1)
        }
        return 0
    }
    
    /// Reset daily progress (for testing)
    func resetDaily() {
        drillsCompletedToday = 0
        save()
    }
    
    /// Reset all progress (for testing)
    func resetAll() {
        drillsCompletedToday = 0
        totalStars = 0
        save()
    }
    
    // MARK: - Private Methods
    
    private func checkForNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDateData = UserDefaults.standard.data(forKey: lastDateKey),
           let lastDate = try? JSONDecoder().decode(Date.self, from: lastDateData) {
            let lastDay = calendar.startOfDay(for: lastDate)
            
            if today > lastDay {
                // New day - reset daily progress
                drillsCompletedToday = 0
                saveLastDate(today)
            }
        } else {
            // First launch - set today as last date
            saveLastDate(today)
        }
    }
    
    private func saveLastDate(_ date: Date) {
        if let data = try? JSONEncoder().encode(date) {
            UserDefaults.standard.set(data, forKey: lastDateKey)
        }
    }
    
    private func load() {
        drillsCompletedToday = UserDefaults.standard.integer(forKey: drillsKey)
        totalStars = UserDefaults.standard.integer(forKey: starsKey)
    }
    
    private func save() {
        UserDefaults.standard.set(drillsCompletedToday, forKey: drillsKey)
        UserDefaults.standard.set(totalStars, forKey: starsKey)
        saveLastDate(Date())
    }
}

// MARK: - Mock for Previews

extension DailyChallengeStore {
    static var mock: DailyChallengeStore {
        let store = DailyChallengeStore()
        store.drillsCompletedToday = 45
        store.totalStars = 25
        return store
    }
    
    static var mockComplete: DailyChallengeStore {
        let store = DailyChallengeStore()
        store.drillsCompletedToday = 100
        store.totalStars = 75
        return store
    }
}

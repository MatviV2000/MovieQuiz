import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case total
        case date
        case gamesCount
        case totalCorrectAnswers
        case totalQuestions
    }
    
    var totalAccuracy: Double {
        let correctAnswers: Int = storage.integer(forKey: Keys.correct.rawValue)
        let totalAccuracy: Double = (Double(correctAnswers) / (10.0 * Double(gamesCount))) * 100
        
        guard totalAccuracy > 0 else { return 0.0 }
        
        return totalAccuracy
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let previousCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let previousTotal = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        storage.set(previousCorrect + count, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(previousTotal + amount, forKey: Keys.totalQuestions.rawValue)
        
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if newGame.correct > bestGame.correct {
            bestGame = newGame
        }
    }
}

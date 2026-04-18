import SwiftData
import Foundation

@Model
final class UserInterestProfile {
    var id: UUID
    var updatedDate: Date
    var interestWeights: [String: Double]  // ["習慣": 0.8, "健康": 0.6, ...]
    var idealGoals: [String]
    var totalScannedCount: Int

    init(idealGoals: [String] = []) {
        self.id = UUID()
        self.updatedDate = .now
        self.interestWeights = [:]
        self.idealGoals = idealGoals
        self.totalScannedCount = 0
    }

    /// スコアが高い順に上位5件を返す
    var topInterests: [(category: String, weight: Double)] {
        interestWeights
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (category: $0.key, weight: $0.value) }
    }
}

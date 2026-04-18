import XCTest
@testable import WisdomSnap

final class WisdomSnapTests: XCTestCase {

    func testSuggestionTypeRawValue() {
        XCTAssertEqual(SuggestionType.quote.rawValue,  "格言")
        XCTAssertEqual(SuggestionType.habit.rawValue,  "習慣")
        XCTAssertEqual(SuggestionType.action.rawValue, "アクション")
    }

    func testUserInterestProfileTopInterests() {
        let profile = UserInterestProfile()
        profile.interestWeights = ["習慣": 0.9, "健康": 0.7, "読書": 0.5]
        let top = profile.topInterests
        XCTAssertEqual(top.first?.category, "習慣")
        XCTAssertEqual(top.count, 3)
    }
}

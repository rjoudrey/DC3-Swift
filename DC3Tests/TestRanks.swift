import XCTest
@testable import DC3

class TestRanks: XCTestCase {
    func testRanks() {
        let elements = ["b", "d", "a", "c", "a"]
        let sortedIndices = elements.indices.bucketSort(key: {
            Int(UnicodeScalar(elements[$0!])!.value)
        })
        let sortedRanks = elements.ranks(sortedIndices: sortedIndices, compare: ==)
        let pairs = zip(sortedIndices, sortedRanks)
        var actual = [Int](repeating: 0, count: sortedRanks.count)
        for pair in pairs {
            actual[pair.0] = pair.1
        }
        let expected = [2, 4, 1, 3, 1]
        XCTAssertEqual(expected, actual)
    }

    func testRanksEmpty() {
        let elements = [Int]()
        let actual = elements.ranks(sortedIndices: [], compare: ==)
        let expected = [Int]()
        XCTAssertEqual(expected, actual)
    }

    func testRanks1() {
        let elements = [0]
        let actual = elements.ranks(sortedIndices: [0], compare: ==)
        let expected = [1]
        XCTAssertEqual(expected, actual)
    }
}

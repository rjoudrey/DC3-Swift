import XCTest
@testable import DC3

class TestRadixSort: XCTestCase {
    func testRadixSort() {
        let actual = ["baa", "bab", "aaa", "aac", "aab"]
            .map { $0.characters }
            .radixSort(key: { c in
                Int(String(c!).unicodeScalars.first!.value)
            }).map(String.init)
        let expected = ["aaa", "aab", "aac", "baa", "bab"]
        XCTAssertEqual(expected, actual)
    }

    func testRadixSortVariableSize() {
        let actual = ["aa", "aaa", "a"]
            .map { $0.characters }
            .radixSort(key: { c in
                guard let c = c else {
                    return 0
                }
                return Int(String(c).unicodeScalars.first!.value) + 1
            }).map(String.init)
        let expected = ["a", "aa", "aaa"]
        XCTAssertEqual(expected, actual)
    }

    func testRadixSortEmpty() {
        let expected = [[Int]]().radixSort(key: { $0! })
        let actual = [[Int]]()
        XCTAssertTrue(expected.elementsEqual(actual, by: ==))
    }

    func testRadixSort1() {
        let expected = [[1]].radixSort(key: { $0! })
        let actual = [[1]]
        XCTAssertTrue(expected.elementsEqual(actual, by: ==))
    }

    func testRadixSortIndexes() {
        let elements = [1, 2, 3]
        let suffixes = elements.indices.map { elements.suffix(from: $0) }
        let expected = [0, 1, 2]
        let actual = suffixes.radixSortedIndices(key: { e in
            guard let e = e else {
                return 0
            }
            return e + 1
        })
        XCTAssertTrue(expected.elementsEqual(actual))
    }
}

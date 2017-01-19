import XCTest
@testable import DC3

class DC3Tests: XCTestCase {
    func testBucketSort() {
        let actual = ["d", "a", "b", "c"].bucketSort(key: {
            Int(UnicodeScalar($0!)!.value)
        })
        let expected = ["a", "b", "c", "d"]
        XCTAssertEqual(expected, actual)
    }

    func testBucketSortEmpty() {
        let expected = [Int]().bucketSort(key: { $0! })
        let actual = [Int]()
        XCTAssertEqual(expected, actual)
    }

    func testBucketSort1() {
        let expected = [1].bucketSort(key: { $0! })
        let actual = [1]
        XCTAssertEqual(expected, actual)
    }

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

    /*func testSuffixArray() {
        let elements = [1, 2, 5, 4, 3, 1, 3]
        // suffixes:
        // 0: 1, 2, 5, 4, 3, 1, 3
        // 1: 2, 5, 4, 3, 1, 3
        // 2: 5, 4, 3, 1, 3
        // 3: 4, 3, 1, 3
        // 4: 3, 1, 3
        // 5: 1, 3
        // 6: 3
        let actual = elements.suffixArray()
        let expected = [0, 5, 1, 6, 4, 3, 2]
        XCTAssertEqual(expected, actual)
    }*/

    /*func testSuffixArray2() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "words", withExtension: "txt")!
        let wordList = try! String(contentsOf: url)
        let words = wordList.components(separatedBy: .newlines)
        var numberOfSuccesses = 0
        // TODO: Test aaa
        for word in ["yabbadabbado"] {
            let suffixes = word.characters.indices.map {
                String(word.characters.suffix(from: $0))
            }
            let expectedSortedIndices = suffixes.indices.sorted(by: { lhs, rhs in
                suffixes[lhs] < suffixes[rhs]
            })
            let chars = Array(word.utf8).map {
                Int($0)
            }
            let actualSortedIndices = chars.suffixArray()
            let expectationIsTrue = actualSortedIndices.elementsEqual(expectedSortedIndices)
            XCTAssertTrue(
                expectationIsTrue,
                "\nWord: \(word)" +
                "\nExpected: \(expectedSortedIndices)" +
                "\nGot:      \(actualSortedIndices)" +
                "\nNumber of successes: \(numberOfSuccesses)"
            )
            if !expectationIsTrue {
                return
            }
            numberOfSuccesses += 1
        }
    }*/
}

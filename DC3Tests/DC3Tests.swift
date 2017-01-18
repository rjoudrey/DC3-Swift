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

    var expectedPart0Output: SuffixArrayPart0Output {
        let R = ["abb", "ada", "bba", "do", "bba", "dab", "bad", "o"].map(toInts)
        let output = SuffixArrayPart0Output(
            B1: [1, 4, 7, 10],
            B2: [2, 5, 8, 11],
            C: [1, 4, 7, 10, 2, 5, 8, 11],
            R: R
        )
        return output
    }

    func testSuffixArrayPart0() {
        let input = "yabbadabbado".utf8.map { Int($0) }
        let actual = suffixArrayPart0(input: input)
        let expected = expectedPart0Output
        XCTAssertEqual(actual.B1, expected.B1)
        XCTAssertEqual(actual.B2, expected.B2)
        XCTAssertEqual(actual.C, expected.C)
        XCTAssertTrue(actual.R.elementsEqual(expected.R, by: ==))
    }

    var expectedPart1Output: SuffixArrayPart1Output {
        return SuffixArrayPart1Output(
            ranksOfR: [1, 2, 4, 6, 4, 5, 3, 7],
            sortedIndicesOfR: [0, 1, 6, 2, 4, 5, 3, 7],
            sortedRanksOfR: [1, 2, 3, 4, 4, 5, 6, 7]
        )
    }

    func testSuffixArrayPart1() {
        let input = expectedPart0Output
        let actual = suffixArrayPart1(part0: input)
        let expected = expectedPart1Output
        XCTAssertEqual(actual.ranksOfR, expected.ranksOfR)
        XCTAssertEqual(actual.sortedIndicesOfR, expected.sortedIndicesOfR)
        XCTAssertEqual(actual.sortedRanksOfR, expected.sortedRanksOfR)
    }

    var expectedPart1_5Output: SuffixArrayPart1_5Output {
        return SuffixArrayPart1_5Output(
            sortedIndicesOfR: []
        )
    }

    func testSuffixArrayPart1_5() {
        let input = expectedPart1Output
        let actual = suffixArrayPart1_5(part1: input)
        let expected = expectedPart1_5Output
        XCTAssertEqual(actual.sortedIndicesOfR, expected.sortedIndicesOfR)
    }

    func toChars(ints: [Int]) -> String {
        return String(ints.map { Character(UnicodeScalar($0)!) })
    }

    func toInts(string: String) -> [Int] {
        return string.utf8.map { Int($0) }
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

import XCTest
@testable import DC3

class SuffixArrayTests: XCTestCase {
    var suffixArrayInput = "yabbadabbado0".utf8.map { Int($0) }

    func toChars(ints: [Int]) -> String {
        return String(ints.map { Character(UnicodeScalar($0)!) })
    }

    func toInts(string: String) -> [Int] {
        return string.utf8.map { Int($0) }
    }

    var expectedPart0Output: SuffixArrayPart0Output {
        let R = ["abb", "ada", "bba", "do0", "bba", "dab", "bad", "o0"].map(toInts)
        let output = SuffixArrayPart0Output(
            B1: [1, 4, 7, 10],
            B2: [2, 5, 8, 11],
            C: [1, 4, 7, 10, 2, 5, 8, 11],
            R: R
        )
        return output
    }

    func testSuffixArrayPart0() {
        let input = suffixArrayInput
        let actual = suffixArrayPart0(input: input)
        let expected = expectedPart0Output
        XCTAssertEqual(actual.B1, expected.B1)
        XCTAssertEqual(actual.B2, expected.B2)
        XCTAssertEqual(actual.C, expected.C)
        XCTAssertTrue(actual.R.elementsEqual(expected.R, by: ==))
    }

    var expectedPart1Output = SuffixArrayPart1Output(
        ranksOfR: [1, 2, 4, 6, 4, 5, 3, 7],
        sortedIndicesOfR: [0, 1, 6, 2, 4, 5, 3, 7],
        sortedRanksOfR: [1, 2, 3, 4, 4, 5, 6, 7]
    )

    func testSuffixArrayPart1() {
        let input = expectedPart0Output
        let actual = suffixArrayPart1(part0: input)
        let expected = expectedPart1Output
        XCTAssertEqual(actual.ranksOfR, expected.ranksOfR)
        XCTAssertEqual(actual.sortedIndicesOfR, expected.sortedIndicesOfR)
        XCTAssertEqual(actual.sortedRanksOfR, expected.sortedRanksOfR)
    }

    var expectedPart1_5Output = SuffixArrayPart1_5Output(
        sortedIndicesOfR: [0, 2, 5, 1, 4, 3, 6, 7]
    )

    var expectedSuffixArrayPart1_7Output: SuffixArrayPart1_7Output {
        return SuffixArrayPart1_7Output(
            ranksOfSi: [nil, 1, 4, nil, 2, 6, nil, 5, 3, nil, 7, 8, nil, 0, 0]
        )
    }

    func testSuffixArrayPart1_7() {
        let input = expectedPart1_5Output
        let actual = suffixArrayPart1_7(part1_5: input, C: expectedPart0Output.C, count: suffixArrayInput.count)
        let expected = expectedSuffixArrayPart1_7Output.ranksOfSi
        XCTAssertTrue(actual.ranksOfSi.elementsEqual(expected, by: ==))
    }

    var expectedSuffixArrayPart2Output = SuffixArrayPart2Output(
        sortedIndicesOfSB0: [4, 2, 3, 1, 0]
    )

    func testSuffixArrayPart2() {
        let part1_7Output = expectedSuffixArrayPart1_7Output
        let actual = suffixArrayPart2(part1_7: part1_7Output, input: suffixArrayInput, B0: [0, 3, 6, 9, 12])
        let expected = expectedSuffixArrayPart2Output
        XCTAssertEqual(actual.sortedIndicesOfSB0, expected.sortedIndicesOfSB0)
    }

    func testConvertFromIndexOfR() {
        let actual =   [0, 1, 2, 3, 4, 5, 6, 7].map(convertFromIndexOfR)
        let expected = [1, 2, 4, 5, 7, 8, 10, 11]
        XCTAssertEqual(actual, expected)
    }

    func testsuffixArrayPart3() {
        let actual = suffixArrayPart3(
            input: suffixArrayInput,
            ranks: expectedSuffixArrayPart1_7Output.ranksOfSi,
            sortedIndicesOfR: expectedPart1_5Output.sortedIndicesOfR,
            sortedIndicesOfSB0: expectedSuffixArrayPart2Output.sortedIndicesOfSB0
        )
        let expected = [12, 1, 6, 4, 9, 3, 8, 2, 7, 5, 10, 11, 0]
        XCTAssertEqual(actual, expected)
    }
}

import XCTest
@testable import DC3

class TestSuffixArrayAlt: XCTestCase {
    let input = "insense".utf8.map { Int($0) }

    let part0Output = SuffixArrayPart0Output(
        R: ["nse", "nse", "sen", "se"].map(toInts)
    )

    let part1Output = SuffixArrayPart1Output(
        ranksOfR: [1, 1, 3, 2],
        sortedIndicesOfR: [0, 1, 3, 2],
        sortedRanksOfR: [1, 1, 2, 3]
    )

    let part1_5Output = SuffixArrayPart1_5Output(
        sortedIndicesOfR: [0, 1, 3, 2]
    )

    let part1_7Output = SuffixArrayPart1_7Output(
        ranksOfSi: [nil, 1, 4, nil, 2, 3, nil, 0, 0]
    )

    let part2Output = SuffixArrayPart2Output(
        sortedIndicesOfSB0: [2, 1, 0]
    )

    func testPart0() {
        let actual = suffixArrayPart0(input: input)
        let expected = part0Output
        XCTAssertTrue(actual.R.elementsEqual(expected.R, by: ==))
    }

    func testPart1() {
        let actual = suffixArrayPart1(part0: part0Output)
        let expected = part1Output
        XCTAssertEqual(actual.ranksOfR, expected.ranksOfR)
        XCTAssertEqual(actual.sortedRanksOfR, expected.sortedRanksOfR)
        XCTAssertEqual(actual.sortedIndicesOfR, expected.sortedIndicesOfR)
    }

    func testPart1_5() {
        let actual = suffixArrayPart1_5(part1: part1Output)
        let expected = part1_5Output
        XCTAssertEqual(actual.sortedIndicesOfR, expected.sortedIndicesOfR)
    }

    func testPart1_7() {
        let actual = suffixArrayPart1_7(part1_5: part1_5Output, count: input.count)
        let expected = part1_7Output
        XCTAssertTrue(actual.ranksOfSi.elementsEqual(expected.ranksOfSi, by: ==))
    }

    func testPart2() {
        let actual = suffixArrayPart2(part1_7: part1_7Output, input: input)
        let expected = part2Output
        XCTAssertEqual(actual.sortedIndicesOfSB0, expected.sortedIndicesOfSB0)
    }

    func testPart3() {
        let actual = suffixArrayPart3(
            input: input,
            ranks: part1_7Output.ranksOfSi,
            sortedIndicesOfR: part1_5Output.sortedIndicesOfR,
            sortedIndicesOfSB0: part2Output.sortedIndicesOfSB0
        )
        let expected = [6, 3, 0, 4, 1, 5, 2]
        XCTAssertEqual(actual, expected)
    }
}

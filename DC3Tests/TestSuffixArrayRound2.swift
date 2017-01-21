import XCTest
@testable import DC3

class TestSuffixArrayRound2: XCTestCase {
            //   0, 1, 2, 3, 4, 5, 6, 7
    let input = [1, 2, 4, 6, 4, 5, 3, 7]

    let part0Output = SuffixArrayPart0Output(
        R: [
            [2, 4, 6],
            [4, 5, 3],
            [7],
            [4, 6, 4],
            [5, 3, 7]
        ]
    )

    let part1Output = SuffixArrayPart1Output(
        ranksOfR: [1, 2, 5, 3, 4],
        sortedIndicesOfR: [0, 1, 3, 4, 2],
        sortedRanksOfR: [1, 2, 3, 4, 5]
    )

    let part1_5Output = SuffixArrayPart1_5Output(
        sortedIndicesOfR: [0, 1, 3, 4, 2]
    )

    let part1_7Output = SuffixArrayPart1_7Output(
        ranksOfSi: [nil, 1, 3, nil, 2, 4, nil, 5, 0, 0]
    )

    let part2Output = SuffixArrayPart2Output(
        sortedIndicesOfSB0: [0, 2, 1]
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
        let expected = [0, 1, 6, 4, 2, 5, 3, 7]
        XCTAssertEqual(actual, expected)
    }
}

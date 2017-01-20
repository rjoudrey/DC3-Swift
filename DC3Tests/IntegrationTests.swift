import XCTest
@testable import DC3

class IntegrationTests: XCTestCase {
    /*func testSuffixArray () {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "words", withExtension: "txt")!
        let wordList = try! String(contentsOf: url)
        let words = wordList.components(separatedBy: .newlines)
        var numberOfSuccesses = 0
        // TODO: Test aaa
        for word in words {
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

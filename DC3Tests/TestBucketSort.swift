import XCTest
@testable import DC3

class TestBucketSort: XCTestCase {
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
}

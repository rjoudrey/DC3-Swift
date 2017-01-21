import Foundation

extension Collection {
    // returns the ranks of elements in an array
    // all elements with the same value will have the same rank
    // e.g. [2, 1, 4, 2].radixSort() = [1, 0, 3, 2]
    //      [2, 1, 4, 2].ranks([1, 0, 3, 2]) = [1, 2, 3, 2]
    func ranks(sortedIndices: [Index], compare: (Iterator.Element, Iterator.Element) -> Bool) -> [Int] {
        guard let firstIndex = sortedIndices.first else {
            return []
        }
        var ranks = [1]
        var previousRank = 1
        var previousElement = self[firstIndex]
        for i in sortedIndices.dropFirst() {
            let element = self[i]
            let rank: Int
            if compare(element, previousElement) {
                rank = previousRank
            } else {
                rank = previousRank + 1
            }
            ranks.append(rank)
            previousElement = element
            previousRank = rank
        }
        return ranks
    }
}

extension Collection {
    subscript(safe i: Index) -> Iterator.Element? {
        if (startIndex ..< endIndex).contains(i) {
            return self[i]
        }
        return nil
    }
}

extension Collection {
    func adjacentDuplicateExists(areEqual: (Iterator.Element, Iterator.Element) -> Bool) -> Bool {
        guard startIndex != endIndex else {
            return false
        }
        var previousIndex = startIndex
        var i = index(after: startIndex)
        while i != endIndex {
            let previousElement = self[previousIndex]
            let element = self[i]
            if areEqual(previousElement, element) {
                return true
            }
            previousIndex = i
            formIndex(after: &i)
        }
        return false
    }
}

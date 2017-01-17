import Foundation

extension Collection where Iterator.Element: Collection {
    typealias SubElement = Iterator.Element.Iterator.Element
    typealias SubIndexDistance = Iterator.Element.IndexDistance
    typealias SubIndex = Iterator.Element.Index

    func radixSortedIndices(key: (SubElement?) -> Int) -> [Index] {
        var sortedIndices = initialIndices
        guard !isEmpty else {
            return []
        }
        let maxCollectionSize = lazy.map { $0.count }.max()!
        var distance = maxCollectionSize
        while distance != 0 {
            distance = distance - 1
            let subElements = subElementsAtDistanceFromStart(distance, orderedBy: sortedIndices)
            sortedIndices = subElements.bucketSort(key: { pair in
                return key(pair!.1)
            }).map {
                $0.0
            }
        }
        return sortedIndices
    }

    private func subElementsAtDistanceFromStart(_ distance: SubIndexDistance, orderedBy indices: [Index]) -> LazyMapRandomAccessCollection<[Index], (Index, SubElement?)> {
        return indices.lazy.map { (i: Index) -> (Index, SubElement?) in
            let subCollection = self[i]
            guard let j = subCollection.index(subCollection.startIndex, offsetBy: distance, limitedBy: subCollection.endIndex), j != subCollection.endIndex else {
                return (i, nil) // no element exists at subCollection[j]
            }
            return (i, subCollection[j])
        }
    }

    private var initialIndices: [Index] {
        var sortedIndices = [Index]()
        var i = startIndex
        while i != endIndex {
            sortedIndices.append(i)
            formIndex(after: &i)
        }
        return sortedIndices
    }

    func radixSort(key: (SubElement?) -> Int) -> [Iterator.Element] {
        return radixSortedIndices(key: key).map { self[$0] }
    }
}

extension Collection {
    func bucketSort(key: (Iterator.Element?) -> Int, maxKey: Int) -> [Iterator.Element] {
        return bucketSortedIndices(key: key, maxKey: maxKey).map { self[$0] }
    }

    func bucketSortedIndices(key: (Iterator.Element?) -> Int, maxKey: Int) -> [Index] {
        var buckets = [[Index]].init(repeating: [], count: maxKey + 1)
        var i = startIndex
        while i != endIndex {
            let element = self[i]
            let key = key(element)
            let indices = buckets[key]
            buckets[key] = indices + [i]
            formIndex(after: &i)
        }
        var sortedIndices = [Index]()
        for bucket in buckets {
            sortedIndices.append(contentsOf: bucket)
        }
        return sortedIndices
    }

    func bucketSort(key: (Iterator.Element?) -> Int) -> [Iterator.Element] {
        guard let maxKey = map(key).max() else {
            return []
        }
        return bucketSort(key: key, maxKey: maxKey)
    }

    func bucketSortedIndices(key: (Iterator.Element?) -> Int) -> [Index] {
        guard let maxKey = map(key).max() else {
            return []
        }
        return bucketSortedIndices(key: key, maxKey: maxKey)
    }
}


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

extension Collection where
    IndexDistance == Int,
    Index == Int,
    SubSequence: Collection,
    SubSequence.Iterator.Element == Int
{
    // based on https://www.cs.helsinki.fi/u/tpkarkka/publications/jacm05-revised.pdf
    func suffixArray() -> [Int] {
        // -------------------- Step 0: Construct a sample --------------------
        // sample positions
        let indices = startIndex ..< endIndex
        let R1 = indices.filter { $0 % 3 == 1 }
        let R2 = indices.filter { $0 % 3 == 2 }
        let R = R1 + R2
        // sample suffixes
        let SC = R.map { i -> SubSequence in
            let j = Swift.min(i + 3, self.endIndex)
            return self[i ..< j]
        }
        // Debugging:
        print(SC.map { String($0.map { Character(UnicodeScalar($0)!) }) })

        // ------------------- Step 1: Sort sample suffixes -------------------
        // Radix sort the characters of R
        let sortedIndicesOfR = SC.radixSortedIndices(key: { x in
            guard let x = x else {
                return 0
            }
            return x + 1
        })
        // Rename the characters with their ranks
        let sortedRanksOfR = SC.ranks(sortedIndices: sortedIndicesOfR, compare: {
            $0.elementsEqual($1)
        })
        var RPrime = [Int](repeating: 0, count: SC.count)
        for (index, rank) in zip(sortedIndicesOfR, sortedRanksOfR) {
            RPrime[index] = rank
        }
        // Debugging:
        print(RPrime)

        let sortedIndicesOfRPrime: [Int]

        var ranksSi = [Int?](repeating: nil, count: count + 1) + [0, 0]
        if sortedRanksOfR.adjacentDuplicateExists(areEqual: ==) {
            // there is a non-unique character in RPrime
            sortedIndicesOfRPrime = [ 8,0,1,6,4,2,5,3,7 ] // RPrime.suffixArray()
        } else {
            sortedIndicesOfRPrime = RPrime
        }

        var rank = 0
        for i in sortedIndicesOfRPrime {
            defer {
                rank = rank + 1
            }
            if i == R.endIndex {
                continue
            }
            // R is [1, 2, 4, 5 etc]
            let j = R[i]
            ranksSi[j] = rank
        }
        print(ranksSi)

        // ----------------- Step 2: Sort nonsample suffixes -----------------
        return []
    }
}

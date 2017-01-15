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

extension Collection where IndexDistance == Int {
    private func B0(distance: IndexDistance) -> Index {
        return index(startIndex, offsetBy: distance * 3)
    }

    private var B0Length: IndexDistance {
        return (count - 1) / 3 + 1
    }

    // 0, 3, 6, 9, ...
    var B0: LazyMapRandomAccessCollection<(CountableRange<Int>), Self.Index> {
        return (0 ..< B0Length).lazy.map {
            self.B0(distance: $0)
        }
    }

    // 1, 2, 4, 5, ...
    private func C(distance: IndexDistance) -> Index {
        return index(startIndex, offsetBy: 3 * (distance / 2) + 1 + distance % 2)
    }

    private var CLength: IndexDistance {
        return count - B0Length
    }

    var C: LazyMapRandomAccessCollection<(CountableRange<Int>), Self.Index> {
        return (0 ..< CLength).lazy.map {
            self.C(distance: $0)
        }
    }
}

extension Collection where
    Iterator.Element == Int,
    IndexDistance == Int,
    Index == Int,
    SubSequence.SubSequence: Collection,
    SubSequence.SubSequence.Index == Int,
    SubSequence.SubSequence.Iterator.Element == Int,
    Indices.Iterator.Element == Index
{
    // returns the indexes of the sorted suffixes in self
    // e.g. [1, 2, 1, 2].suffixArray() = [2, 0, 3, 1]
    // based on https://www.cs.helsinki.fi/u/tpkarkka/publications/jacm05-revised.pdf
    func suffixArray() -> [Int] {
        let toSuffixes = { self.suffix(from: $0).prefix(3) }
        // TODO: Make B0 and C lazy
        let B0 = self.B0
        let C = self.C
        // suffixes (of length 3) of C
        let SC = C.map(toSuffixes)
        let key: (Int?) -> Int = { x in
            guard let x = x else {
                return 0
            }
            return x + 1
        }
        // preliminary sorted indices of SC
        let PSISC = SC.radixSortedIndices(key: key)
        // preliminary ranks of SC
        let PRSC = SC.ranks(sortedIndices: PSISC, compare: { (lhs, rhs) in
            lhs.elementsEqual(rhs)
        })
        // ranks of SC
        let RSC: [Int]
        // sorted indices of SC
        let SISC: [Int]
        // sorted preliminary ranks of SC
        let SPRSC = PSISC.lazy.map({ PRSC[$0] })
        // is there a duplicated rank in PRSC (e.g. PRSC = [2, 1, 1, 3])?
        if SPRSC.adjacentDuplicateExists(areEqual: ==) {
            // if so, we need to recurse on PRSC to get the sorted order of SC (e.g. SISC = [3, 1, 2, 4])
            SISC = PRSC.suffixArray()
            RSC = SISC.reduce((ranks: [Int](repeating: 0, count: SC.count), rank: 1), { acc, i in
                var acc = acc
                acc.ranks[i] = acc.rank
                return (acc.ranks, acc.rank + 1)
            }).ranks
        }
        else {
            // if not, the "preliminary" ranks and sorted indices are the final sorted order of SC
            SISC = PSISC
            RSC = PRSC
        }
        // we build this array in order to simplify the calculation of rank(Si+1) and rank(Si+2)
        // note: we add two zeroes to the end of ranks so that (i+2) will always be a valid index of ranks
        let ranks = zip(C, RSC).reduce([Int](repeating: 0, count: count), { ranks, indexAndRank in
            var ranks = ranks
            ranks[indexAndRank.0] = indexAndRank.1
            return ranks
        }) + [0, 0]
        // sorted indices of SB0
        let SISB0 = B0.map { [self[$0], ranks[$0 + 1]] }.radixSortedIndices(key: key)
        // converts indices of SC into indices of self
        // e.g. ISC2I(0) = 1, ISC2I(1) = 2, ISC2I(2) = 4, etc
        let ISC2I: (Index) -> Index = { C[$0] }
        // merge SISB0 and SISC
        let out = SISB0.reduce((sortedIndices: [Index](), SRSISC: 0), { acc, SB0i in
            // the index of the suffix we are sorting on (i.e. Si)
            let i = B0[SB0i]
            // remaining indices of SC (that we need to merge with SB0)
            let RISC = SISC.suffix(from: acc.SRSISC)
            // for i in B0 and j in C, return true iff Rank(Sj) > Rank(Si)
            let rankGreaterThan: (Index) -> Bool = {
                let j = C[RISC[$0]]
                if j % 3 == 1 {
                    let RSi = (self[i], ranks[i + 1])
                    let RSj = (self[j], ranks[j + 1])
                    return RSj > RSi
                }
                else {
                    // note: self[i + 1] may not exist, so we manually check the bounds
                    let RSi = (self[i], self[safe: i + 1] ?? 0, ranks[i + 2])
                    let RSj = (self[j], self[safe: j + 1] ?? 0, ranks[j + 2])
                    return RSj > RSi
                }
            }
            // the index of SISC where RISC will start at next round
            let SRSISC: Index
            // the indexes of RISC where Sj < Si
            let IRLTI: [Index]
            if let FGTI = RISC.indices.lazy.filter(rankGreaterThan).first {
                IRLTI = SISC[RISC.startIndex ..< FGTI].map(ISC2I)
                SRSISC = FGTI
            }
            else {
                IRLTI = RISC.map(ISC2I)
                SRSISC = SISC.endIndex
            }
            return (acc.sortedIndices + IRLTI + [i], SRSISC)
        })
        return out.sortedIndices + SISC.suffix(from: out.SRSISC).map(ISC2I)
    }
}

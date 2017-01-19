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

struct SuffixArrayPart0Output {
    let B1: [Int]
    let B2: [Int]
    let C: [Int]
    let R: [[Int]]
}

struct SuffixArrayPart1Output {
    let ranksOfR: [Int] // may contain duplicate ranks
    let sortedIndicesOfR: [Int]
    let sortedRanksOfR: [Int]
}

struct SuffixArrayPart1_5Output {
    let sortedIndicesOfR: [Int]
}

struct SuffixArrayPart1_7Output {
    let ranksOfSi: [Int?] // contains no duplicate ranks
}

// based on https://www.cs.helsinki.fi/u/tpkarkka/publications/jacm05-revised.pdf

// Construct a sample
func suffixArrayPart0(input: [Int]) -> SuffixArrayPart0Output {
    let indices = input.indices
    let B1 = indices.filter { $0 % 3 == 1 }
    let B2 = indices.filter { $0 % 3 == 2 }
    // sample positions
    let C = B1 + B2
    // sample suffixes
    let R = C.map { i -> [Int] in
        let j = Swift.min(i + 3, input.endIndex)
        return Array(input[i ..< j])
    }
    // print(SC.map { String($0.map { Character(UnicodeScalar($0)!) }) })
    return SuffixArrayPart0Output(B1: B1, B2: B2, C: C, R: R)
}

// Sort sample suffixes
func suffixArrayPart1(part0: SuffixArrayPart0Output) -> SuffixArrayPart1Output {
    // Radix sort the characters of R
    let sortedIndicesOfR = part0.R.radixSortedIndices(key: { x in
        guard let x = x else {
            return 0
        }
        return x + 1
    })
    // Rename the characters with their ranks
    let sortedRanksOfR = part0.R.ranks(sortedIndices: sortedIndicesOfR, compare: {
        $0.elementsEqual($1)
    })
    var ranksOfR = [Int](repeating: 0, count: part0.R.count)
    for (index, rank) in zip(sortedIndicesOfR, sortedRanksOfR) {
        ranksOfR[index] = rank
    }
    return SuffixArrayPart1Output(ranksOfR: ranksOfR, sortedIndicesOfR: sortedIndicesOfR, sortedRanksOfR: sortedRanksOfR)
}

func suffixArrayPart1_5(part1: SuffixArrayPart1Output) -> SuffixArrayPart1_5Output {
    let sortedIndicesOfR: [Int]
    if part1.sortedRanksOfR.adjacentDuplicateExists(areEqual: ==) {
        // there is a non-unique character in RPrime
        // sortedIndicesOfR = part1.ranksOfR.suffixArray()
        sortedIndicesOfR = []
        // todo: fix this
    } else {
        sortedIndicesOfR = part1.sortedRanksOfR.map { $0 - 1 }
    }
    return SuffixArrayPart1_5Output(sortedIndicesOfR: sortedIndicesOfR)
}

func suffixArrayPart1_7(part1_5: SuffixArrayPart1_5Output, C: [Int], count: Int) -> SuffixArrayPart1_7Output {
    var ranksOfSi = [Int?](repeating: nil, count: count) + [0, 0]
    var rank = 0
    for i in part1_5.sortedIndicesOfR {
        defer {
            rank = rank + 1
        }
        if i == C.endIndex {
            continue
        }
        let j = C[i]
        ranksOfSi[j] = rank
    }
    return SuffixArrayPart1_7Output(ranksOfSi: ranksOfSi)
}

// (ti, rank(Si+1))
struct SuffixArrayPart2Output {
    var ranksOfSj: [Int?]
}

// Sort nonsample suffixes
func suffixArrayPart2(part1_7: SuffixArrayPart1_7Output, input: [Int], B0: [Int]) -> SuffixArrayPart2Output {
    let pairs = B0.map { i in
        [input[i], part1_7.ranksOfSi[i + 1]!]
    }
    let sortedIndicesOfSB0 = pairs.radixSortedIndices(key: { pair in
        if let pair = pair {
            return pair
        }
        return 0
    })
    var ranksOfSj = [Int?](repeating: nil, count: input.count + 1) + [0, 0]
    var rank = 1
    for i in sortedIndicesOfSB0 {
        let index = B0[i]
        ranksOfSj[index] = rank
        rank += 1
    }
    return SuffixArrayPart2Output(ranksOfSj: ranksOfSj)
}


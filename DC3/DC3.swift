import Foundation

// generates a sequence of values start ... end by transforming the input by next()
// I used this because it makes reverse iteration with CollectionType.Index.Distance easier
func generator<T>(from start: T, to end: T, next: @escaping (T) -> T) -> AnyIterator<T> where T: Equatable {
    var current: T = start
    var prev: T?
    return AnyIterator<T> {
        if prev == end {
            return nil
        }
        defer {
            prev = current
            current = next(current)
        }
        return current
    }
}

extension Collection where
    Iterator.Element: Collection,
    Iterator.Element.Iterator.Element: Equatable,
    Indices.Iterator.Element == Index
{
    // returns the indices of self sorted by their corresponding collections
    typealias SubCollectionElement = Iterator.Element.Iterator.Element
    func radixSort(toKey: @escaping (SubCollectionElement?) -> Int) -> [Index] {
        typealias Bucket = [Index]
        guard !isEmpty else {
            return []
        }
        let maxKey = lazy.joined().map(toKey).max()!
        // add one because buckets[maxKey] must be valid
        let numBuckets = maxKey + 1
        let maxNumDigits = lazy.map { $0.count }.max()!
        let digitRange = generator(from: maxNumDigits, to: 0, next: { $0 - 1 })
        // bucket sort self[i][j] for all i,j
        return digitRange.reduce(Array(indices)) { sortedIndices, j in
            let buckets = Array(repeating: Bucket(), count: numBuckets)
            // bucket sort self[i][j] for all i
            let filledBuckets = sortedIndices.reduce(buckets) { buckets, i in
                // bucket sort self[i][j]
                var buckets = buckets
                let digits: Iterator.Element = self[i]
                let digit: SubCollectionElement?
                // we don't assume that all subcollections have the same length,
                // so it's important to check that self[i][j] exists
                if (0 ... digits.count - 1).contains(j) {
                    let digitIndex = digits.index(digits.startIndex, offsetBy: j)
                    digit = digits[digitIndex]
                }
                else {
                    digit = nil
                }
                let digitKey = toKey(digit)
                buckets[digitKey] = buckets[digitKey] + [i]
                return buckets
            }
            return Array(filledBuckets.joined())
        }
    }
}

extension Collection where Iterator.Element: Collection, Index == Int, Iterator.Element.Iterator.Element: Equatable {
    // returns the ranks of elements in an array
    // all elements with the same value will have the same rank
    // e.g. [2, 1, 4, 2].radixSort() = [1, 0, 3, 2]
    // [2, 1, 4, 2].ranks([1, 0, 3, 2]) = [1, 2, 3, 2]
    func ranks(_ sortedIndices: [Index]) -> [Int] {
        typealias ValueRank = (value: Iterator.Element, rank: Int)
        typealias Acc = (ranks: [Int], prev: ValueRank?)
        let ranks = map { _ in 0 }
        let t: Acc = (ranks, nil)
        return sortedIndices.reduce(t, { t, i in
            let cur = self[i]
            let vr: ValueRank
            if let prev = t.prev {
                if cur.elementsEqual(prev.value) {
                    vr = prev
                }
                else {
                    vr = (cur, (prev.rank + 1))
                }
            }
            else {
                vr = (cur, 1)
            }
            var ranks = t.ranks
            ranks[i] = vr.rank
            return (ranks, vr)
        }).ranks
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe i: Index) -> Iterator.Element? {
        return indices.contains(i) ? self[i] : nil
    }
}

extension Collection where Iterator.Element == Int, Indices.SubSequence: Collection, Indices.SubSequence.Iterator.Element == Index {
    func adjacentDuplicateExists() -> Bool {
        return indices.dropLast().lazy.filter {
            self[$0] == self[self.index(after: $0)]
            }.first != nil
    }
}

// a lazy collection where C[i] can be derived from i
struct AnyLazyCollection<Element>: LazyCollectionProtocol {
    let startIndex: Int
    let endIndex: Int
    let sub: (Int) -> Element
    init(count: Int, sub: @escaping (Int) -> Element) {
        startIndex = 0
        endIndex = count
        self.sub = sub
    }
    subscript (position: Int) -> Element {
        return sub(position)
    }
    public func index(after i: Int) -> Int {
        return i + 1
    }
    func makeIterator() -> AnyIterator<Element> {
        return AnyIterator(self.indices.lazy.map { self[$0] }.makeIterator())
    }
}

extension Collection where
    Iterator.Element == Int,
    IndexDistance == Int,
    Index == Int,
    SubSequence.SubSequence: Collection,
    SubSequence.SubSequence.Iterator.Element == Int,
    SubSequence.SubSequence.Index == Int,
    Indices.Iterator.Element == Index
{
    // returns the indexes of the sorted suffixes in self
    // e.g. [1, 2, 1, 2].suffixArray() = [2, 0, 3, 1]
    // based on https://www.cs.helsinki.fi/u/tpkarkka/publications/jacm05-revised.pdf
    func suffixArray() -> [Index] {
        let toSuffixes = { self.suffix(from: $0).prefix(3) }
        let n = count
        let nB0 = (n - 1) / 3 + 1
        // 0, 3, 6, 9, ... (equivalent to indices.filter { $0 % 3 == 0 })
        let B0 = AnyLazyCollection(count: nB0, sub: { self.startIndex + $0 * 3 })
        // 1, 2, 4, 5, ... (equivalent to indices.filter { $0 % 3 != 0 })
        let C = AnyLazyCollection(count: n - nB0, sub: { self.startIndex + $0 + $0 / 2 + 1 })
        // suffixes (of length 3) of C
        let SC = C.map(toSuffixes)
        let toKey = { ($0 ?? -1) + 1 }
        // preliminary sorted indices of SC
        let PSISC = SC.radixSort(toKey: toKey)
        // preliminary ranks of SC
        let PRSC = SC.ranks(PSISC)
        // ranks of SC
        let RSC: [Int]
        // sorted indices of SC
        let SISC: [Int]
        // sorted preliminary ranks of SC
        let SPRSC = PSISC.lazy.map({ PRSC[$0] })
        // is there a duplicated rank in PRSC (e.g. PRSC = [2, 1, 1, 3])?
        if SPRSC.adjacentDuplicateExists() {
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
        let SISB0 = B0.map { [self[$0], ranks[$0 + 1]] }.radixSort(toKey: toKey)
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

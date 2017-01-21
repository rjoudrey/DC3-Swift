import Foundation

struct SuffixArrayPart0Output {
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
    return SuffixArrayPart0Output(R: R)
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
        sortedIndicesOfR = suffixArray(input: part1.ranksOfR)
    } else {
        // the indices are already sorted
        sortedIndicesOfR = part1.sortedIndicesOfR
    }
    return SuffixArrayPart1_5Output(sortedIndicesOfR: sortedIndicesOfR)
}

func suffixArrayPart1_7(part1_5: SuffixArrayPart1_5Output, count: Int) -> SuffixArrayPart1_7Output {
    var ranksOfSi = [Int?](repeating: nil, count: count) + [0, 0]
    var rank = 1
    for indexR in part1_5.sortedIndicesOfR {
        let i = convertFromIndexOfR(indexR, count: count)
        ranksOfSi[i] = rank
        rank += 1
    }
    return SuffixArrayPart1_7Output(ranksOfSi: ranksOfSi)
}

// (ti, rank(Si+1))
struct SuffixArrayPart2Output {
    var sortedIndicesOfSB0: [Int]
}

// Sort nonsample suffixes
func suffixArrayPart2(part1_7: SuffixArrayPart1_7Output, input: [Int]) -> SuffixArrayPart2Output {
    let B0 = stride(from: 0, to: input.count, by: 3)
    let pairs = B0.map { i in
        [input[i], part1_7.ranksOfSi[i + 1]!]
    }
    let sortedIndicesOfSB0 = pairs.radixSortedIndices(key: { pair in
        if let pair = pair {
            return pair
        }
        return 0
    })
    return SuffixArrayPart2Output(sortedIndicesOfSB0: sortedIndicesOfSB0)
}

// TODO: Make this performant
func convertFromIndexOfR(_ i: Int, count: Int) -> Int {
    let indices = (0 ..< count)
    let B1 = indices.filter { $0 % 3 == 1 }
    let B2 = indices.filter { $0 % 3 == 2 }
    let C = B1 + B2
    return C[i]
}

// Merge suffixes
func suffixArrayPart3(input: [Int], ranks: [Int?], sortedIndicesOfR: [Int], sortedIndicesOfSB0: [Int]) -> [Int] {
    var sortedIndices = [Int]()

    var iteratorR = sortedIndicesOfR.makeIterator()
    var iteratorSB0 = sortedIndicesOfSB0.makeIterator()

    var _indexR = iteratorR.next()
    var _indexSB0 = iteratorSB0.next()

    while let indexR = _indexR, let indexSB0 = _indexSB0 {
        // convert index of SB0 into an index of the input array
        let i = convertFromIndexOfR(indexR, count: input.count)
        let j = 3 * indexSB0

        let lessThan: Bool
        switch i % 3 {
        case 1: // i is in B1
            lessThan = (input[i], ranks[i + 1]!) <= (input[j], ranks[j + 1]!)
        case 2: // i is in B2
            lessThan = (input[i], input[safe: i + 1] ?? 0, ranks[i + 2]!) <= (input[j], input[safe: j + 1] ?? 0, ranks[j + 2]!)
        default:
            fatalError()
        }
        // suffix[i] is less than suffix[j], so increment i
        if lessThan {
            sortedIndices.append(i)
            _indexR = iteratorR.next()
        } else {
            sortedIndices.append(j)
            _indexSB0 = iteratorSB0.next()
        }
    }

    if let indexR = _indexR {
        let i = convertFromIndexOfR(indexR, count: input.count)
        sortedIndices.append(i)
    }

    while let indexR = iteratorR.next() {
        let i = convertFromIndexOfR(indexR, count: input.count)
        sortedIndices.append(i)
    }

    if let indexSB0 = _indexSB0 {
        let j = 3 * indexSB0
        sortedIndices.append(j)
    }

    while let indexSB0 = iteratorSB0.next() {
        let j = 3 * indexSB0
        sortedIndices.append(j)
    }

    return sortedIndices
}

func suffixArray(input: [Int]) -> [Int] {
    let part0 = suffixArrayPart0(input: input)
    let part1 = suffixArrayPart1(part0: part0)
    let part1_5 = suffixArrayPart1_5(part1: part1)
    let part1_7 = suffixArrayPart1_7(part1_5: part1_5, count: input.count)
    let part2 = suffixArrayPart2(part1_7: part1_7, input: input)
    let part3 = suffixArrayPart3(
        input: input,
        ranks: part1_7.ranksOfSi,
        sortedIndicesOfR: part1_5.sortedIndicesOfR,
        sortedIndicesOfSB0: part2.sortedIndicesOfSB0
    )
    return part3
}

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

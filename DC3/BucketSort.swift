import Foundation

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

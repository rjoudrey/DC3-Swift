import Foundation

let toKey: UInt8? -> Int = { value in
    guard let value = value else { return 0 }
    let a = "a".utf8.first!
    return  Int(a.distanceTo(value)) + 1
}

let printSortedSuffixes = { (s: String.UTF8View) in
    let sKeys = s.map { toKey($0) }
    let SAs = sKeys.suffixArray()
    let sortedSuffixes = SAs.map { String(s.suffixFrom(s.startIndex.advancedBy($0)))! }
    print("s:\n\(s)\n")
    print("SA(s):\n\(sortedSuffixes.joinWithSeparator("\n"))\n\n")
}

let s = "yabbadabbado"
printSortedSuffixes(s.utf8)

/*
 s:
 yabbadabbado
 
 SA(s):
 abbadabbado
 abbado
 adabbado
 ado
 badabbado
 bado
 bbadabbado
 bbado
 dabbado
 do
 o
 yabbadabbado
 */

import Foundation

let toKey: UInt8? -> Int = { value in
    guard let value = value else { return 0 }
    let a = "a".utf8.first!
    return Int(a.distanceTo(value)) + 1
}

let b = "yabbadabbado"
let bUtf8 = b.utf8
let bUtf8Keys = bUtf8.map { toKey($0) }
let sortedSuffixes = bUtf8Keys.suffixArray().map { b.substringFromIndex(b.startIndex.advancedBy($0)) }.joinWithSeparator("\n")
print("b:\n\(b)\n\nSA(b):\n\(sortedSuffixes)")

/*
 
 b:
 yabbadabbado
 
 SA(b):
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
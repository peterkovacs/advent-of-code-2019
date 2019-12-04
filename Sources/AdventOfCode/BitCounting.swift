import Foundation

public extension Int {
  var bits: Int {
    var result = ((self & 0xfff) * 0x1001001001001 & 0x84210842108421) % 0x1f
    result += (((self & 0xfff000) >> 12) * 0x1001001001001 & 0x84210842108421) % 0x1f
    result += ((self >> 24) * 0x1001001001001 & 0x84210842108421) % 0x1f
    return result
  }

  var digits: [Int] {
    assert(self > 0)

    return Array(sequence(state: self) { i in
      guard i > 0 else { return nil }
      defer { i /= 10 }
      return i % 10
    }.reversed())
  }
}

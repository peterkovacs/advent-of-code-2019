import AdventOfCode

extension Array where Element: Equatable {
  func lengthOfRun(atIndex index: Index) -> Int {
    assert(indices.contains(index))

    let item = self[index]
    return self[index...].prefix { $0 == item }.count
  }
}

extension Int {
  var digits: [Int] {
    assert(self > 0)

    return Array(sequence(state: self) { (i: inout Int) in
      guard i > 0 else { return nil }
      defer { i /= 10 }
      return i % 10
    }.reversed())
  }

  var partOne: Bool {
    let digits = self.digits
    var hasPair = false

    for i in 0..<(digits.count-1) {
      if digits[i] > digits[i + 1] { return false }
      if digits[i] == digits[i + 1] { hasPair = true }
    }

    return hasPair
  }

  var partTwo: Bool {
    let digits = self.digits
    var hasPair = false

    var i = digits.startIndex
    while i < digits.endIndex - 1 {
      let lengthOfRun = digits.lengthOfRun(atIndex: i)
      if lengthOfRun == 2 { hasPair = true }
      i += lengthOfRun - 1

      if i < digits.endIndex - 1, digits[i] > digits[i + 1] { return false }
      i += 1
    }

    return hasPair
  }
}

let part1 = (246540...787419).reduce(into: 0) {
  if $1.partOne { $0 += 1 }
}
print("part1", part1)

let part2 = (246540...787419).reduce(into: 0) {
  if $1.partTwo { $0 += 1 }
}
print("part2", part2)

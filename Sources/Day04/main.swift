import AdventOfCode

extension Array where Element: Equatable {
  func lengthOfRun(atIndex index: Index) -> Int {
    assert(indices.contains(index))

    let item = self[index]
    var index = self.index(after: index)
    var length = 1

    while index != self.endIndex && self[index] == item {
      length += 1
      index = self.index(after: index)
    }

    return length
  }
}

extension Int {
  var digits: [Int] {
    assert(self > 0)

    var i = self
    var result = [Int]()
    while i > 0 {
      result.insert(i % 10, at: 0)
      i /= 10
    }

    return result
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
      if digits[i] > digits[i + 1] { return false }
      let lengthOfRun = digits.lengthOfRun(atIndex: i)
      if lengthOfRun == 2 { hasPair = true }
      i += Swift.max(1, lengthOfRun - 1)
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

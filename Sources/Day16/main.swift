import AdventOfCode

func sequence(n: Int) -> DropFirstSequence<UnfoldSequence<Int,(UnfoldSequence<Int, Array<Int>.Index>,Int,Int)>> {
  let pattern = cycle([0, 1, 0, -1])
  var iterator = pattern.makeIterator()
  guard let first = iterator.next() else { fatalError() }
  let seq: DropFirstSequence<UnfoldSequence<Int,(UnfoldSequence<Int, Array<Int>.Index>,Int,Int)>> = 
    sequence(state: (iterator, first, n)) { 
      if $0.2 < 1 {
        $0.1 = $0.0.next()!
        $0.2 = n
      }
      $0.2 -= 1
      return $0.1
    }.dropFirst()
  return seq
}

func calculate(input: [Int]) -> [Int] {
  (1...input.count).map { n in
    return abs(zip( input, sequence(n: n) ).reduce(into: 0) { $0 += ($1.0 * $1.1) }) % 10
  }
}

let input = readLine(strippingNewline: true)!.map { Int($0.unicodeScalars.first!.value) - 0x30 }
let part1: [Int] = Array(sequence(state: input, next: { (n: inout [Int]) in
  n = calculate(input: n)
  return n 
}).dropFirst(99).prefix(1))[0]
print("part1", part1[0..<8].map { String($0) }.joined())

func calculate(offset: Int, input: [Int]) -> [Int] {
  var output = input
  for i in (offset..<(output.count-1)).reversed() {
    output[i] = (output[i] + output[i+1]) % 10
  }
  return output
}

let offset = Int(input.prefix(7).map{String($0)}.joined())!

// probably a better way to do this.
var tmp = input
tmp.reserveCapacity(6_500_000)
for _ in 0..<9999 {
  tmp.append(contentsOf: input)
}

let part2: [Int] = Array(sequence(state: Array(tmp[offset...]), next: { (n: inout [Int]) in
  n = calculate(offset: 0, input: n)
  return n 
}).dropFirst(99).prefix(1))[0]
print("part2", part2[0..<8].map { String($0) }.joined())

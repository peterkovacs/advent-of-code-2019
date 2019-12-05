import AdventOfCode

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }

var part1 = CPU(program: program)
part1.exec() {1}

var part2 = CPU(program: program)
part2.exec() {5}

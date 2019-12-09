
import AdventOfCode

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }

var part1 = CPU(program: program, phase: 1)
part1.exec()
print(part1.state, part1.output)

var part2 = CPU(program: program, phase: 2)
part2.exec()
print(part2.state, part2.output)

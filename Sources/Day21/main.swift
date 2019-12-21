import AdventOfCode

let input = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
var part1 = CPU(program: input)

part1.ascii(input: """
NOT A T
NOT B J
OR T J
NOT C T
OR T J
AND D J
WALK

""")
part1.exec()
print(part1.ascii)
print("part1", part1.output.last!)

// ABCDEFGHI
//   .#   #
//  . #   #
// .  #   #
var part2 = CPU(program: input)
part2.ascii(input: """
NOT C T
AND D T
AND H T
NOT B J
AND D J
AND H J
OR T J
NOT A T
OR T J
RUN

""")
part2.exec()
print(part2.ascii)
print("part2", part2.output.last!)

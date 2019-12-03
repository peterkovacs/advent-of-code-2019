import AdventOfCode

var input = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
input[1] = 12
input[2] = 2

var part1 = CPU(program: input)
part1.exec()
print("part1", part1.program)

func part2(input: [Int]) -> Int {
  var input = input
  for noun in 0...99 {
    for verb in 0...99 {
      input[1] = noun
      input[2] = verb
      var cpu = CPU(program: input)

      cpu.exec()
      if cpu.program[0] == 19690720 {
        return 100 * noun + verb
      }
    }
  }

  return 0
}

print("part2", part2(input: input) )

import AdventOfCode

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }

let part1 = (0...4).permutations().map { input -> Int in
  var (a, b, c, d, e) = (CPU(program: program, phase: input[0]),
                         CPU(program: program, phase: input[1]), 
                         CPU(program: program, phase: input[2]), 
                         CPU(program: program, phase: input[3]), 
                         CPU(program: program, phase: input[4]))
  a.input.append(0)
  a.exec() { b.input.append($0) }
  b.exec() { c.input.append($0) }
  c.exec() { d.input.append($0) }
  d.exec() { e.input.append($0) }
  e.exec()
  return e.output.removeLast()
}.max()!

print("part1", part1)

let part2 = (5...9).permutations().map { input -> Int in
  var (a, b, c, d, e) = (CPU(program: program, phase: input[0]),
                         CPU(program: program, phase: input[1]), 
                         CPU(program: program, phase: input[2]), 
                         CPU(program: program, phase: input[3]), 
                         CPU(program: program, phase: input[4]))
  a.input.append(0)

  while !a.isHalted && !b.isHalted && !c.isHalted && !d.isHalted && !e.isHalted {
    a.exec() { b.input.append($0) }
    b.exec() { c.input.append($0) }
    c.exec() { d.input.append($0) }
    d.exec() { e.input.append($0) }
    e.exec() { a.input.append($0) }
  }

  return a.input.removeLast()
}.max()!

print("part2", part2)

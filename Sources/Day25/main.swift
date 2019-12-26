import AdventOfCode
import Foundation

guard CommandLine.arguments.count > 1 else { fatalError() }

var cpu = CPU.load(URL(fileURLWithPath: CommandLine.arguments[1]))

while !cpu.isHalted {
  if cpu.isBlocked {
    guard let input = readLine(strippingNewline: false) else { exit(0) }
    cpu.ascii(input: input)
  }

  cpu.exec()
  print(cpu.ascii)
  cpu.output.removeAll()
}

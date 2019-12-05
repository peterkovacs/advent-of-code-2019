import Foundation

public struct CPU {
  private var pc = 0
  public var program: [Int]

  public init(program: [Int]) {
    self.program = program
  }

  public mutating func exec() {
    while true {
      switch program[pc] {
      case 1:
        let store = program[pc + 3]
        let a = program[pc + 1]
        let b = program[pc + 2]
        program[store] = program[a] + program[b]
        pc += 4
      case 2:
        let store = program[pc + 3]
        let a = program[pc + 1]
        let b = program[pc + 2]
        program[store] = program[a] * program[b]
        pc += 4
      case 99:
        return
      default:
        fatalError()
      }
    }
  }

  public mutating func exec(input: () -> Int) {
    while true {
      switch decode( op: program[pc] ) {
      case 1:
        store( op: program[pc], offset: 3, value: value(op: program[pc], offset: 1) + value(op: program[pc], offset: 2))
        pc += 4
      case 2:
        store( op: program[pc], offset: 3, value: value(op: program[pc], offset: 1) * value(op: program[pc], offset: 2))
        pc += 4
      case 3:
        store( op: program[pc], offset: 1, value: input() )
        pc += 2
      case 4:
        print(value(op: program[pc], offset: 1))
        pc += 2

      case 5:
        if value(op: program[pc], offset: 1) != 0 {
          pc = value(op: program[pc], offset: 2)
        } else {
          pc += 3
        }

      case 6:
        if value(op: program[pc], offset: 1) == 0 {
          pc = value(op: program[pc], offset: 2)
        } else {
          pc += 3
        }

      case 7:
        let val = value(op: program[pc], offset: 1) < value(op: program[pc], offset: 2) ? 1 : 0
        store(op: program[pc], offset: 3, value: val)
        pc += 4

      case 8:
        let val = value(op: program[pc], offset: 1) == value(op: program[pc], offset: 2) ? 1 : 0
        store(op: program[pc], offset: 3, value: val)
        pc += 4

      case 99:
        return
      default:
        fatalError("illegal instruction @ \(pc), \(program[pc]) \(decode(op: program[pc]))")
      }
    }
  }

  func decode(op: Int) -> Int { op % 100 }

  func value(op: Int, offset: Int) -> Int {
    // offset is 1 (-> X00), 2 (-> X000), 3 (-> X0000)
    if (op / (10 * Int(pow(10.0, Double(offset)))) % 10) == 1 {
      // immediate mode.
      return program[pc + offset]
    } else {
      // position mode
      return program[ program[ pc + offset] ]
    }
  }

  mutating func store(op: Int, offset: Int, value: Int) {
    guard (op / (10 * Int(pow(10.0, Double(offset)))) % 10) == 0 else { fatalError("store to immediate mode?") }

    program[ program[pc + offset] ] = value
  }
}

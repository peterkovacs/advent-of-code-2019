import Foundation

public struct CPU {
  public enum State {
    case running
    case blocked
    case halted
  }

  private var pc = 0
  public var program: [Int]

  public var input: [Int] = []
  public var output: [Int] = []
  public var state: State = .running

  public init(program: [Int], phase: Int? = nil) {
    self.program = program
    if let phase = phase { input.append(phase) }
  }

  public var isBlocked: Bool { state == .blocked }
  public var isHalted: Bool { state == .halted }

  public mutating func exec(output: ((Int) -> ())? = nil) {
    while true {
      switch decode( op: program[pc] ) {
      case 1:
        store( op: program[pc], offset: 3, value: value(op: program[pc], offset: 1) + value(op: program[pc], offset: 2))
        pc += 4
      case 2:
        store( op: program[pc], offset: 3, value: value(op: program[pc], offset: 1) * value(op: program[pc], offset: 2))
        pc += 4
      case 3:
        if input.isEmpty {
          state = .blocked
          return 
        }
        store( op: program[pc], offset: 1, value: input.removeFirst() )
        pc += 2
      case 4:
        let val = value(op: program[pc], offset: 1)

        if let output = output { output(val) } 
        else { self.output.append(val) }

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
        state = .halted
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

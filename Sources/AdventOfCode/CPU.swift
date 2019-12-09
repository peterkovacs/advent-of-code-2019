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
  public var base: Int = 0

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

      case 9:
        let val = value(op: program[pc], offset: 1)
        base += val
        pc += 2

      case 99:
        state = .halted
        return 
      default:
        fatalError("illegal instruction @ \(pc), \(program[pc]) \(decode(op: program[pc]))")
      }
    }
  }

  func decode(op: Int) -> Int { op % 100 }

  mutating func value(op: Int, offset: Int) -> Int {
    // offset is 1 (-> X00), 2 (-> X000), 3 (-> X0000)
    switch (op / (10 * Int(pow(10.0, Double(offset)))) % 10) {
    case 0:
      // position mode
      let index = program[pc + offset]
      reserve(size: index)
      return program[ program[ pc + offset] ]
    case 1:
      // immediate mode.
      let index = pc + offset
      reserve(size: index)
      return program[pc + offset]
    case 2:
      // relative mode
      let index = base + program[pc + offset]
      reserve(size: index)
      return program[index]
    default:
      fatalError("unknown mode")
    }
  }

  mutating func reserve(size: Int) {
    while program.count < size + 1 {
      program.append(0)
    }
  }

  mutating func store(op: Int, offset: Int, value: Int) {
    switch (op / (10 * Int(pow(10.0, Double(offset)))) % 10) {
    case 0:
      let index = program[pc + offset] 
      reserve(size: index)
      program[index] = value
    case 1:
      fatalError("store to immediate mode?")
    case 2:
      let index = base + program[pc + offset]
      reserve(size: index)
      program[index] = value
    default:
      fatalError("unknown mode")
    }
  }
}

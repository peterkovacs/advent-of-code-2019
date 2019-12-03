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
}

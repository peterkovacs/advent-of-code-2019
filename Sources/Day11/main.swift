import AdventOfCode

enum Color {
  case unpainted
  case black
  case white
}

extension Color: CustomStringConvertible {
  var description: String {
    switch self {
    case .unpainted: return " "
    case .black: return " "
    case .white: return "#"
    }
  }
}

extension CPU {
  mutating func paint(grid: inout Grid<Color>, position: Coordinate) -> Grid<Color> {
    var direction = \Coordinate.up
    var position = position

    while !isHalted {
      input.append( grid[position] == .white ? 1 : 0 )
      exec()
      guard isBlocked else { break }

      let color = output.removeFirst()
      let turn = output.removeFirst()

      assert(output.isEmpty)

      grid[position] = color == 0 ? .black : .white

      if turn == 0 {
        direction = Coordinate.turn(left: direction)
      } else {
        direction = Coordinate.turn(right: direction)
      }

      position = position[keyPath: direction]
    }

    return grid
  }
}

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
var grid1 = Grid<Color>(Array(repeating: .unpainted, count: 120 * 120))!
var part1 = CPU(program: program)
let start = Coordinate(x: 60, y: 60)
print("part1", part1.paint(grid: &grid1, position: start).filter { $0 != .unpainted }.count )

var grid2 = Grid<Color>(Array(repeating: .unpainted, count: 120 * 120))!
grid2[start] = .white
var part2 = CPU(program: program)
print(part2.paint(grid: &grid2, position: start))

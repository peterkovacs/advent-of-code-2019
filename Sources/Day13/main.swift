import AdventOfCode

var program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
var part1 = CPU(program: program)

part1.exec()
print("part1", stride(from: part1.output.startIndex + 2, to: part1.output.endIndex, by: 3).filter { part1.output[$0] == 2 }.count)

struct Game {
  enum Element: Int { case empty, wall, block, paddle, ball }
  var grid: Grid<Element> = Grid(Array(repeating: .empty, count: 45 * 45))!

  var ball: Coordinate = .zero
  var paddle: Coordinate = .zero
  var score: Int = 0

  mutating func exec(output: inout [Int]) {
    let x = output.removeFirst()
    let y = output.removeFirst()

    if x == -1, y == 0 {
      score = output.removeFirst()
      return
    }

    let z = Element(rawValue: output.removeFirst() )!

    switch z {
    case .paddle:
      paddle = Coordinate(x: x, y: y)
    case .ball:
      ball = Coordinate(x: x, y: y)
    default:
      break
    }

    grid[x: x, y: y] = z
  }
}

extension Game.Element: CustomStringConvertible {
  var description: String {
    switch self {
    case .empty: return " "
    case .wall: return "█"
    case .block: return "#"
    case .paddle: return "▂"
    case .ball: return "•"
    }
  }
}

program[0] = 2
var part2 = CPU(program: program)
var game = Game()

while !part2.isHalted {
  part2.input.append( (game.ball.x - game.paddle.x).signum() )
  part2.exec()
  while !part2.output.isEmpty {
    game.exec(output: &part2.output)
  }
  // print(game.grid)
}

print("part2", game.score)

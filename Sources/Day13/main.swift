import AdventOfCode
import CoreGraphics
import Foundation

var program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
var part1 = CPU(program: program)

part1.exec()
print("part1", stride(from: part1.output.startIndex + 2, to: part1.output.endIndex, by: 3).filter { part1.output[$0] == 2 }.count)

struct Game {
  enum Element: Int { case empty, wall, block, paddle, ball }
  var grid: Grid<Element> = Grid.unbounded(default: .empty)

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

  var pixel: Pixel {
    switch self {
      case .empty: return Pixel(a: 0, r: 0, g: 0, b: 0)
      case .wall: return Pixel(a: 255, r: 255, g: 255, b: 255)
      case .block: return Pixel(a: 255, r: 255, g: 128, b: 128)
      case .paddle: return Pixel(a: 255, r: 128, g: 255, b: 128)
      case .ball: return Pixel(a: 255, r: 128, g: 255, b: 255)
    }
  }
}

extension Grid where T == Game.Element {
  func draw(context: CGContext) {
    let scaled = Grid(rectangle: self, width: width, height: height, transform: CGAffineTransform(scaleX: 0.1, y: 0.1).translatedBy(x: -5, y: -5))

    scaled.indices.forEach { 
      context[x: $0.x, y: $0.y] = scaled[$0].pixel 
    }
  }
}

program[0] = 2
var part2 = CPU(program: program)
var game = Game()
let animator = Animator(width: 480, height: 208, frameRate: 1.0 / 30, url: URL(fileURLWithPath: "day13.mov"))
while !part2.isHalted {
  part2.input.append( (game.ball.x - game.paddle.x).signum() )
  part2.exec()
  while !part2.output.isEmpty {
    game.exec(output: &part2.output)
  }
  animator.draw(callback: game.grid.draw)
}
animator.complete()

print("part2", game.score)

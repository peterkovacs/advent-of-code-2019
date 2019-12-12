import AdventOfCode
import CoreGraphics
import Foundation

enum Color {
  case unpainted
  case black
  case white
}

extension Color: CustomStringConvertible {
  var pixel: Pixel {
    switch self {
    case .white:
      return .white
    case .black:
      return .black
    case .unpainted:
      return Pixel(a: 0, r: 0, g: 0, b: 0)
    }
  }

  var description: String {
    switch self {
    case .unpainted: return " "
    case .black: return " "
    case .white: return "#"
    }
  }
}

extension CPU {
  mutating func paint(grid: inout Grid<Color>, position: Coordinate, animator: Animator? = nil) -> Grid<Color> {
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

      if let animator = animator {
        animator.draw { grid.draw(context: $0, scale: 4) { $0.pixel } }
      }

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

extension Grid {
  func draw(context: CGContext, scale: Int, withPixel: (T)->Pixel ) {
    let backgroundColor = CGColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
    let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)

    context.setFillColor(backgroundColor)
    context.fill(backgroundBounds)

    let scaled = Grid(self, transform: CGAffineTransform(scaleX: 1/CGFloat(scale), y: 1/CGFloat(scale)).translatedBy(x: -(CGFloat(scale)/2), y: -CGFloat(scale)/2))!
    
    iterate( 1..<(scale*count), and: 1..<(scale*count) ).forEach { x,y in 
      context[x: x, y: y] = withPixel(scaled[x: x, y: y])
    }
  }
}

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }
var grid1 = Grid<Color>(Array(repeating: .unpainted, count: 120 * 120))!
var part1 = CPU(program: program)
let start = Coordinate(x: 30, y: 60)
print("part1", part1.paint(grid: &grid1, position: start).filter { $0 != .unpainted }.count )

var grid2 = Grid<Color>(Array(repeating: .unpainted, count: 120 * 120))!
grid2[start] = .white
var part2 = CPU(program: program)
let animator = Animator.init(width: 480, height: 480, frameRate: 1.0 / 30, url: URL(fileURLWithPath: "day11.mpeg"))
print(part2.paint(grid: &grid2, position: start, animator: animator))
animator.complete()

let context = CGContext.square(size: 120 * 4)
grid2.draw(context: context, scale: 4) { 
  switch $0 {
  case .white:
    return .white
  case .black:
    return .black
  case .unpainted:
    return Pixel(a: 0, r: 0, g: 0, b: 0)
  }
}

context.save(to: URL(fileURLWithPath: "day11.png"))

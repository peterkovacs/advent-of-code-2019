import AdventOfCode

// enum State: Int {
//   case scaffold = 35
//   case space = 46 
//   case robotLeft = 60
//   case robotRight = 62
//   case robotUp = 94
//   case robotDown = 118
// }

enum State: Equatable {
  case scaffold
  case space
  case robot(Coordinate.Direction)
  case unknown(Character)

  static func parse(_ value: Int) -> Self {
    switch value {
      case 35: // #
        return .scaffold
      case 46: // .
        return .space
      case 60: // <
        return .robot(\Coordinate.left)
      case 62: // >
        return .robot(\Coordinate.left)
      case 94: // ^
        return .robot(\Coordinate.up)
      case 118: // ^
        return .robot(\Coordinate.down)
      default: 
        return .unknown(Character(Unicode.Scalar(UInt8(value))))
    }
  }
}

extension State: CustomStringConvertible {
  var description: String {
    switch self {
      case .scaffold: return "#"
      case .space: return "."
      case .robot(\Coordinate.right): return ">"
      case .robot(\Coordinate.left): return "<"
      case .robot(\Coordinate.up): return "^"
      case .robot(_): return "v"
      case .unknown(let c): return "\(c)"
    }
  }
}

enum Dir: Int {
  case left = 76
  case right = 82
}

struct Path: CustomStringConvertible {
  let direction: Dir
  var length: Int

  var description: String {
    switch direction {
      case .left: return "L,\(length)"
      case .right: return "R,\(length)"
    }
  }
}

extension Grid where Element == State {
  mutating func path(from: Coordinate, direction: Coordinate.Direction, segments: [Path]) -> [Path] {
    var segments = segments

    let straight = from[keyPath: direction]
    let left = from[keyPath: Coordinate.turn(left: direction)]
    let right = from[keyPath: Coordinate.turn(right: direction)]

    if straight.isValid(x: width, y: height), self[straight] == .scaffold {
      segments[ segments.count - 1 ].length += 1
      return path(from: straight, direction: direction, segments: segments)
    } else if left.isValid(x: width, y: height), self[left] == .scaffold {
      return path(from: left, direction: Coordinate.turn(left: direction), segments: segments.appending(Path(direction: .left, length: 1)))
    } else if right.isValid(x: width, y: height), self[right] == .scaffold {
      return path(from: right, direction: Coordinate.turn(right: direction), segments: segments.appending(Path(direction: .right, length: 1)))
    } else {
      return segments
    }
  }
}

var input = readLine(strippingNewline: true)!.split(separator: ",").map { Int($0)! }

func part1(input: [Int]) -> Grid<State> {
  var cpu = CPU(program: input)

  cpu.exec()
  let lines = cpu.output.split(separator: 10)
  let grid = Grid(rectangle: lines.joined().map { State.parse(Int($0)) }, width: lines[0].count, height: lines.count)

  print("part1", grid.indices.filter{ $0.neighbors(limitedBy: grid.width, and: grid.height).allSatisfy { grid[$0] == .scaffold } }.map { $0.x * $0.y }.sum() )
  return grid
}

var grid = part1(input: input)
print(grid.width, grid.height, grid.count)
let position = grid.indices.first(where: { if case .robot(_) = grid[$0] { return true } else { return false } })!
print(position)
// print(grid)
guard case .robot(let direction) = grid[position] else { fatalError() }
let path = grid.path(from: position, direction: direction, segments: [])
print(path, path.count)

// A=L,6, L,4, R,12, 
// B=L,6, R,12, R,12, L,8, 
// A=L,6, L,4, R,12, 
// C=L,6, L,10, L,10, L,6, 
// B=L,6, R,12, R,12, L,8, 
// A=L,6, L,4, R,12, 
// C=L,6, L,10, L,10, L,6, 
// B=L,6, R,12, R,12, L,8, 
// A=L,6, L,4, R,12, 
// C=L,6, L,10, L,10, L,6

func part2(input: [Int]) {
  let part2 = "A,B,A,C,B,A,C,B,A,C\nL,6,L,4,R,12\nL,6,R,12,R,12,L,8\nL,6,L,10,L,10,L,6\nn\n".map { Int($0.unicodeScalars.first!.value) }
  var cpu = CPU(program: input)
  cpu.input.append(contentsOf: part2)
  cpu.exec()
  print(cpu.state)
  let lines = cpu.output.prefix(45*41+40).split(separator: 10)
  let grid = Grid(rectangle: lines.joined().map { State.parse(Int($0)) }, width: 45, height: 41)
  print(grid)
  print("part2", cpu.output)
}

input[0] = 2
part2(input: input)

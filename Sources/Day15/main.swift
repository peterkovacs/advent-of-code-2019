import AdventOfCode
import Foundation

enum State: Int {
  case wall = 0
  case empty = 1
  case oxygenSystem = 2
  case unknown
  case bot
  case path
}

extension State: CustomStringConvertible {
  var description: String {
    switch self {
      case .empty, .unknown: return " "
      case .wall: return "█"
      case .oxygenSystem: return "🎰"
      case .bot: return "🤖"
      case .path: return "."
    }
  }
}

extension State: Drawable {
  var pixel: Pixel {
    switch self {
      case .empty: return .black
      case .wall: return .white
      case .oxygenSystem: return Pixel(a: 255, r: 255, g: 0, b: 0)
      case .bot: return Pixel(a: 255, r: 0, g: 255, b: 0)
      case .unknown: return Pixel(a: 0, r: 0, g: 0, b: 0)
      case .path: return Pixel(a: 255, r: 0, g: 0, b: 255)
    }
  }
}

enum Movement: Int, CaseIterable {
  case north = 1
  case south = 2
  case west = 3
  case east = 4
}

extension Coordinate {
  func move(_ direction: Movement) -> Coordinate {
    switch direction {
      case .north: return self.up
      case .south: return self.down
      case .east: return self.right
      case .west: return self.left
    }
  }

  func move(to: Coordinate) -> Movement {
    switch ((self.x - to.x), (self.y - to.y)) {
      case (1, 0): return .west
      case (-1, 0): return .east
      case (0, 1): return .north
      case (0, -1): return .south
      default: fatalError()
    }
  }
}

let program = readLine(strippingNewline: true)!.split(separator: ",").map{ Int($0)! }

extension Grid where Element == State {
  mutating func explore(from start: Coordinate) -> Coordinate {
    var result = Coordinate.zero
    var queue = [(0, start, CPU(program: program))]
    self[start] = .bot

    while !queue.isEmpty {
      let (distance, position, cpu) = queue.removeFirst()
    
      for i in position.neighbors where self[i] == .unknown {
        var cpu = cpu
        cpu.input.append(position.move(to: i).rawValue)
        cpu.exec()
        guard let state = State(rawValue: cpu.output.removeLast()) else { fatalError() }

        self[i] = state
        switch state {
        case .empty:
          queue.append((distance + 1, i, cpu))
        case .oxygenSystem:
          result = i
        case .wall, .unknown, .bot, .path:
          break
        }
      }
    }

    return result
  }

  func distance(from start: Coordinate, to: Coordinate) -> Int {
    var queue = [(0, start)]
    var visited = Set<Coordinate>([start])

    while !queue.isEmpty {
      let (distance, pos) = queue.removeFirst()

      for j in pos.neighbors where !visited.contains(j) && self[j] != .wall {
        visited.insert(j)
        if j == to {
          return distance + 1
        } 

        queue.append((distance + 1, j))
      }
    }

    return 0
  }

  mutating func fill(from start: Coordinate) -> Int {
    var queue = [(0, start)]
    var visited = Set<Coordinate>([start])
    var best = 0

    while !queue.isEmpty {
      let (distance, pos) = queue.removeFirst()
      for j in pos.neighbors where self.contains(index: j) && !visited.contains(j) && self[j] != .wall {
        visited.insert(j)

        if distance + 1 > best { 
          best = distance + 1 
        }
        queue.append((distance + 1, j))
      }
    }

    return best
  }
}

var grid = Grid<State>.unbounded(default: .unknown)
let destination = grid.explore(from: .zero)
grid.save(scale: 10.0, to: URL(fileURLWithPath: "day15.png"))
print("part1", grid.distance(from: .zero, to: destination))
print("part2", grid.fill(from: destination))

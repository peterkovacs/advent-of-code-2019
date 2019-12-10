import AdventOfCode
import Foundation

enum State: Equatable {
  case empty
  case asteroid
  case unknown
  indirect case scanned(State)
}

extension State: CustomStringConvertible {
  var description: String {
    switch self {
      case .empty: return "."
      case .asteroid: return "#"
      case .scanned(let s): return s.description
      case .unknown: return "?"
    }
  }
}

extension Grid where T == State {
  func visible(from: Coordinate) -> [Coordinate] {
    var grid = self
    var queue = [ from ]
    while !queue.isEmpty {
      let pos = queue.removeFirst()

      switch grid[pos] {
      case .scanned(_): continue
      case .empty:
        grid[pos] = .scanned(.empty)
      case .unknown:
        grid[pos] = .scanned(.unknown)
      case .asteroid:
        grid[pos] = .scanned(.asteroid)
        var encounteredAsteroid = false
        // once we hit an asteroid, everything behind it is unknown
        // we've already scanned the asteroid that caused this line.
        from.line(to: pos, limitedBy: count).forEach {
            if case .asteroid = grid[$0] { encounteredAsteroid = true }
            if encounteredAsteroid { grid[$0] = .scanned(.unknown) }
        }
      }

      queue.append(contentsOf: pos.neighbors8(limitedBy: count).filter { if case .scanned(_) = grid[$0] { return false } else { return true } } )
    }

    return grid.indices.filter { $0 != from && grid[$0] == .scanned(.asteroid) }
  }
}

let grid = Grid( stdin.joined().map { $0 == "#" ? State.asteroid : State.empty } )!.expand(default: .empty)
let coordinates: [Coordinate] = grid.indices.filter({ i in grid[i] == State.asteroid })
let (pos, visible) = coordinates.map({ ($0, grid.visible(from: $0)) }).max(by: { $0.1.count < $1.1.count })!
print("part1", pos - Coordinate(x: 1, y: 1), visible.count)

let angles = visible.map({ a -> (Coordinate, Coordinate, Double) in
  let dA = (a - pos)
  let result = atan2(Double(dA.x), Double(-dA.y))
  return ( a, dA, result < 0 ? result + .pi * 2 : result )
}).sorted(by: { $0.2 < $1.2 })

let (part2, _, _) = angles[199]
print("part2", part2 - Coordinate(x: 1, y: 1))

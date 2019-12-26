import AdventOfCode
import FootlessParser

enum Maze {
  case wall
  case path
  case label(Character)
  case outer(Coordinate)
  case inner(Coordinate)
}

extension Maze: CustomStringConvertible {
  var description: String {
    switch self {
      case .wall: return "#"
      case .path: return "."
      case .label(let c): return "\(c)"
      case .outer(_): return "^"
      case .inner(_): return "v"
    }
  }
}

extension Grid where Element == Maze {
  func findGate(position: Coordinate, direction: Coordinate.Direction, label: Character) -> (String, Coordinate)? {
    // because we're scanning top to bottom and left to right, we only need to
    // check below and to the right for the rest of the gate.

    let next = position[keyPath: direction]
    let nextnext = next[keyPath: direction]
    let prev = position[keyPath: Coordinate.turn(around: direction)]

    if next.isValid(x: width, y: height), case .label(let c) = self[next] {
      if nextnext.isValid(x: width, y: height), case .path = self[nextnext] {
        return ("\(label)\(c)", nextnext)
      }
      else {
        return ("\(label)\(c)", prev)
      }
    }

    return nil
  }

  func findGatePositions() -> [(String, Coordinate)] {
    var result = [(String, Coordinate)]()

    self.indices.forEach {
      switch self[$0] {
      case .label(let c):
        if let gate = findGate(position: $0, direction: \.right, label: c) ?? findGate(position: $0, direction: \.down, label: c) {
          result.append(gate)
        }
      case .outer(_), .inner(_), .wall, .path: break
      }
    }

    return result
  }

  mutating func placeGates() -> (Coordinate, Coordinate) {
    let positions = findGatePositions()

    self.indices.forEach { pos in
      switch self[pos] {
        case .label(let c):
          if let right = findGate(position: pos, direction: \.right, label: c),
             let pair = positions.first(where: { $0.0 == right.0 && $0.1 != right.1 }) {
            if !pos.right.right.isValid(x: width, y: height) || !pos.left.isValid(x: width, y: height) {
              self[pos]       = .outer(pair.1)
              self[pos.right] = .outer(pair.1)
            } else {
              self[pos]       = .inner(pair.1)
              self[pos.right] = .inner(pair.1)
            }
          }
          else if let down = findGate(position: pos, direction: \.down, label: c),
                  let pair = positions.first(where: { $0.0 == down.0 && $0.1 != down.1 }) {
            if !pos.down.down.isValid(x: width, y: height) || !pos.up.isValid(x: width, y: height) {
              self[pos]      = .outer(pair.1)
              self[pos.down] = .outer(pair.1)
            } else {
              self[pos]      = .inner(pair.1)
              self[pos.down] = .inner(pair.1)
            }
          }

        case .outer(_), .inner(_), .wall, .path: break
      }
    }

    return ( positions.first(where: { $0.0 == "AA" })!.1,
             positions.first(where: { $0.0 == "ZZ" })!.1 )
  }

  struct Key: Hashable { 
    let pos: Coordinate
    let level: Int
  }

  func shortestPath(from start: Coordinate, to destination: Coordinate) -> Int {
    var dist = [Key(pos: start, level: 0): 0]
    var nodes = Set([Key(pos: start, level: 0)])
    var visited = Set([Key(pos: start, level: 0)])

    while !nodes.isEmpty {
      guard let u = nodes.min(by: { dist[$0, default: Int.max] < dist[$1, default: Int.max]}) else { fatalError() }
      let distance = dist[u]!

      if destination == u.pos, u.level == 0 {
        // Calculate path.
        return distance
      }

      nodes.remove(u)

      let neighbors: [Key] = 
        u.pos.neighbors(limitedBy: self.width, and: self.height)
         .compactMap {
           if $0 == destination, u.level > 0 { return nil }

           switch self[$0] {
           case .outer(let c): 
            return u.level > 0 ? Key(pos: c, level: u.level - 1) : nil
           case .inner(let c): return u.level < 30 ? Key(pos: c, level: u.level + 1) : nil
           case .path: return Key(pos: $0, level: u.level)
           default: return nil
           }
         }

      for v in neighbors where visited.insert(v).inserted {
        nodes.insert(v)

        let alt = distance + 1
        if alt < dist[v, default: Int.max] {
          dist[v] = alt
        }
      }
    }

    return Int.max
  }

}

let parser = ({ _ in Maze.wall } <^> anyOf(" #")) <|> 
             ({ _ in Maze.path} <^> char(".")) <|> 
             ({ Maze.label($0) } <^> alphanumeric)
let input = Array(stdin)
var grid = Grid(rectangle: try parse( oneOrMore(parser), input.joined()), width: input[0].count, height: input.count )
let (start, end) = grid.placeGates()
print(grid)
print(start, end)

let part1 =
grid.shortestPath(from: start,
                  to: end,
                  neighbors: { coord in 
                    return coord.neighbors(limitedBy: grid.width, and: grid.height).compactMap {
                      switch grid[$0] {
                        case .outer(let c), .inner(let c): return c
                        case .path: return $0
                        default: return nil
                      }
                    }
                  }, 
                  isValid: { _, _ in return true })

print("part1", part1.count)
print("part2", grid.shortestPath(from: start, to: end))

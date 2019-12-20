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

  func shortestPath(from start: Coordinate, to end: Coordinate) -> Int {
    var queue = [(0, start, 0)]
    var visited = Set<Key>()
    var parents = [Coordinate: Coordinate]()

    while !queue.isEmpty {
      let (distance, i, level) = queue.removeFirst()

      let neighbors: [(Coordinate,Int)] = 
        i.neighbors(limitedBy: self.width, and: self.height)
         .compactMap {
           if $0 == end, level > 0 { return nil }

           switch self[$0] {
           case .outer(let c): 
            return level > 0 ? (c, -1) : nil
           case .inner(let c): return (c, 1)
           case .path: return ($0, 0)
           default: return nil
           }
         }

      for (j, levelStep) in neighbors {
        let newLevel = level + levelStep
        guard visited.insert(Key(pos: j, level: newLevel)).inserted else { continue }
        parents[j] = i

        if j == end, newLevel == 0 {
          return distance + 1
        }

        queue.append((distance + 1, j, newLevel))
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

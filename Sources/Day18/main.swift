import AdventOfCode
import FootlessParser

enum Maze {
  case wall
  case empty
  case entrance
  case key(Character)
  case door(Character)
}

extension Maze: CustomStringConvertible {
  var description: String {
    switch self {
      case .wall: return "#"
      case .empty: return " "
      case .entrance: return "@"
      case .key(let c): return "\(c)"
      case .door(let c): return "\(c)"
    }
  }
}

struct Memo: Hashable {
  let a: Coordinate
  let b: Coordinate
  let doors: Set<Character>
}
var visibleMemo = [Memo: Set<Character>]()
var stepsMemo = [Memo: Int?]()

extension Grid where T == Maze {
  var keyPositions: [Character: Coordinate] {
    return self.indices.reduce(into: [:]) {
      if case .key(let c) = self[$1] {
        $0[c] = $1
      }
    }
  }

  func keysVisible(from: Coordinate, doors: Set<Character>) -> Set<Character> {
    if let visible = visibleMemo[Memo(a: from, b: from, doors: doors)] {
      return visible
    }

    var visited = Set<Coordinate>()
    var result = Set<Character>()

    func dfs(from: Coordinate) {
      guard visited.insert(from).inserted else { return }

      for i in from.neighbors(limitedBy: width, and: height) {
        switch self[i] {
        case .empty, .entrance: dfs(from: i)
        case .key(let c): 
          result.insert(c)
          dfs(from: i)
        case .door(let c):
          guard let l = c.lowercased().first else { fatalError() }
          guard doors.contains(c) || doors.contains(l) else { break }
          dfs(from: i)
        case .wall: break
        }
      }
    }

    dfs(from: from)
    result.subtract(doors)
    visibleMemo[Memo(a: from, b: from, doors: doors)] = result
    return result
  }

  func shortestPath(from: Coordinate, to: Coordinate, keys: Set<Character>) -> Int? {
    if let steps = stepsMemo[Memo(a: from, b: to, doors: keys)] {
      return steps
    }

    let path = self.shortestPath(from: from, to: to) { 
      switch $1 {
      case .wall: return false
      case .empty, .entrance: return true
      case .door(let c): 
        guard let l = c.lowercased().first else { fatalError() }
        // If we hit a key we don't have, then this path isn't valid.
        return keys.contains(l) || keys.contains(c) 
      case .key(let c): 
        // If we hit a key we don't have, then this path isn't valid.
        return keys.contains(c)
      }
    }

    guard !path.isEmpty else { 
      stepsMemo[Memo(a: from, b: to, doors: keys)] = .some(nil)
      return nil 
    }

    stepsMemo[Memo(a: from, b: to, doors: keys)] = path.count
    return path.count
  }

  struct Visited: Hashable {
    let position: Coordinate
    let keys: Set<Character>
    let distance: Int
  }

  func bestKeyOrder(from position: Coordinate) -> ([Character], Int) {
    let positions = self.keyPositions
    var queue = [(position, [Character](), keysVisible(from: position, doors: Set()), 0)]
    var bestPath = [] as [Character]
    var bestDistance = Int.max // 4270
    var visited = Set<Visited>()

    while !queue.isEmpty {
      let (position, keys, visible, distance) = queue.removeFirst()
      guard visited.insert(Visited(position: position, keys: Set(keys), distance: distance)).inserted else { continue }

      for key in visible { 
        guard let newPosition = positions[key] else { fatalError() }
        let newKeys = keys.appending(key)
        let doors = Set(newKeys)
        guard let step = shortestPath(from: position, to: newPosition, keys: doors) else { continue }
        guard distance + step < bestDistance else { continue }

        if doors.count == positions.count {
          bestDistance = distance + step
          queue = queue.filter({ $0.3 < bestDistance })
          bestPath = newKeys
          print("FOUND PATH", newKeys, bestDistance, queue.count)
        } else {
          let visible = keysVisible(from: newPosition, doors: doors)
          if !visible.isEmpty {
            let index = queue.firstIndex(where: {
              $0.1.count < newKeys.count || ($0.1.count == newKeys.count && $0.3 > distance + step)
            })
            queue.insert((newPosition, newKeys, visible, distance + step), at: index ?? queue.endIndex)
          }
        }
      }
    }

    return (bestPath, bestDistance)
  }

  struct Visited4: Hashable {
    let position0: Coordinate
    let position1: Coordinate
    let position2: Coordinate
    let position3: Coordinate
    let keys: Set<Character>
    let distance: Int
  }

  func bestKeyOrder(from entrances: [Coordinate]) -> ([Character], Int) {
    let keyPositions = self.keyPositions
    var queue = [(entrances, [Character](), entrances.map { keysVisible(from: $0, doors: Set()) }, 0)]
    var bestPath = [Character]()
    var bestDistance = Int.max // 1982
    var visited = Set<Visited4>()

    while !queue.isEmpty {
      let (positions, keys, visibles, distance) = queue.removeFirst()
      guard visited.insert(Visited4(position0: positions[0], position1: positions[1], position2: positions[2], position3: positions[3], keys: Set(keys), distance: distance)).inserted else { continue }

      if visited.count % 1000 == 0 {
        print("VISITED", visited.count, queue.count)
      }

      for order in (0..<4).permutations() {
        for (i, position, visible) in zip( order, order.map{ positions[$0] }, order.map{ visibles[$0] } ) {
          for key in visible {
            guard let newPosition = keyPositions[key] else { fatalError() }
            let newKeys = keys.appending(key)
            let doors = Set(newKeys)
            guard let step = shortestPath(from: position, to: newPosition, keys: doors) else { continue }
            guard distance + step < bestDistance else { continue }

            if doors.count == keyPositions.count { 
              bestDistance = distance + step
              queue = queue.filter({ $0.3 < bestDistance })
              bestPath = newKeys
              print("FOUND PATH", newKeys, bestDistance, queue.count)
            } else {
              var (positions, visibles) = (positions, visibles)
              positions[i] = newPosition
              visibles = positions.map { keysVisible(from: $0, doors: doors) }
              guard !visibles.allSatisfy({ $0.isEmpty }) else { 
                continue 
              }

              let index = queue.firstIndex(where: {
                $0.1.count < newKeys.count || ($0.1.count == newKeys.count && $0.3 > distance + step)
              })
              queue.insert((positions, newKeys, visibles, distance + step), at: index ?? queue.endIndex)
          }
        }
      }
    }
  }

    return (bestPath, bestDistance)
  }
}

let keys = "abcdefghijklmnopqrstuvwxyz"
let parser = ({ _ in Maze.wall } <^> char("#")) <|> 
             ({ _ in Maze.empty} <^> char(".")) <|> 
             ({ _ in Maze.entrance} <^> char("@")) <|> 
             ({ Maze.key($0) } <^> anyOf(keys)) <|> 
             ({ Maze.door($0) } <^> anyOf(keys.uppercased()))

let input = Array(stdin.map { $0 })
// let input = """
// #################
// #i.G..c...e..H.p#
// ########.########
// #j.A..b...f..D.o#
// ########@########
// #k.E..a...g..B.n#
// ########.########
// #l.F..d...h..C.m#
// #################
// """.split(separator: "\n")
let grid = Grid(rectangle: try parse( oneOrMore(parser), input.joined() ), width: input[0].count, height: input.count)
if CommandLine.arguments[1] == "1" {
  let entrance = grid.indices.first { if case .entrance = grid[$0] { return true } else { return false }}!
  print(grid.keysVisible(from: entrance, doors: Set()))
  print("part1", grid.bestKeyOrder(from: entrance))
} else if CommandLine.arguments[1] == "2" {
  let entrances = grid.indices.filter({ if case .entrance = grid[$0] { return true } else { return false }})
  print(grid.keyPositions, grid.keyPositions.count)
  print(Array(entrances.indices.permutations()))
  print(entrances)
  print(entrances.map { grid.keysVisible(from: $0, doors: Set()) })
  print("part2", grid.bestKeyOrder(from: entrances))
}

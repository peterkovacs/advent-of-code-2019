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

extension Grid where T == Maze {
  var keyPositions: [Character: Coordinate] {
    return self.indices.reduce(into: [:]) {
      if case .key(let c) = self[$1] {
        $0[c] = $1
      }
    }
  }

  func keysVisible(from: Coordinate, doors: Set<Character>) -> Set<Character> {
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
    return result
  }

  func shortestPath(from: Coordinate, to: Coordinate, keys: Set<Character>) -> Int? {
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

    guard !path.isEmpty else { return nil }

    return path.count
  }

  func shortestPath(from: Coordinate, to: Coordinate) -> (Int, Set<Character>)? {
    let path = self.shortestPath(from: from, to: to) {
      switch $1 {
        case .wall: return false
        case .empty, .entrance, .door(_), .key(_): return true
      }
    }

    guard !path.isEmpty else { return nil }

    return (path.count, path.reduce(into: Set<Character>()) { 
      if case .door(let c) = self[$1], let lc = c.lowercased().first {
        $0.insert(lc)
      }
    })
  }

  struct Visited: Hashable {
    let position: Coordinate
    let keys: Set<Character>
  }

  func bestKeyOrder(from position: Coordinate) -> Int {
    let positions = self.keyPositions
    var queue = [ (position, Set<Character>(), keysVisible(from: position, doors: Set()), 0) ]
    queue.reserveCapacity(100)

    var bestDistance = Int.max // 4270
    var visited = Set<Visited>()

    let allKeys = Set(positions.keys)
    let distances = ([position] + positions.values).combinations(length: 2)
      .reduce(into: [Set<Coordinate>:Int]()) { (result, positions) in
        if let path = shortestPath(from: positions[0], to: positions[1], keys: allKeys) {
          result[Set(positions)] = path
        }
      }

    let keyVisibility = positions.mapValues { p in
      return 
        positions.values
          .filter { $0 != p }
          .reduce(into: [(Character, Set<Character>)]()) { 
            guard case .key(let c) = self[$1] else { fatalError() }
            if let (_, set) = shortestPath(from: p, to: $1) {
              $0.append((c, set))
            }
          }
    }

    while !queue.isEmpty {
      let (position, keys, visible, distance) = queue.removeFirst()
      // If we've been in this position with these keys, we've been here in fewer steps.
      guard visited.insert(Visited(position: position, keys: keys)).inserted else { continue }

      for key in visible { 
        guard let newPosition = positions[key] else { fatalError() }
        let newKeys = keys.union([key])
        let step = distances[Set([position, newPosition])]!

        guard distance + step < bestDistance else { continue }

        if newKeys.count == positions.count {
          bestDistance = distance + step
        } else {
          guard let visibility = keyVisibility[key] else { fatalError() }

          let newVisible = 
            Set(visibility
              .filter { $0.1.isSubset(of: newKeys) }
              .map { $0.0 })
            .subtracting(newKeys)

          if !newVisible.isEmpty {
            let index = queue.firstIndex { $0.3 > distance + step }
            queue.insert((newPosition, newKeys, newVisible, distance + step), at: index ?? queue.endIndex)
          }
        }
      }
    }

    // return (bestPath, bestDistance)
    return bestDistance
  }

  struct Visited4: Hashable {
    let position0: Coordinate
    let position1: Coordinate
    let position2: Coordinate
    let position3: Coordinate
    let keys: Set<Character>
  }

  func bestKeyOrder(from entrances: [Coordinate]) -> Int {
    let keyPositions = self.keyPositions
    var queue = [(entrances, Set<Character>(), entrances.map { keysVisible(from: $0, doors: Set()) }, 0)]
    var bestDistance = Int.max // 1982
    var bestPath = 0
    var visited = Set<Visited4>()

    let allKeys = Set(keyPositions.keys)
    let distances = (entrances + keyPositions.values).combinations(length: 2)
      .reduce(into: [Set<Coordinate>:Int]()) { (result, positions) in
        if let path = shortestPath(from: positions[0], to: positions[1], keys: allKeys) {
          result[Set(positions)] = path
        }
      }

    var pointsOfInterest = Array(keyPositions.values)
    pointsOfInterest.append(contentsOf: entrances)
    let keyVisibility = Dictionary(uniqueKeysWithValues: pointsOfInterest.map { (p: Coordinate) -> (Coordinate, [(Character, Set<Character>)]) in
      return (key: p, value: 
        keyPositions.values
          .filter { $0 != p }
          .reduce(into: [(Character, Set<Character>)]()) { 
            guard case .key(let c) = self[$1] else { fatalError() }
            if let (_, set) = shortestPath(from: p, to: $1) {
              $0.append((c, set))
            }
          }
      )
    })

    while !queue.isEmpty {
      let (positions, keys, visibles, distance) = queue.removeFirst()
      guard visited.insert(Visited4(position0: positions[0], position1: positions[1], position2: positions[2], position3: positions[3], keys: Set(keys))).inserted else { continue }

      // order only matters if positions in other 
      for order in (0..<4).permutations() {
        for (i, position, visible) in zip( order, order.map{ positions[$0] }, order.map{ visibles[$0] } ) {
          for key in visible {
            guard let newPosition = keyPositions[key] else { fatalError() }
            let newKeys = keys.union([key])
            let step = distances[Set([position, newPosition])]!

            guard distance + step < bestDistance else { continue }

            if newKeys.count > bestPath {
              bestPath = newKeys.count
              print("bestPath", bestPath, distance + step, queue.count)
            }

            if newKeys.count == allKeys.count { 
              bestDistance = distance + step
            } else {
              var (positions, visibles) = (positions, visibles)
              positions[i] = newPosition
              visibles = positions.map {
                guard let visibility = keyVisibility[$0] else { fatalError() }
                return Set(visibility
                  .filter { $0.1.isSubset(of: newKeys) }
                  .map { $0.0 })
                .subtracting(newKeys)
              }

              guard !visibles.allSatisfy({ $0.isEmpty }) else { 
                continue 
              }

              guard !visited.contains(Visited4(position0: positions[0], position1: positions[1], position2: positions[2], position3: positions[3], keys: Set(newKeys))) else { continue }
              let index = queue.firstIndex(where: { ( bestDistance == Int.max && $0.1.count < newKeys.count ) || $0.3 > distance + step })
              queue.insert((positions, newKeys, visibles, distance + step), at: index ?? queue.endIndex)
          }
        }
      }
    }
  }

    return bestDistance
  }
}

let keys = "abcdefghijklmnopqrstuvwxyz"
let parser = ({ _ in Maze.wall } <^> char("#")) <|> 
             ({ _ in Maze.empty} <^> char(".")) <|> 
             ({ _ in Maze.entrance} <^> char("@")) <|> 
             ({ Maze.key($0) } <^> anyOf(keys)) <|> 
             ({ Maze.door($0) } <^> anyOf(keys.uppercased()))

let input = Array(stdin.map { $0 })
let grid = Grid(rectangle: try parse( oneOrMore(parser), input.joined() ), width: input[0].count, height: input.count)

if CommandLine.arguments[1] == "1" {
  let entrance = grid.indices.first { if case .entrance = grid[$0] { return true } else { return false }}!
  print(grid.keysVisible(from: entrance, doors: Set()))
  print("part1", grid.bestKeyOrder(from: entrance))
} else if CommandLine.arguments[1] == "2" {
  let entrances = grid.indices.filter({ if case .entrance = grid[$0] { return true } else { return false }})
  print(entrances.map { grid.keysVisible(from: $0, doors: Set()) })
  print("part2", grid.bestKeyOrder(from: entrances))
}

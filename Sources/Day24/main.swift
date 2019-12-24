import AdventOfCode

enum Space: Character, CustomStringConvertible {
  case empty = "."
  case bug = "#"

  var description: String {
    return String(self.rawValue)
  }
}

extension Grid where Element == Space {
  func nbugs(at: Coordinate) -> Int {
    at.neighbors(limitedBy: width, and: height).reduce(into: 0, { if case .bug = self[$1] { $0 += 1 } } )
  }

  var next: Self {
    var result = Grid(square: self, count: self.width)
    for i in indices {
      switch self[i] {
      case .bug:
        result[i] = nbugs(at: i) == 1 ? .bug : .empty
      case .empty:
        let bugs = nbugs(at: i)
        result[i] = bugs == 1 || bugs == 2 ? .bug : .empty
      }
    }
    return result
  }

  var biodiversity: Int {
    indices.filter({ self[$0] == .bug }).reduce(0) { $0 + 1 << ($1.y*width + $1.x) }
  }
}

extension Dictionary where Key == Int, Value == Grid<Space> {
  var levels: Range<Int> { 
    guard let min = keys.min(), let max = keys.max() else { return 0..<0 }
    return (min - 1)..<(max + 2)
  }
  static let `default` = Grid<Space>(square: repeatElement(Space.empty, count: 25), count: 5)

  func nbugs(at: Coordinate, level: Int) -> Int {
    let (outer, current, inner) = (self[level - 1, default: Self.default], self[level, default: Self.default], self[level + 1, default: Self.default])
    return at.neighbors.reduce(into: 0) {
      switch( ($1.x, $1.y, at.x, at.y) ) {
      case (-1, _, _, _):
        if case .bug = outer[Coordinate(x: 1, y: 2)] { $0 += 1 }
      case (_, -1, _, _):
        if case .bug = outer[Coordinate(x: 2, y: 1)] { $0 += 1 }
      case (5, _, _, _):
        if case .bug = outer[Coordinate(x: 3, y: 2)] { $0 += 1 }
      case (_, 5, _, _):
        if case .bug = outer[Coordinate(x: 2, y: 3)] { $0 += 1 }
      case (2, 2, 2, 1):
        $0 += (0..<5).reduce(into: 0) { if case .bug = inner[Coordinate(x: $1, y: 0)] { $0 += 1 } }
      case (2, 2, 2, 3):
        $0 += (0..<5).reduce(into: 0) { if case .bug = inner[Coordinate(x: $1, y: 4)] { $0 += 1 } }
      case (2, 2, 1, 2):
        $0 += (0..<5).reduce(into: 0) { if case .bug = inner[Coordinate(x: 0, y: $1)] { $0 += 1 } }
      case (2, 2, 3, 2):
        $0 += (0..<5).reduce(into: 0) { if case .bug = inner[Coordinate(x: 4, y: $1)] { $0 += 1 } }
      default:
        if case .bug = current[$1] { $0 += 1 }
      }
    }
  } 

  var next: Self {
    var result = Self()
    for level in self.levels {
      var grid = Grid(square: self[level, default: Self.default], count: 5)
      for i in grid.indices {
        if i.x == 2, i.y == 2 { continue }
        switch grid[i] {
        case .bug:
          grid[i] = nbugs(at: i, level: level) == 1 ? .bug : .empty
        case .empty:
          let bugs = nbugs(at: i, level: level)
          grid[i] = bugs == 1 || bugs == 2 ? .bug : .empty
        }
      }
      if !grid.allSatisfy({ $0 == .empty }) {
        result[level] = grid
      }
    }
    return result
  }
}

let input = """
.#.##
..##.
##...
#...#
..###
""".split(separator: "\n")

let grid = Grid(square: input.joined().map { Space(rawValue: $0)! }, count: 5)
var set = Set<Grid<Space>>()
let part1 = Array(sequence(first: grid, next: { $0.next }).lazy.drop(while: { set.insert($0).inserted }).prefix(1)).first

print("part1", part1?.biodiversity as Any)

var recursive = [0: grid]
for _ in 0..<200 { recursive = recursive.next }
print(recursive.reduce(into: 0) { $0 += $1.value.reduce(into: 0) { if case .bug = $1 { $0 += 1 } } })

import Foundation
import CoreGraphics

public func gcd<T: FixedWidthInteger & SignedNumeric>(_ m: T, _ n: T) -> T {
    guard m >= 0, n >= 0 else { return gcd(abs(m), abs(n)) }
    guard m >= n else { return gcd(n, m) }

    let r = m % n
    if r != 0 {
        return gcd(n, r)
    } else {
        return n
    }
}

public struct Coordinate {
  public let x, y: Int
  public typealias Direction = KeyPath<Coordinate, Coordinate>

  public var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
  public var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
  public var up: Coordinate { return Coordinate( x: x, y: y - 1 ) }
  public var down: Coordinate { return Coordinate( x: x, y: y + 1 ) }
  public var neighbors: [Coordinate] { return [ up, left, right, down ] }

  public func neighbors(limitedBy: Int) -> [Coordinate] {
    return neighbors(limitedBy: limitedBy, and: limitedBy )
  }

  public func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
    return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) } 
  }

  public func isValid( x: Int, y: Int ) -> Bool {
    return self.x >= 0 && self.x < x && self.y >= 0 && self.y < y
  }

  public func neighbors( limitedBy: Int, traveling: Direction ) -> [Coordinate] {
    switch traveling {
    case \Coordinate.down, \Coordinate.up:
      return [ left, right ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    case \Coordinate.left, \Coordinate.right:
      return [ down, up ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    default: fatalError()
    }
  }

  public func neighbors8( limitedBy: Int ) -> [Coordinate] {
    return [ left, right, up, down, left.up, right.up, left.down, right.down ].filter { $0.isValid(x: limitedBy, y: limitedBy) }
  }

  public func line(to: Coordinate, limitedBy count: Int) -> [Coordinate] {
    guard self != to else { return [] }

    let direction = to - self
    if direction.x == 0 {
      // vertical line
      if direction.y < 0 { 
        return stride(from: self.y, through: 0, by: -1).dropFirst().map { Coordinate(x: self.x, y: $0) }
      } else { 
        return stride(from: self.y, to: count, by: 1).dropFirst().map { Coordinate(x: self.x, y: $0) }
      }
    } else if direction.y == 0 {
      // horizontal line
      if direction.x < 0 { 
        return stride(from: self.x, through: 0, by: -1).dropFirst().map { Coordinate(x: $0, y: self.y) } 
      } else { 
        return stride(from: self.x, to: count, by: 1).dropFirst().map { Coordinate(x: $0, y: self.y) } 
      }
    } else {
      let direction = direction / gcd(direction.x, direction.y)
      return zip( stride(from: self.x, to: direction.x < 0 ? -1 : count, by: direction.x), 
                  stride(from: self.y, to: direction.y < 0 ? -1 : count, by: direction.y ) )
             .dropFirst()
             .map { Coordinate(x: $0.0, y: $0.1) }
    }
  }
 
  public func direction(to: Coordinate) -> Direction {
    if abs(self.x - to.x) > abs(self.y - to.y) {
      return self.x > to.x ? \Coordinate.left : \Coordinate.right
    } else {
      return self.y > to.y ? \Coordinate.up : \Coordinate.down
    }
  }

  public init( x: Int, y: Int ) {
    self.x = x
    self.y = y
  }

  public static var zero: Coordinate = Coordinate(x: 0, y: 0)
}

public extension Coordinate {
  static func turn(left: Direction) -> Direction {
    switch left {
    case \Coordinate.down: return \Coordinate.right
    case \Coordinate.up: return \Coordinate.left
    case \Coordinate.right: return \Coordinate.up
    case \Coordinate.left: return \Coordinate.down
    default: return left
    }
  }
  static func turn(right: Direction) -> Direction {
    switch right {
    case \Coordinate.down: return \Coordinate.left
    case \Coordinate.up: return \Coordinate.right
    case \Coordinate.right: return \Coordinate.down
    case \Coordinate.left: return \Coordinate.up
    default: return right
    }
  }
  static func turn(around: Direction) -> Direction {
    switch around {
    case \Coordinate.down: return \Coordinate.up
    case \Coordinate.up: return \Coordinate.down
    case \Coordinate.right: return \Coordinate.left
    case \Coordinate.left: return \Coordinate.right
    default: return around
    }
  }
}

public struct Grid<T>: Sequence {

  public struct CoordinateIterator: Sequence, IteratorProtocol {
    let count: Int
    var coordinate: Coordinate

    public mutating func next() -> Coordinate? {
      if !coordinate.isValid( x: count, y: count ) {
        coordinate = Coordinate(x: 0, y: coordinate.y+1)
      }
      guard coordinate.isValid( x: count, y: count ) else { return nil }
      defer { coordinate = coordinate.right }

      return coordinate
    }
  }

  public struct Iterator: IteratorProtocol {
    let grid: Grid
    var iterator: CoordinateIterator

    public mutating func next() -> T? {
      guard let coordinate = iterator.next() else { return nil }
      return grid[ coordinate ]
    }
  }

  public typealias Element = T
  var grid: [Element]
  public let count: Int
  let transform: CGAffineTransform 

  public subscript( x x: Int, y y: Int ) -> Element {
    get { 
      let point = transform(x: x, y: y)
      return grid[ point.y * count + point.x ] 
    }
    set { 
      let point = transform(x: x, y: y)
      grid[ point.y * count + point.x ] = newValue 
    }
  }

  public subscript( _ c: Coordinate ) -> Element {
    get { return self[ x: c.x, y: c.y ] }
    set { self[ x: c.x, y: c.y ] = newValue }
  }

  public subscript( x x: CountableRange<Int>, y y: CountableRange<Int>) -> Grid<Element>? {
    guard x.count == y.count else { return nil }
    return Grid( zip( y, repeatElement( x, count: y.count ) ).lazy.flatMap{ outer in outer.1.map { inner in self[ x: inner, y: outer.0 ] } }, count: x.count, transform: .identity )
  }

  public init?<S: Sequence>( _ input: S, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = Int(Double(grid.count).squareRoot())
    self.transform = transform

    guard grid.count == count * count else { return nil }
  }

  public init?<S: Sequence>( _ input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count
    self.transform = transform

    guard grid.count == count * count else { return nil }
  }

  public init?<S: Sequence>( rotated input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count

    if (count % 2) == 1 {
      self.transform = transform
        .translatedBy(x: CGFloat(count/2), y: CGFloat(count/2))
        .rotated(by: .pi/2)
        .translatedBy(x: -CGFloat(count/2), y: -CGFloat(count/2))
    } else {
      // No idea why +1 needed, but even-count rotations don't line up without it.
      // Probably should've paid more attention in linear algebra
      self.transform = transform
        .translatedBy(x: CGFloat(count/2), y: CGFloat(count/2))
        .rotated(by: .pi/2)
        .translatedBy(x: -CGFloat(count/2), y: -CGFloat(count/2) + 1)
    }

    guard grid.count == count * count else { return nil }
  }

  public init?<S: Sequence>( mirrored input: S, count: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
    self.grid = Array(input)
    self.count = count
    self.transform = transform
      .scaledBy(x: -1, y: 1)
      .translatedBy(x: -CGFloat(count - 1), y: 0)

    guard grid.count == count * count else { return nil }
  }

  public var rotated: Grid {
    return Grid( rotated: grid, count: count, transform: transform )!
  }

  public var mirrored: Grid {
    return Grid( mirrored: grid, count: count, transform: transform )!
  }

  public func transform(x: Int, y: Int) -> Coordinate {
    let point = CGPoint(x: x, y: y).applying( self.transform ) 
    return Coordinate( x: Int(point.x.rounded()), y: Int(point.y.rounded()) )
  }

  public func makeIterator() -> Iterator {
    return Iterator(grid: self, iterator: CoordinateIterator(count: count, coordinate: Coordinate(x: 0, y: 0)))
  }

  public var indices: CoordinateIterator {
    return CoordinateIterator(count: count, coordinate: Coordinate(x: 0, y: 0))
  }

  public mutating func copy( grid: Grid<T>, origin: Coordinate ) {
    for y in origin.y..<(origin.y+grid.count) {
      for x in origin.x..<(origin.x+grid.count) {
        self[x: x, y: y] = grid[x: x - origin.x, y: y - origin.y]
      }
    }
  }
}

extension Grid where Grid.Element: Equatable {
  public static func ==(lhs: Grid, rhs: Grid) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return lhs.elementsEqual( rhs )
  }
}

extension Grid: CustomStringConvertible where Element: CustomStringConvertible {
  public var description: String {
    var result = ""
    for y in 0..<count {
      for x in 0..<count {
        result.append( self[x: x, y: y].description )
      }
      result.append("\n")
    }
    return result
  }
}

extension Coordinate: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(x << 32)
    hasher.combine(y & 0xffffffff)
  } 
}

extension Coordinate: CustomStringConvertible {
  public var description: String {
    return "(\(x), \(y))"
  }
}

extension Coordinate: Comparable {
  public static func <(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
  }
}

extension Coordinate: Equatable {
  public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.y == rhs.y && lhs.x == rhs.x
  }
}

public func -(lhs: Coordinate, rhs: Coordinate) -> Coordinate { 
  return Coordinate(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
  return Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func /(lhs: Coordinate, rhs: Int) -> Coordinate {
  guard lhs.x.isMultiple(of: rhs), lhs.y.isMultiple(of: rhs) else { fatalError() }

  return Coordinate(x: lhs.x / rhs, y: lhs.y / rhs)
}

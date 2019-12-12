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

  public init( x: Int, y: Int ) {
    self.x = x
    self.y = y
  }
}

public extension Coordinate {
  var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
  var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
  var up: Coordinate { return Coordinate( x: x, y: y - 1 ) }
  var down: Coordinate { return Coordinate( x: x, y: y + 1 ) }
  var neighbors: [Coordinate] { return [ up, left, right, down ] }

  func neighbors(limitedBy: Int) -> [Coordinate] {
    return neighbors(limitedBy: limitedBy, and: limitedBy )
  }

  func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
    return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) } 
  }

  func isValid( x: Int, y: Int ) -> Bool {
    return self.x >= 0 && self.x < x && self.y >= 0 && self.y < y
  }

  func neighbors( limitedBy: Int, traveling: Direction ) -> [Coordinate] {
    switch traveling {
    case \Coordinate.down, \Coordinate.up:
      return [ left, right ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    case \Coordinate.left, \Coordinate.right:
      return [ down, up ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
    default: fatalError()
    }
  }

  func neighbors8( limitedBy: Int ) -> [Coordinate] {
    return [ left, right, up, down, left.up, right.up, left.down, right.down ].filter { $0.isValid(x: limitedBy, y: limitedBy) }
  }

  func line(to: Coordinate, limitedBy count: Int) -> [Coordinate] {
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
 
  func direction(to: Coordinate) -> Direction {
    if abs(self.x - to.x) > abs(self.y - to.y) {
      return self.x > to.x ? \Coordinate.left : \Coordinate.right
    } else {
      return self.y > to.y ? \Coordinate.up : \Coordinate.down
    }
  }

  static var zero: Coordinate = Coordinate(x: 0, y: 0)
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

public struct Coord3D {
  public let x, y, z: Int

  public init(x: Int, y: Int, z: Int) {
    self.x = x
    self.y = y
    self.z = z
  }

  public static var zero: Coord3D = Coord3D(x: 0, y: 0, z: 0)
}

public extension Coord3D {
  static func -(lhs: Coord3D, rhs: Coord3D) -> Coord3D {
    Coord3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
  }

  static func +(lhs: Coord3D, rhs: Coord3D) -> Coord3D {
    Coord3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }

  var manhattan: Int { abs(x) + abs(y) + abs(z) }
}

extension Coord3D: Equatable, Hashable {}

extension Coord3D: CustomStringConvertible {
  public var description: String {
    return "(\(x), \(y), \(z))"
  }
}

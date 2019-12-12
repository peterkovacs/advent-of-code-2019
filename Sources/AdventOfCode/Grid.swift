import Foundation
import CoreGraphics

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

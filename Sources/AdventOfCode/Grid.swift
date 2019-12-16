import Foundation
import CoreGraphics

public struct Grid<T> {
  public typealias Element = T
  public fileprivate(set) var startIndex: Coordinate
  public fileprivate(set) var endIndex: Coordinate
  public fileprivate(set) var transform: CGAffineTransform

  fileprivate let index: (inout Self, Coordinate) -> Coordinate?
  fileprivate let `get`: (Coordinate) -> Element
  fileprivate let `set`: (Coordinate, Element) -> ()

  public var width: Int { abs(endIndex.x - startIndex.x) }
  public var height: Int { abs(endIndex.y - startIndex.y) }
  public var count: Int { width * height }

  public init<S: Sequence>(square input: S, count c: Int? = nil, transform: CGAffineTransform = .identity ) where S.Element == Element {
    var array = Array(input)
    let count = c ?? Int(Double(array.count).squareRoot())

    precondition(array.count == count * count, "\(array.count) is not \(count)*\(count)")

    self.startIndex = Self.transform(x: 0, y: 0, with: transform.inverted())
    self.endIndex = Self.transform(x: count, y: count, with: transform.inverted())

    self.transform = transform
    self.index = { $1.isValid(x: count, y: count) ? $1 : nil }
    self.get = { 
      precondition($0.isValid(x: count, y: count))
      return array[$0.x + $0.y * count] 
    }
    self.set = { 
      precondition($0.isValid(x: count, y: count))
      return array[$0.x + $0.y * count] = $1 
    }
  }

  public init<S: Sequence>(rectangle input: S, width: Int, height: Int, transform: CGAffineTransform = .identity) where S.Element == Element {
    var array = Array(input)
    precondition(array.count == width * height)

    self.transform = transform
    self.startIndex = Coordinate(x: 0, y: 0)
    self.endIndex = Coordinate(x: width, y: height)
    self.index = { $1.isValid(x: width, y: height) ? $1 : nil }
    self.get = { 
      precondition($0.isValid(x: width, y: height), "\($0) is out of bounds (\(width), \(height))")
      return array[$0.x + $0.y * width] 
    }
    self.set = { 
      precondition($0.isValid(x: width, y: height))
      return array[$0.x + $0.y * width] = $1 
    }
  }

  fileprivate init(startIndex: Coordinate, endIndex: Coordinate, transform: CGAffineTransform, index: @escaping (inout Self, Coordinate) -> Coordinate?, get: @escaping (Coordinate) -> Element, set: @escaping (Coordinate, Element) -> ()) {
    self.startIndex = startIndex
    self.endIndex = endIndex
    self.transform = transform
    self.index = index
    self.get = get
    self.set = set
  }

  public static func unbounded(default: Element, transform: CGAffineTransform = .identity) -> Self {
    var grid = [Coordinate: Element]()

    return Self(startIndex: Coordinate(x: 0, y: 0),
                endIndex: Coordinate(x: 0, y: 0),
                transform: transform, 
                index: { 
                  $0.startIndex = Coordinate(x: Swift.min($0.startIndex.x, $1.x), 
                                             y: Swift.min($0.startIndex.y, $1.y))
                  $0.endIndex = Coordinate(x: Swift.max($0.endIndex.x, $1.x + 1), 
                                           y: Swift.max($0.endIndex.y, $1.y + 1))
                  return $1
                },
                get: { grid[$0, default: `default`] }, 
                set: { grid[$0] = $1 })
  }

  public subscript(x x: Int, y y: Int) -> Element {
    get {
      let point = transform(x: x, y: y)
      return self.get(point)
    }
    set {
      if let point = self.index( &self, transform(x: x, y: y) ) {
        self.set(point, newValue)
      }
    }
  }

  public subscript(_ coordinate: Coordinate) -> Element {
    get { self[x: coordinate.x, y: coordinate.y] }
    set { self[x: coordinate.x, y: coordinate.y] = newValue }
  }

  private static func transform(x: Int, y: Int, with transform: CGAffineTransform) -> Coordinate {
    let point = CGPoint(x: x, y: y).applying( transform ) 
    return Coordinate( x: Int(point.x.rounded()), y: Int(point.y.rounded()) )
  }

  private func transform(x: Int, y: Int) -> Coordinate {
    return Self.transform(x: x, y: y, with: transform)

  }
}

extension Grid: Sequence {
  public struct CoordinateIterator: Sequence, IteratorProtocol {
    let startIndex: Coordinate
    let endIndex: Coordinate
    var coordinate: Coordinate

    init(grid: Grid) {
      self.startIndex = Grid.transform(x: grid.startIndex.x,
                                       y: grid.startIndex.y,
                                       with: grid.transform.inverted())
      self.endIndex = Grid.transform(x: grid.endIndex.x-1, 
                                     y: grid.endIndex.y-1,
                                     with: grid.transform.inverted()) 
                      + Coordinate(x: 1, y: 1)
      self.coordinate = self.startIndex
    }

    public mutating func next() -> Coordinate? {
      if coordinate.x >= endIndex.x {
        coordinate = Coordinate(x: startIndex.x, y: coordinate.y + 1)
      }
      if coordinate.y >= endIndex.y { return nil }
      defer { coordinate = coordinate.right }

      return coordinate
    }
  }

  public struct Iterator: IteratorProtocol {
    var grid: Grid
    var iterator: CoordinateIterator

    public mutating func next() -> Element? {
      guard let coordinate = iterator.next() else { return nil }
      return grid[coordinate]
    }
  }

  public func makeIterator() -> Iterator {
    return Iterator(grid: self, iterator: indices)
  }

  public var indices: CoordinateIterator {
    return CoordinateIterator(grid: self)
  }

  public func contains(index: Coordinate) -> Bool {
    (startIndex.x..<endIndex.x).contains(index.x) && 
    (startIndex.y..<endIndex.y).contains(index.y)
  }
}

extension Grid where Grid.Element: Equatable {
  public static func ==(lhs: Grid, rhs: Grid) -> Bool {
    guard lhs.startIndex == rhs.startIndex, lhs.endIndex == rhs.endIndex else { return false }
    return lhs.elementsEqual( rhs )
  }
}

extension Grid: CustomStringConvertible where Element: CustomStringConvertible {
  public var description: String {
    var result = ""
    result.reserveCapacity(count)
    for y in startIndex.y..<endIndex.y{
      for x in startIndex.x..<endIndex.x {
        result.append( self[x: x, y: y].description )
      }
      result.append("\n")
    }
    return result
  }
}

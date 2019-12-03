import AdventOfCode
import FootlessParser

let unit = { (\Coordinate.up, $0) }    <^> (char("U") *> ({ Int($0)! } <^> oneOrMore(digit))) <|>
           { (\Coordinate.down, $0) }  <^> (char("D") *> ({ Int($0)! } <^> oneOrMore(digit))) <|>
           { (\Coordinate.left, $0) }  <^> (char("L") *> ({ Int($0)! } <^> oneOrMore(digit))) <|>
           { (\Coordinate.right, $0) } <^> (char("R") *> ({ Int($0)! } <^> oneOrMore(digit))) 
let parser = oneOrMore(unit <* optional(char(",")))
let wires = stdin.map { try! parse(parser, $0)}
typealias Wire = [(KeyPath<Coordinate, Coordinate>, Int)]

extension Coordinate {
  var distance: Int { abs(x) + abs(y) }
}

extension Set where Element == Coordinate {
  mutating func populate(coordinate: Coordinate, keypath: KeyPath<Coordinate, Coordinate>, length: Int) -> Coordinate {
    let newCoordinate = coordinate[keyPath: keypath]
    insert(newCoordinate)

    if length > 1 {
      return populate(coordinate: newCoordinate, keypath: keypath, length: length - 1)
    } else {
      return newCoordinate
    }
  }

  func check(coordinate: Coordinate, keypath: KeyPath<Coordinate, Coordinate>, length: Int) -> (Coordinate, Int) {
    let newCoordinate = coordinate[keyPath: keypath]
    let distance: Int = contains(newCoordinate) ? newCoordinate.distance : Int.max

    if length > 1 {
      let result = check(coordinate: newCoordinate, keypath: keypath, length: length - 1)
      return (result.0, Swift.min(result.1, distance))
    } else {
      return (newCoordinate, distance)
    }
  }
}

func part1(wire a: Wire, wire b: Wire) -> Int {
  var grid = Set<Coordinate>()
  var position = Coordinate(x: 0, y: 0)

  for coordinate in a {
    position = grid.populate(coordinate: position, keypath: coordinate.0, length: coordinate.1)
  }

  var check = Coordinate(x: 0, y: 0)
  var minimum = Int.max
  for coordinate in b {
    let (newCoordinate, maybeMinimum) = grid.check(coordinate: check, keypath: coordinate.0, length: coordinate.1)
    check = newCoordinate
    if maybeMinimum < minimum {
      minimum = maybeMinimum
    }
  }

  return minimum
}

extension Dictionary where Key == Coordinate, Value == Int {
  mutating func populate(coordinate: Coordinate, direction: KeyPath<Coordinate, Coordinate>, steps: Int, length: Int) -> (Coordinate, Int) {
    let newCoordinate = coordinate[keyPath: direction]
    if self[newCoordinate] == nil {
      self[newCoordinate] = steps + 1
    }

    if length > 1 {
      return populate(coordinate: newCoordinate, direction: direction, steps: steps + 1, length: length - 1)
    } else {
      return (newCoordinate, steps + 1)
    }
  }

  func check(coordinate: Coordinate, direction: KeyPath<Coordinate, Coordinate>, steps: Int, length: Int) -> (Coordinate, Int, Int?) {
    let newCoordinate = coordinate[keyPath: direction]
    let otherSteps = self[newCoordinate]

    if length > 1 {
      let (result, newSteps, minimum) = check(coordinate: newCoordinate, direction: direction, steps: steps + 1, length: length - 1)

      switch (minimum, otherSteps) {
      case (.none, .none): return (result, newSteps, .none)
      case (.some(let x), .none): return (result, newSteps, x)
      case (.none, .some(let x)): return (result, newSteps, x + steps + 1)
      case (.some(let x), .some(let y)): return (result, newSteps, Swift.min(x, y + steps + 1))
      }

    } else {
      return (newCoordinate, steps + 1, otherSteps.map { $0 + steps + 1 })
    }
  }
}

func part2(wire a: Wire, wire b: Wire) -> Int {
  var grid = [Coordinate: Int]()
  var position = Coordinate(x: 0, y: 0)
  var steps = 0
  for coordinate in a {
    (position, steps) = grid.populate(coordinate: position, direction: coordinate.0, steps: steps, length: coordinate.1)
  }

  var check = Coordinate(x: 0, y: 0)
  var minimum = Int.max
  steps = 0
  for coordinate in b {
    let (newCoordinate, newSteps, maybeMinimum) = grid.check(coordinate: check, direction: coordinate.0, steps: steps, length: coordinate.1)
    check = newCoordinate
    steps = newSteps
    minimum = min(minimum, maybeMinimum ?? minimum)
  }

  return minimum
}

print("part1", part1(wire: wires[0], wire: wires[1]))
print("part2", part2(wire: wires[0], wire: wires[1]))

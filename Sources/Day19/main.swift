import AdventOfCode
import Foundation

let input = readLine(strippingNewline: true)!.split(separator: ",").map { Int($0)! }
func value(at: Coordinate) -> Int {
  var cpu = CPU(program: input)
  cpu.input.append(at.x)
  cpu.input.append(at.y)
  cpu.exec()
  return cpu.output[0]
}

var grid = Grid<Int>(rectangle: repeatElement(0, count: 50*50), width: 50, height: 50)
grid.indices.forEach {
  grid[$0] = value(at: $0)
}

print("part1", grid.filter({$0 == 1}).count)

let X = 100000
let topX = Double((30000...).first { value(at: Coordinate(x: X, y: $0)) == 1 }!)
let Y = 100000
let bottomY = Double((210000...).first { value(at: Coordinate(x: $0, y: Y)) == 1 }!)
let topSlope = -topX / Double(X)
let bottomSlope = -Double(Y) / bottomY

// I can only imagine that the a and b are necessary to help with some floating point error.
let x = Int((100.0 * topSlope - 100) / (bottomSlope - topSlope))
let y = -Int((-100.0 / bottomSlope + 100) / ((1.0 / topSlope) - (1.0 / bottomSlope)))

let (a, b) = iterate(0..<10, and: 0..<10).filter { (a, b) in 
  (x-a..<x-a+100).allSatisfy { value(at: Coordinate(x: $0, y: y - b)) == 1 } &&
  (y-b..<y-b+100).allSatisfy { value(at: Coordinate(x: x - a, y: $0)) == 1 }
}.max { $0.0+$0.1 < $1.0+$1.1 }!

print("part2", 10000 * (x-a) + (y-b))

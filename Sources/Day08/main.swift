import AdventOfCode
import Foundation
import Vision

let input = readLine(strippingNewline: true)!.map { Int($0.unicodeScalars.first!.value) -  0x30 }
let sizeOfLayer = 25*6
let numberOfLayers = input.count / sizeOfLayer
let layers = (0..<numberOfLayers).reduce(into: [Array<Int>]()) {
  $0.append( Array(input[ (sizeOfLayer*$1)..<(sizeOfLayer*($1+1)) ]) )
}

extension Array where Element == Int {
  func count(of val: Int) -> Int {
    reduce(into: 0) { if $1 == val { $0 += 1 } }
  }
}

if let part1 = layers.min(by: { $0.count(of: 0) < $1.count(of: 0) }).map( { $0.count(of: 1) * $0.count(of: 2)}) {
  print("part1", part1)
}

let context = CGContext.create(size: CGSize(width: 25, height: 6))
for layer in layers.reversed() {
  iterate(0..<25, and: 0..<6).forEach { x, y in
      switch( layer[x + y*25] ) {
      case 0: 
        context[x: x, y: y] = Pixel(a: 255, r: 0, g: 0, b: 0)
      case 1:
        context[x: x, y: y] = Pixel(a: 255, r: 255, g: 255, b: 255)
      default:
        break
      }
  }
}

context.save(to: URL(fileURLWithPath: "day08-part2.png"))

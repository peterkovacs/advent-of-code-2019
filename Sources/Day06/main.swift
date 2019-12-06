import AdventOfCode
import FootlessParser

struct Orbits {
  let orbits: [String: String]
  
  func count(object: String) -> Int {
    var object = object
    var count = 0

    while let orbiting = orbits[object] {
      object = orbiting
      count += 1
    }

    return count
  }

  func orbits(object: String) -> [String] {
    var result = [String]()
    var object = object
    while let orbiting = orbits[object] {
      result.append(orbiting)
      object = orbiting
    }
    return result
  }
}

let parser = tuple <^> count(3, any()) <*> (char(")") *> count(3, any()))
let input = stdin.map { try! parse( parser, $0 ) }
let orbits = Orbits(orbits: input.reduce(into: [String: String]()) { $0[ $1.1 ] = $1.0 })

let part1 = input.reduce(into: 0) { count, pair in 
  count += orbits.count(object: pair.1 )
}

print("part1", part1)

let you = orbits.orbits(object: "YOU")
let santa = orbits.orbits(object: "SAN")

let part2 = you.prefix { !santa.contains($0) }.count + santa.prefix { !you.contains($0) }.count
print("part2", part2)

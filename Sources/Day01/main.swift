import AdventOfCode
import FootlessParser

let input = stdin.map { Int($0)! }

let part1 = input.map { $0 / 3 - 2 }.sum()
print( "part 1", part1 )

func fuel(for val: Int) -> Int? {
  let mass = val / 3 - 2
  if mass < 0 {
    return nil
  } else { 
    return mass
  }
}

let part2 = input.flatMap { Array(sequence( first: fuel(for: $0)!, next: fuel )) }.sum()
print( "part 2", part2 )

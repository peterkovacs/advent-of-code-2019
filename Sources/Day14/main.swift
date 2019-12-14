import AdventOfCode
import FootlessParser

struct Reactant {
  var quantity: Int
  let symbol: String

  static func *(lhs: Reactant, rhs: Int) -> Reactant {
    Reactant(quantity: lhs.quantity * rhs, symbol: lhs.symbol)
  }
}

struct Reaction {
  var schedule = [String: (Int, [Reactant])]()
  var byproducts = [String: Int]()
}

extension Reaction {
  mutating func react(reactant: Reactant) -> Bool {
    let alreadyHave = byproducts[reactant.symbol, default: 0]

    // Do we already have enough byproducts for the request.
    guard alreadyHave < reactant.quantity else { 
      byproducts[reactant.symbol] = alreadyHave - reactant.quantity
      return true
    }

    if let (canMake, reagents) = schedule[reactant.symbol] {
      let need = reactant.quantity - alreadyHave
      let multiplier = (need / canMake) + (need % canMake).signum()
      byproducts[reactant.symbol] = 0

      if reagents.allSatisfy({ react(reactant: $0 * multiplier) }) {
        // Can create reagents, we're left with some remainder.
        byproducts[reactant.symbol] = (canMake * multiplier) - need
        return true
      }
    }

    // Unable to make reactant.quantity
    return false
  }
}

var reaction = Reaction(schedule: [:], byproducts: ["ORE": 1_000_000_000_000])

let chemical = curry(Reactant.init(quantity:symbol:)) <^> ({ Int($0)! } <^> oneOrMore(digit)) <*> (char(" ") *> oneOrMore(alphanumeric)) 
let parser = curry({ reaction.schedule[$1.symbol] = ($1.quantity, $0) }) <^> oneOrMore( chemical <* optional(string(", ")) ) <*> (string(" => ") *> chemical)
stdin.forEach { try! parse(parser, $0) }

if reaction.react(reactant: Reactant(quantity: 1, symbol: "FUEL")) {
  print("part1", 1_000_000_000_000 - reaction.byproducts["ORE", default: 0])
}

var count = 1
while( reaction.react(reactant: Reactant(quantity: 1, symbol: "FUEL")) ) { count += 1 }
print("part2", count)

import AdventOfCode
import ModularArithmetic
import FootlessParser
import Foundation
import BigInt

public enum Command {
  case reverse
  case deal(BigInt)
  case cut(BigInt)
}

extension Array where Element == Int {
  func apply(command: Command) -> Array<Int> {
    switch command {
    case .reverse:
      return Array(reversed())
    case .deal(let d):
      let mod = count
      let d = Int(d)
      return zip(indices, stride(from: startIndex, to: endIndex * d, by: d)).reduce(into: self) {
        $0[$1.1 % mod] = self[$1.0]
      }
    case .cut(let d) where d < 0:
      let d = Int(d) + count
      return Array(self[d...] + self[..<d])
    case .cut(let d) where d >= 0:
      let d = Int(d)
      return Array(self[d...] + self[..<d])
    default:
      fatalError("swift too dum to know i've covered every possibility.")
    }
  }
}

extension BigInt: ModularOperations {
  public func adding(_ other: BigInt, modulo: BigInt) -> BigInt {
    return (self + other).modulo(modulo)
  }

  public func subtracting(_ other: BigInt, modulo: BigInt) -> BigInt {
    return (self - other).modulo(modulo)
  }

  public func multiplying(_ other: BigInt, modulo: BigInt) -> BigInt {
    return (self * other).modulo(modulo)
  }
}

extension BigInt {
  func apply(commands: [Command], length: BigInt) -> BigInt {
    precondition((0..<length).contains(self))

    var next = self
    for command in commands.reversed() {
      switch command {
      case .reverse:
        next = (length - 1 - next)
      case .cut(var d):
        if d < 0 { d = length + d }
        if d >= next { next = next.subtracting( length - d, modulo: length ) }
        else { next = next.adding(d, modulo: length) }
      case .deal(let d):
        if next > 0 {
            // next == (x * d) mod length
            next = d.inverse(modulo: length)!
                      .multiplying(d + next, modulo: length)
                      .subtracting(1, modulo: length)
        } else {
            next = 0
        }
      }
    }

    return next
  }

}

let parser: Parser<Character, Command> = 
    ({ _ in Command.reverse } <^> string("deal into new stack")) <|>
  ({ Command.deal(BigInt($0)!) } <^> (string("deal with increment ") *> oneOrMore(digit))) <|>
   ({ Command.cut(BigInt($0)!) } <^> (string("cut ") *> oneOrMore(char("-") <|> digit)))

let input = try parse(oneOrMore(parser <* optional(char("\n"))), stdin.joined(separator: "\n"))
let result = input.reduce(Array(0..<10007)) { $0.apply(command: $1) }
print("part1", result.firstIndex(of: 2019)!)

// https://en.wikipedia.org/wiki/Linear_congruential_generator#c_≠_0
// X_{n+1}=(a X_{n} + b) mod {m}
// 107918735430368 = (a * 2020 + c) mod 119315717514047
// 9694310388107 = (a * 107918735430368 + b) mod 119315717514047
// a = 42907977848598, b = 57014396460530
// Nth = (a^n*2020 + c*(a^n - 1)/(a - 1)) mod 119315717514047
// Nth = (a^n*2020 + c*(a^n - 1)/(a - 1)) mod m
// Nth = (a^n*2020 + c*(a^n - 1)*(a - 1).inverse(m)) mod m

// print( "(a * 2020 + c) mod m = ", (2020.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))
// print( "(a * 107918735430368 + c) mod m = ", (107918735430368.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))
// print( "(a * 9694310388107 + c) mod m = ", (9694310388107.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))

let length = BigInt(119315717514047) 
let n      = BigInt(101741582076661)
var x      = BigInt(2020)
var y      = x.apply(commands: input, length: length)
var z      = y.apply(commands: input, length: length)
let a      = ((y - z) * (x - y + length).inverse(modulo: length)!).modulo(length)
let b      = (y - a * x).modulo(length)

// a^(n - 1) % n = 1, if n is prime and co-prime with a.
// inverse(a) = a^(n-2) mod n
assert(y == (x*a + b).modulo(length))
assert(z == (x*a*a + b*(a*a - 1)/(a - 1)).modulo(length))
print("part2", (x*a.power(n, modulus: length) + b*(a.power(n, modulus: length) - 1)*(a - 1).inverse(length)!).modulo(length))

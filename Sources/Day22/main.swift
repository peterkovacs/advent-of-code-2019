import AdventOfCode
import ModularArithmetic
import FootlessParser
import Foundation
import BigInt

public enum Command {
  case reverse
  case deal(Int)
  case cut(Int)
}

extension Array where Element == Int {
  func apply(command: Command) -> Array<Int> {
    switch command {
    case .reverse:
      return Array(reversed())
    case .deal(let d):
      let mod = count
      return zip(indices, stride(from: startIndex, to: endIndex * d, by: d)).reduce(into: self) {
        $0[$1.1 % mod] = self[$1.0]
      }
    case .cut(let d) where d < 0:
      let d = d + count
      return Array(self[d...] + self[..<d])
    case .cut(let d) where d >= 0:
      return Array(self[d...] + self[..<d])
    default:
      fatalError("swift too dum to know i've covered every possibility.")
    }
  }
}

struct Key: Hashable {
  let n, c: Int
}
var memo = [Key: Int]()

extension Int {
  func apply(commands: [Command], length: Int) -> Int {
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
  ({ Command.deal(Int($0)!) } <^> (string("deal with increment ") *> oneOrMore(digit))) <|>
   ({ Command.cut(Int($0)!) } <^> (string("cut ") *> oneOrMore(char("-") <|> digit)))

let input = try parse(oneOrMore(parser <* optional(char("\n"))), stdin.joined(separator: "\n"))
let result = input.reduce(Array(0..<10007)) { $0.apply(command: $1) }
print("part1", result.firstIndex(of: 2019)!)

// https://en.wikipedia.org/wiki/Linear_congruential_generator#c_≠_0
// X_{n+1}=(a X_{n} + c) mod {m}
// 107918735430368 = (a * 2020 + c) mod 119315717514047
// 9694310388107 = (a * 107918735430368 + c) mod 119315717514047
// a = 42907977848598, c = 57014396460530
// Nth = (a^n*2020 + c*(a^n - 1)/(a - 1)) mod 119315717514047
// Nth = (a^n*2020 + c*(a^n - 1)/(a - 1)) mod m; a = 42907977848598; n = 101741582076661; c = 57014396460530; m = 119315717514047

// print( "(a * 2020 + c) mod m = ", (2020.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))
// print( "(a * 107918735430368 + c) mod m = ", (107918735430368.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))
// print( "(a * 9694310388107 + c) mod m = ", (9694310388107.multiplying(42907977848598, modulo: 119315717514047).adding(57014396460530, modulo: 119315717514047) ))

// let start = Date()
// let a = 42907977848598 
// let c = 57014396460530 
// let seed = 2020 
// let aN = a.exponentiating(by: n, modulo: length)
// let part2 = (seed.multiplying(aN, modulo: length).adding(c.multiplying((aN - 1) / (a - 1), modulo: length), modulo: length))
// print(a, n, aN, seed.multiplying(aN, modulo: length), (aN - 1) / (a - 1), c.multiplying((aN - 1) / (a-1), modulo: length))
// print("part2", part2, Date().timeIntervalSince(start))

let length = 119315717514047 
let n      = 101741582076661
var x      = 2020
var y      = x.apply(commands: input, length: length)
var z      = y.apply(commands: input, length: length)
let a      = (y-z).multiplying( (x - y + length).inverse(modulo: length)!, modulo: length)
let b      = (y-a).multiplying( x, modulo: length )

print( x, y, z, a, b)
// let answer = (power(A, n, D) * X + (power(A, n, D) - 1) * primeModInverse(A - 1, D) * B) % D

let i = BigInt(a.exponentiating(by: n, modulo: length)) * BigInt(x)
let j = (BigInt(a.exponentiating(by: n, modulo: length) - 1))
let k = BigInt((a-1).inverse(modulo: length)!)
let part2: BigInt = ( i + j * k * BigInt(b)) % BigInt(length)

print( "part2", part2)

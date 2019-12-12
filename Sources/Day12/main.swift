import AdventOfCode
import Foundation

struct State: Hashable {
  let a, b, c, d: Moon

  init(moons: [Moon]) {
    a = moons[0]
    b = moons[1]
    c = moons[2]
    d = moons[3]
  }
}

struct Moon: Hashable {
  var pos: Coord3D
  var v: Coord3D
}

extension Moon: CustomStringConvertible {
  var description: String {
    "(pos: \(pos), v: \(v))"
  }
}

// var moons = [
//   Moon(pos: Coord3D(x:10, y:15, z:7), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:15, y:10, z:0), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:20, y:12, z:3), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:0, y:-3, z:13), v: Coord3D.zero )
// ]

// Example 1
// var moons = [
//   Moon(pos: Coord3D(x:-1, y:0, z:2), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:2, y:-10, z:-7), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:4, y:-8, z:8), v: Coord3D.zero ),
//   Moon(pos: Coord3D(x:3, y:5, z:-1), v: Coord3D.zero ),
// ]

// Example 2
var moons = [
  Moon(pos: Coord3D(x:-8, y:-10, z:0), v: Coord3D.zero),
  Moon(pos: Coord3D(x:5, y:5, z:10), v: Coord3D.zero),
  Moon(pos: Coord3D(x:2, y:-7, z:3), v: Coord3D.zero),
  Moon(pos: Coord3D(x:9, y:-8, z:-3), v: Coord3D.zero),
]

var states = Set<State>([State(moons: moons)])
states.reserveCapacity(10_000_000)

extension Coord3D {

  func gravity(_ rhs: Coord3D) -> Coord3D {
    let difference = self - rhs
    return Coord3D(
      x: -difference.x.signum(),
      y: -difference.y.signum(),
      z: -difference.z.signum()
    )
  }
}

var start = Date()
for iter in (1...) {

  moons[0].v = moons[0].v + 
    moons[0].pos.gravity(moons[1].pos) + 
    moons[0].pos.gravity(moons[2].pos) + 
    moons[0].pos.gravity(moons[3].pos)
  moons[1].v = moons[1].v + 
    moons[1].pos.gravity(moons[0].pos) + 
    moons[1].pos.gravity(moons[2].pos) + 
    moons[1].pos.gravity(moons[3].pos)
  moons[2].v = moons[2].v + 
    moons[2].pos.gravity(moons[0].pos) + 
    moons[2].pos.gravity(moons[1].pos) + 
    moons[2].pos.gravity(moons[3].pos)
  moons[3].v = moons[3].v + 
    moons[3].pos.gravity(moons[0].pos) + 
    moons[3].pos.gravity(moons[1].pos) + 
    moons[3].pos.gravity(moons[2].pos)

  for i in moons.indices { 
    moons[i].pos = moons[i].pos + moons[i].v 
  }

  if !states.insert(State(moons: moons)).inserted {
    print("part2", iter)
    break
  }

  if iter == 1000 {
    print("part1", moons.map{ $0.pos.manhattan * $0.v.manhattan }.sum() )
    print()
  }

  if iter % 100_000 == 0 {
    let now = Date()
    print(iter, now.timeIntervalSince(start)) 
    print(moons)
    start = now
  }
}

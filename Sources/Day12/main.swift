import AdventOfCode
import Foundation

struct State: Hashable {
  let ap, av, bp, bv, cp, cv, dp, dv: Int

  init(moons: [Moon], pos: KeyPath<Coord3D, Int>, v: KeyPath<Coord3D, Int>) {
    ap = moons[0].pos[keyPath: pos]
    av = moons[0].v[keyPath: v]
    bp = moons[1].pos[keyPath: pos]
    bv = moons[1].v[keyPath: v]
    cp = moons[2].pos[keyPath: pos]
    cv = moons[2].v[keyPath: v]
    dp = moons[3].pos[keyPath: pos]
    dv = moons[3].v[keyPath: v]
  }
}
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

struct Moon: Hashable {
  var pos: Coord3D
  var v: Coord3D
}

var moons = [
  Moon(pos: Coord3D(x:10, y:15, z:7), v: Coord3D.zero ),
  Moon(pos: Coord3D(x:15, y:10, z:0), v: Coord3D.zero ),
  Moon(pos: Coord3D(x:20, y:12, z:3), v: Coord3D.zero ),
  Moon(pos: Coord3D(x:0, y:-3, z:13), v: Coord3D.zero )
]

var stateX = [State(moons: moons, pos: \.x, v: \.x): 0]
var stateY = [State(moons: moons, pos: \.y, v: \.y): 0]
var stateZ = [State(moons: moons, pos: \.z, v: \.z): 0]

var start = Date()
var (cycleX, cycleY, cycleZ) = (nil as Int?, nil as Int?, nil as Int?)

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

  moons[0].pos = moons[0].pos + moons[0].v 
  moons[1].pos = moons[1].pos + moons[1].v 
  moons[2].pos = moons[2].pos + moons[2].v 
  moons[3].pos = moons[3].pos + moons[3].v 

  let x = State(moons: moons, pos: \.x, v: \.x)
  let y = State(moons: moons, pos: \.y, v: \.y)
  let z = State(moons: moons, pos: \.z, v: \.z)

  if cycleX == nil, let prev = stateX[x] { cycleX = iter - prev }
  if cycleY == nil, let prev = stateY[y] { cycleY = iter - prev }
  if cycleZ == nil, let prev = stateZ[z] { cycleZ = iter - prev }

  stateX[x] = iter
  stateY[y] = iter
  stateZ[z] = iter

  if let cycleX = cycleX, let cycleY = cycleY, let cycleZ = cycleZ {
    let tmp = cycleX * cycleY / gcd(cycleX, cycleY)
    let part2 = tmp * cycleZ / gcd(tmp, cycleZ)
    print("part2 \(part2)")
    break
  }

  if iter == 1000 {
    print("part1", moons.map{ $0.pos.manhattan * $0.v.manhattan }.sum() )
  }
}

import AdventOfCode

let input = [3,62,1001,62,11,10,109,2221,105,1,0,1423,980,1681,1205,918,1619,825,1382,1650,794,889,1524,1802,1464,1588,1495,1555,1135,2097,2155,668,856,1961,1998,1897,1837,1069,1283,633,1318,2186,1351,951,732,1172,763,1866,2031,571,1104,1009,1248,701,1040,600,1722,1930,1759,2126,2066,0,0,0,0,0,0,0,0,0,0,0,0,3,64,1008,64,-1,62,1006,62,88,1006,61,170,1106,0,73,3,65,20101,0,64,1,21001,66,0,2,21102,105,1,0,1105,1,436,1201,1,-1,64,1007,64,0,62,1005,62,73,7,64,67,62,1006,62,73,1002,64,2,132,1,132,68,132,1002,0,1,62,1001,132,1,140,8,0,65,63,2,63,62,62,1005,62,73,1002,64,2,161,1,161,68,161,1102,1,1,0,1001,161,1,169,102,1,65,0,1101,0,1,61,1101,0,0,63,7,63,67,62,1006,62,203,1002,63,2,194,1,68,194,194,1006,0,73,1001,63,1,63,1105,1,178,21101,210,0,0,106,0,69,2101,0,1,70,1101,0,0,63,7,63,71,62,1006,62,250,1002,63,2,234,1,72,234,234,4,0,101,1,234,240,4,0,4,70,1001,63,1,63,1106,0,218,1106,0,73,109,4,21102,1,0,-3,21102,1,0,-2,20207,-2,67,-1,1206,-1,293,1202,-2,2,283,101,1,283,283,1,68,283,283,22001,0,-3,-3,21201,-2,1,-2,1105,1,263,22102,1,-3,-3,109,-4,2105,1,0,109,4,21101,0,1,-3,21102,1,0,-2,20207,-2,67,-1,1206,-1,342,1202,-2,2,332,101,1,332,332,1,68,332,332,22002,0,-3,-3,21201,-2,1,-2,1105,1,312,22102,1,-3,-3,109,-4,2106,0,0,109,1,101,1,68,358,21002,0,1,1,101,3,68,367,20101,0,0,2,21102,376,1,0,1105,1,436,21202,1,1,0,109,-1,2106,0,0,1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648,4294967296,8589934592,17179869184,34359738368,68719476736,137438953472,274877906944,549755813888,1099511627776,2199023255552,4398046511104,8796093022208,17592186044416,35184372088832,70368744177664,140737488355328,281474976710656,562949953421312,1125899906842624,109,8,21202,-6,10,-5,22207,-7,-5,-5,1205,-5,521,21101,0,0,-4,21101,0,0,-3,21102,51,1,-2,21201,-2,-1,-2,1201,-2,385,470,21002,0,1,-1,21202,-3,2,-3,22207,-7,-1,-5,1205,-5,496,21201,-3,1,-3,22102,-1,-1,-5,22201,-7,-5,-7,22207,-3,-6,-5,1205,-5,515,22102,-1,-6,-5,22201,-3,-5,-3,22201,-1,-4,-4,1205,-2,461,1105,1,547,21102,-1,1,-4,21202,-6,-1,-6,21207,-7,0,-5,1205,-5,547,22201,-7,-6,-7,21201,-4,1,-4,1106,0,529,22102,1,-4,-7,109,-8,2105,1,0,109,1,101,1,68,563,21002,0,1,0,109,-1,2105,1,0,1102,1,73571,66,1102,1,1,67,1101,598,0,68,1101,0,556,69,1102,0,1,71,1102,1,600,72,1105,1,73,1,1051,1101,0,21391,66,1102,2,1,67,1102,627,1,68,1102,1,351,69,1102,1,1,71,1102,1,631,72,1106,0,73,0,0,0,0,255,5471,1102,99181,1,66,1102,1,1,67,1102,660,1,68,1101,0,556,69,1101,0,3,71,1101,0,662,72,1105,1,73,1,17,3,460765,45,30493,45,121972,1101,0,46399,66,1102,2,1,67,1102,1,695,68,1102,1,302,69,1101,1,0,71,1101,0,699,72,1106,0,73,0,0,0,0,24,22277,1102,1,8581,66,1101,1,0,67,1102,1,728,68,1102,556,1,69,1102,1,1,71,1102,1,730,72,1106,0,73,1,17710,2,138742,1101,0,10289,66,1102,1,1,67,1101,759,0,68,1101,0,556,69,1102,1,1,71,1102,761,1,72,1106,0,73,1,19,3,552918,1102,1,72053,66,1102,1,1,67,1102,790,1,68,1101,556,0,69,1102,1,1,71,1101,0,792,72,1106,0,73,1,-442,12,273759,1101,0,79159,66,1102,1,1,67,1102,821,1,68,1101,0,556,69,1102,1,1,71,1102,823,1,72,1106,0,73,1,11,37,72277,1102,77783,1,66,1101,0,1,67,1102,1,852,68,1101,556,0,69,1102,1,1,71,1102,854,1,72,1106,0,73,1,68,3,645071,1101,102769,0,66,1102,2,1,67,1102,1,883,68,1101,0,302,69,1101,0,1,71,1101,0,887,72,1105,1,73,0,0,0,0,27,5601,1102,1,24061,66,1102,1,1,67,1102,916,1,68,1102,1,556,69,1101,0,0,71,1101,918,0,72,1106,0,73,1,1035,1101,1487,0,66,1102,1,1,67,1101,0,945,68,1102,1,556,69,1102,1,2,71,1102,947,1,72,1106,0,73,1,10,22,79379,7,10002,1101,85451,0,66,1102,1,1,67,1101,0,978,68,1101,556,0,69,1101,0,0,71,1101,980,0,72,1106,0,73,1,1653,1101,653,0,66,1101,1,0,67,1101,1007,0,68,1102,556,1,69,1101,0,0,71,1102,1,1009,72,1106,0,73,1,1783,1101,0,79691,66,1101,1,0,67,1102,1036,1,68,1101,556,0,69,1101,1,0,71,1102,1,1038,72,1105,1,73,1,160,7,5001,1101,0,52153,66,1101,0,1,67,1101,0,1067,68,1101,556,0,69,1101,0,0,71,1102,1069,1,72,1105,1,73,1,1164,1102,373,1,66,1102,3,1,67,1101,0,1096,68,1101,0,302,69,1102,1,1,71,1101,0,1102,72,1105,1,73,0,0,0,0,0,0,17,125582,1101,11069,0,66,1101,1,0,67,1101,1131,0,68,1102,556,1,69,1101,0,1,71,1102,1133,1,72,1105,1,73,1,-30085,2,277484,1102,62791,1,66,1101,4,0,67,1101,0,1162,68,1102,1,253,69,1102,1,1,71,1102,1170,1,72,1105,1,73,0,0,0,0,0,0,0,0,44,21391,1101,47857,0,66,1101,1,0,67,1102,1199,1,68,1101,556,0,69,1102,2,1,71,1101,1201,0,72,1106,0,73,1,1,12,91253,45,60986,1101,0,92153,66,1101,7,0,67,1101,1232,0,68,1102,1,302,69,1102,1,1,71,1101,1246,0,72,1105,1,73,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,251164,1101,0,25873,66,1102,1,3,67,1101,1275,0,68,1101,0,302,69,1102,1,1,71,1101,0,1281,72,1106,0,73,0,0,0,0,0,0,17,188373,1102,1867,1,66,1102,1,3,67,1101,0,1310,68,1102,253,1,69,1101,0,1,71,1102,1316,1,72,1105,1,73,0,0,0,0,0,0,23,207902,1102,15461,1,66,1101,2,0,67,1102,1,1345,68,1102,1,302,69,1102,1,1,71,1102,1349,1,72,1106,0,73,0,0,0,0,17,62791,1102,21379,1,66,1102,1,1,67,1102,1,1378,68,1102,1,556,69,1101,1,0,71,1101,0,1380,72,1105,1,73,1,-72092,2,208113,1101,1667,0,66,1102,1,6,67,1101,1409,0,68,1102,1,302,69,1101,1,0,71,1101,0,1421,72,1106,0,73,0,0,0,0,0,0,0,0,0,0,0,0,44,42782,1102,1,5471,66,1101,1,0,67,1102,1450,1,68,1101,556,0,69,1101,0,6,71,1101,1452,0,72,1106,0,73,1,19665,29,30922,26,746,26,1119,41,25873,41,51746,41,77619,1101,66271,0,66,1101,0,1,67,1102,1,1491,68,1102,556,1,69,1102,1,1,71,1102,1493,1,72,1106,0,73,1,8231,12,182506,1101,99871,0,66,1101,1,0,67,1101,1522,0,68,1102,556,1,69,1102,1,0,71,1102,1,1524,72,1105,1,73,1,1448,1101,0,56999,66,1101,1,0,67,1101,1551,0,68,1101,556,0,69,1101,0,1,71,1101,1553,0,72,1105,1,73,1,125,22,317516,1101,0,59051,66,1101,1,0,67,1102,1582,1,68,1101,0,556,69,1102,2,1,71,1101,0,1584,72,1105,1,73,1,23,3,184306,21,205538,1101,37997,0,66,1102,1,1,67,1102,1615,1,68,1101,556,0,69,1101,0,1,71,1101,0,1617,72,1105,1,73,1,613,3,92153,1101,0,39887,66,1101,0,1,67,1102,1,1646,68,1101,556,0,69,1101,0,1,71,1102,1648,1,72,1105,1,73,1,3181,3,276459,1101,59999,0,66,1102,1,1,67,1102,1677,1,68,1101,556,0,69,1102,1,1,71,1102,1679,1,72,1106,0,73,1,218052,2,69371,1101,0,69371,66,1102,1,6,67,1101,1708,0,68,1102,253,1,69,1101,0,1,71,1101,1720,0,72,1105,1,73,0,0,0,0,0,0,0,0,0,0,0,0,21,102769,1101,30493,0,66,1101,0,4,67,1102,1749,1,68,1102,302,1,69,1102,1,1,71,1102,1,1757,72,1106,0,73,0,0,0,0,0,0,0,0,26,373,1102,80651,1,66,1102,1,1,67,1101,1786,0,68,1101,0,556,69,1102,1,7,71,1101,1788,0,72,1106,0,73,1,2,3,368612,20,92798,24,44554,23,103951,37,144554,7,3334,7,6668,1101,91253,0,66,1102,1,3,67,1101,1829,0,68,1102,302,1,69,1101,1,0,71,1102,1,1835,72,1106,0,73,0,0,0,0,0,0,27,3734,1102,1,48593,66,1102,1,1,67,1102,1,1864,68,1102,1,556,69,1101,0,0,71,1101,0,1866,72,1105,1,73,1,1286,1101,0,68261,66,1102,1,1,67,1102,1,1893,68,1101,0,556,69,1101,1,0,71,1101,1895,0,72,1105,1,73,1,71521,2,416226,1102,1,22277,66,1102,1,2,67,1102,1924,1,68,1101,0,302,69,1101,0,1,71,1101,0,1928,72,1106,0,73,0,0,0,0,27,1867,1101,0,93097,66,1101,0,1,67,1102,1,1957,68,1101,0,556,69,1101,0,1,71,1102,1,1959,72,1106,0,73,1,49331,2,346855,1101,79379,0,66,1101,0,4,67,1101,0,1988,68,1102,302,1,69,1101,0,1,71,1101,0,1996,72,1105,1,73,0,0,0,0,0,0,0,0,7,8335,1101,0,103951,66,1102,2,1,67,1102,1,2025,68,1102,302,1,69,1101,1,0,71,1101,0,2029,72,1106,0,73,0,0,0,0,37,216831,1102,1,72277,66,1102,1,3,67,1101,0,2058,68,1102,1,302,69,1102,1,1,71,1102,2064,1,72,1106,0,73,0,0,0,0,0,0,29,15461,1101,0,27691,66,1102,1,1,67,1102,2093,1,68,1101,0,556,69,1101,0,1,71,1102,2095,1,72,1106,0,73,1,5479541,20,46399,1101,0,48163,66,1101,1,0,67,1101,2124,0,68,1101,0,556,69,1102,0,1,71,1102,1,2126,72,1105,1,73,1,1954,1102,82193,1,66,1101,1,0,67,1101,2153,0,68,1101,556,0,69,1102,0,1,71,1102,2155,1,72,1105,1,73,1,1601,1102,101267,1,66,1101,0,1,67,1102,1,2182,68,1101,0,556,69,1102,1,1,71,1102,2184,1,72,1106,0,73,1,-114,45,91479,1102,41651,1,66,1101,1,0,67,1101,0,2213,68,1101,556,0,69,1101,0,3,71,1102,1,2215,72,1105,1,73,1,5,22,158758,22,238137,7,1667]
var cpus: [CPU] = (0..<50).map { return CPU(program: input, phase: $0) }

func assign(cpus: inout [CPU], address: Int, x: Int, y: Int) -> Bool {
  guard cpus.indices.contains(address) else { return true }

  cpus[address].input.append(x)
  cpus[address].input.append(y)
  return false
}

func part1(cpus: [CPU]) {
  var cpus = cpus

  while true { 
    for cpu in 0..<cpus.count {
      if cpus[cpu].isBlocked, cpus[cpu].input.isEmpty { cpus[cpu].input.append(-1) }
      cpus[cpu].exec()
      if cpus[cpu].output.count > 2 {
        let (address, x, y) = ( cpus[cpu].output.removeFirst(), cpus[cpu].output.removeFirst(), cpus[cpu].output.removeFirst() )
        if assign(cpus: &cpus, address: address, x: x, y: y) {
          print("part1", y)
          return
        }
      }
    }
  }
}

struct Pair: Hashable {
  let x, y: Int
}
func part2(cpus: [CPU]) {
  var sent = Set<Pair>()
  var nat = Pair(x: 0, y: 0)
  var cpus = cpus

  while true { 
    var blocked = true
    for cpu in 0..<cpus.count {
      if cpus[cpu].isBlocked, cpus[cpu].input.isEmpty { cpus[cpu].input.append(-1) }
      else { blocked = false }
    }

    if blocked {
      guard sent.insert(nat).inserted else {
        print("part2", nat.y)
        return
      }

      cpus[0].input.removeAll()
      cpus[0].input.append( nat.x )
      cpus[0].input.append( nat.y )
    }

    for cpu in 0..<cpus.count {
      cpus[cpu].exec()

      if cpus[cpu].output.count > 2 {
        let (address, x, y) = ( cpus[cpu].output.removeFirst(), cpus[cpu].output.removeFirst(), cpus[cpu].output.removeFirst() )

        if assign(cpus: &cpus, address: address, x: x, y: y) {
          nat = Pair(x: x, y: y)
        }
      }
    }
  }
}

part1(cpus: cpus)
part2(cpus: cpus)

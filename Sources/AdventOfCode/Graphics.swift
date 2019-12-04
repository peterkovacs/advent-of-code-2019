import CoreGraphics
import Foundation

public struct Pixel {
  public var a: UInt8
  public var r: UInt8
  public var g: UInt8
  public var b: UInt8

  public init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
    self.a = a
    self.r = r
    self.g = g
    self.b = b
  }
}

public extension CGRect {
  var area: CGFloat {
    return width * height
  }
}

public extension CGContext {
  static func create(size: CGSize) -> CGContext {
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue )!
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    return context
  }
  static func square(size: Int) -> CGContext {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue )!
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: 1, y: -1)
    return context
  }
  subscript(x x: Int, y y: Int) -> Pixel {
    get {
      let stride = bytesPerRow / MemoryLayout<Pixel>.size
      return data!.assumingMemoryBound(to: Pixel.self).advanced(by: stride * y + x ).pointee
    }
    set {
      let stride = bytesPerRow / MemoryLayout<Pixel>.size
      data!.assumingMemoryBound(to: Pixel.self).advanced(by: stride * y + x ).pointee = newValue
    }
  }

  subscript(x x: CGFloat, y y: CGFloat) -> Pixel {
    get {
      return self[x: Int(x.rounded()), y: Int(y.rounded())]
    }
    set {
       self[x: Int(x.rounded()), y: Int(y.rounded())] = newValue
    }
  }

  subscript(point: (CGFloat, CGFloat)) -> Pixel {
    get {
      return self[x: point.0, y: point.1]
    }
    set {
       self[x: point.0, y: point.1] = newValue
    }
  }

  subscript(point: (Int, Int)) -> Pixel {
    get {
      return self[x: point.0, y: point.1]
    }
    set {
      self[x: point.0, y: point.1] = newValue
    }
  }

  subscript(point: Coordinate) -> Pixel {
    get {
      return self[x: point.x, y: point.y]
    }
    set {
      self[x: point.x, y: point.y] = newValue
    }
  }

  subscript(rect: CGRect) -> [Pixel] {
    return iterate( Int(rect.minX)..<Int(rect.maxX), and: Int(rect.minY)..<Int(rect.maxY) ).map { self[$0] }
  }

  @discardableResult func save(to destinationURL: URL) -> Bool { 
    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false } 
    CGImageDestinationAddImage(destination, self.makeImage()!, nil) 
    return CGImageDestinationFinalize(destination) 
  }

}

public struct PixelIterator: IteratorProtocol {
  var x: Int = 0
  var y: Int = 0
  let context: CGContext

  public mutating func next() -> Pixel? {
    defer { 
      x += 1 
      if x >= context.width {
        x = 0
        y += 1
      }
    }

    guard y < context.height else { return nil }

    return context[x: x, y: y]
  }
}

extension CGContext: Sequence {
  public func makeIterator() -> PixelIterator {
    return PixelIterator(x: 0, y: 0, context: self)
  }
}

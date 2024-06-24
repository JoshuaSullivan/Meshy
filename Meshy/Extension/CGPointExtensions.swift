import CoreGraphics

public extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    func toUnitPoint(in size: CGSize, clampValues: Bool = false ) -> CGPoint {
        let px = x / size.width
        let py = y / size.height
        if clampValues {
            return CGPoint(x: max(0, min(1, px)), y: max(0, min(1, py)))
        } else {
            return CGPoint(x: px, y: py)
        }
    }
    
    func toScreenPoint(in size: CGSize, clampValues: Bool = false) -> CGPoint {
        let px = x * size.width
        let py = y * size.height
        if clampValues {
            return CGPoint(x: max(0, min(size.width, px)), y: max(0, min(size.height, py)))
        } else {
            return CGPoint(x: px, y: py)
        }
    }
    
    func rounded(screenScale: CGFloat) -> CGPoint {
        let px = round(x * screenScale) / screenScale
        let py = round(y * screenScale) / screenScale
        return CGPoint(x: px, y: py)
    }
    
    var simd2: SIMD2<Float> { SIMD2(x: Float(x), y: Float(y)) }
}

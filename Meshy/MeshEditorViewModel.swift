import SwiftUI
import Combine

@Observable
public final class MeshEditorViewModel {
    
    private static let allColors: [Color] = [
        .red, .green, .blue,
        .cyan, .pink, .yellow,
        .purple, .orange, .indigo
    ]
    
    public var width: Int
    public var height: Int
    private var points: [MeshGradient.BezierPoint] = []
    public var meshPoints: MeshGradient.Locations = .points([])
    public var colors: [Color] = []
    public var background: Color = .clear
    
    public var controlPointVMs: [ControlPointViewModel] = []
    
    private var rawPoints: [SIMD2<Float>] = []
    private var allColors: [Color]
    
    private var viewSize: CGSize?
    
    private var subs = Set<AnyCancellable>()
    
    public var useBezierHandles: Bool = false {
        didSet {
            controlPointVMs.forEach {
                $0.useBezierHandles = useBezierHandles
            }
            updateMeshPoints()
        }
    }
    
    init(width: Int = 3, height: Int = 4) {
        self.width = width
        self.height = height
        allColors = Self.allColors.shuffled()
        setupValues()
    }
    
    private func setupValues() {
        let dx: Float = 1 / Float(width - 1)
        let dy: Float = 1 / Float(height - 1)
        
        var points: [SIMD2<Float>] = []
        var colors: [Color] = []
                
        for y in (0..<height) {
            for x in (0..<width) {
                let px = Float(x) * dx
                let py = Float(y) * dy
                points.append(SIMD2<Float>(x: px, y: py))
                colors.append(allColors[y])
            }
        }
        self.rawPoints = points
        self.colors = colors
    }
    
    private func createControlPoints(viewSize: CGSize) {
        subs.removeAll()
        points = rawPoints.map { rawPoint in
            let top = offset(point: rawPoint, dx: 0, dy: -40, viewSize: viewSize)
            let leading = offset(point: rawPoint, dx: 40, dy: 0, viewSize: viewSize)
            let bottom = offset(point: rawPoint, dx: 0, dy: 40, viewSize: viewSize)
            let trailing = offset(point: rawPoint, dx: -40, dy: 0, viewSize: viewSize)
            return MeshGradient.BezierPoint(position: rawPoint, leadingControlPoint: leading, topControlPoint: top, trailingControlPoint: trailing, bottomControlPoint: bottom)
        }
        controlPointVMs = points.enumerated().map { index, point in
            let cpvm = ControlPointViewModel(index: index, color: colors[index], point: point, viewSize: viewSize)
            cpvm.useBezierHandles = useBezierHandles
            cpvm.location.sink { [weak self] index, bez in
                guard let self, index >= 0 else { return }
                self.points[index] = bez
                self.updateMeshPoints()
            }.store(in: &subs)
            cpvm.color.sink { [weak self] index, color in
                guard let self, index >= 0 else { return }
                self.colors[index] = color
            }.store(in: &subs)
            return cpvm
        }
        updateMeshPoints()
    }
    
    private func updateMeshPoints() {
        if useBezierHandles {
            meshPoints = .bezierPoints(points)
        } else {
            meshPoints = .points(points.map(\.position))
        }
    }
    
    private func offset(point: SIMD2<Float>, dx: CGFloat, dy: CGFloat, viewSize: CGSize) -> SIMD2<Float> {
        let udx = Float(dx / viewSize.width)
        let udy = Float(dy / viewSize.height)
        return SIMD2(x: point.x + udx, y: point.y + udy)
    }
    
    public func set(viewSize: CGSize) {
        self.viewSize = viewSize
        if controlPointVMs.isEmpty {
            createControlPoints(viewSize: viewSize)
        }
    }
}

private extension MeshGradient.BezierPoint {
    /// Creates an instance of BezierPoint where all of the control handles are equal to the position.
    init(position: CGPoint) {
        let p = position.simd2
        self.init(position: p, leadingControlPoint: p, topControlPoint: p, trailingControlPoint: p, bottomControlPoint: p)
    }
}

import SwiftUI
import Combine

@Observable
public final class ControlPointViewModel: Identifiable {
    
    public typealias LocationUpdate = (index: Int, location: MeshGradient.BezierPoint)
    public typealias ColorUpdate = (index: Int, color: Color)
    
    public var id: Int { index }
    
    public var location: AnyPublisher<LocationUpdate, Never> {
        _location.eraseToAnyPublisher()
    }
    
    private let _location = CurrentValueSubject<LocationUpdate, Never>((index: -1, location: .zero))
    
    public var color: AnyPublisher<ColorUpdate, Never> {
        _color.eraseToAnyPublisher()
    }
    
    private let _color = CurrentValueSubject<ColorUpdate, Never>((index: 0, color: .red))
    
    public let index: Int
    public var pointColor: Color {
        didSet {
            _color.send((index: index, color: pointColor))
        }
    }
    public let viewSize: CGSize
    public var position: CGPoint {
        didSet {
            updateValue()
        }
    }
    public private(set) var allowedEdges: [HandleEdge] = []
    public private(set) var allowedMovementAxes: [MovementAxis] = []
    
    public var top: CGPoint {
        didSet {
            updateValue()
        }
    }
    public var leading: CGPoint {
        didSet {
            updateValue()
        }
    }
    public var bottom: CGPoint {
        didSet {
            updateValue()
        }
    }
    public var trailing: CGPoint {
        didSet {
            updateValue()
        }
    }
    
    public var useBezierHandles: Bool = false
    
    public var showColorPicker: Bool = false
    
    public init(index: Int, color: Color, point: MeshGradient.BezierPoint, viewSize: CGSize) {
        self.index = index
        self.pointColor = color
        self.position = point.position.cgPoint
        self.viewSize = viewSize
        
        _color.value = (index: index, color: color)
        
        let screenScale = UIScreen.main.scale
        top = (point.topControlPoint - point.position).cgPoint.toScreenPoint(in: viewSize).rounded(screenScale: screenScale)
        leading = (point.leadingControlPoint - point.position).cgPoint.toScreenPoint(in: viewSize).rounded(screenScale: screenScale)
        bottom = (point.bottomControlPoint - point.position).cgPoint.toScreenPoint(in: viewSize).rounded(screenScale: screenScale)
        trailing = (point.trailingControlPoint - point.position).cgPoint.toScreenPoint(in: viewSize).rounded(screenScale: screenScale)
        
        let x = max(0, min(position.x, 1))
        let y = max(0, min(position.y, 1))
        
        if x == 0 {
            // Position is on left edge.
            if y != 0 && y != 1 {
                allowedEdges = [.leading]
                allowedMovementAxes = [.vertical]
            }
        } else if x == 1 {
            // Position is on right edge.
            if y != 0 && y != 1 {
                allowedEdges = [.trailing]
                allowedMovementAxes = [.vertical]
            }
        } else {
            // Position is somewhere in the middle horizontally.
            if y == 0 {
                // Position is on top edge.
                allowedEdges = [.bottom]
                allowedMovementAxes = [.horizontal]
            } else if y == 1 {
                // Position is on the bottom edge.
                allowedEdges = [.top]
                allowedMovementAxes = [.horizontal]
            } else {
                // Position is somewhere in the middle on both axes.
                allowedEdges = [.top, .leading, .bottom, .trailing]
                allowedMovementAxes = [.horizontal, .vertical]
            }
        }
        
        // Zero out the handles we won't use.
        HandleEdge.allCases.forEach { edge in
            guard !allowedEdges.contains(edge) else { return }
            switch edge {
            case .top: top = .zero
            case .leading: leading = .zero
            case .bottom: bottom = .zero
            case .trailing: trailing = .zero
            }
        }
    }
    
    private func updateValue() {
        let pos = position.simd2
        let pTop = pos + top.toUnitPoint(in: viewSize).simd2
        let pLeading = pos + leading.toUnitPoint(in: viewSize).simd2
        let pBottom = pos + bottom.toUnitPoint(in: viewSize).simd2
        let pTrailing = pos + trailing.toUnitPoint(in: viewSize).simd2
        let bez = MeshGradient.BezierPoint(position: pos, leadingControlPoint: pLeading, topControlPoint: pTop, trailingControlPoint: pTrailing, bottomControlPoint: pBottom)
        _location.send((index: index, location: bez))
    }
    
    public func controlPointTapped() {
        showColorPicker.toggle()
    }
}

private extension MeshGradient.BezierPoint {
    static let zero = MeshGradient.BezierPoint(position: .zero, leadingControlPoint: .zero, topControlPoint: .zero, trailingControlPoint: .zero, bottomControlPoint: .zero)
}

private extension SIMD2<Float> {
    static let zero = SIMD2(x: 0, y: 0)
    
    var cgPoint: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}

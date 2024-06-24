import SwiftUI

struct ControlPointView: View {
    
    @Bindable var viewModel: ControlPointViewModel
    
    @State private var startingpoint: CGPoint?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.useBezierHandles {
                    ForEach(viewModel.allowedEdges) { edge in
                        switch edge {
                        case .top:
                            BezierHandleView(edge: edge, value: $viewModel.top)
                                .offset(x: viewModel.top.x, y: viewModel.top.y)
                        case .leading:
                            BezierHandleView(edge: edge, value: $viewModel.leading)
                                .offset(x: viewModel.leading.x, y: viewModel.leading.y)
                        case .bottom:
                            BezierHandleView(edge: edge, value: $viewModel.bottom)
                                .offset(x: viewModel.bottom.x, y: viewModel.bottom.y)
                        case .trailing:
                            BezierHandleView(edge: edge, value: $viewModel.trailing)
                                .offset(x: viewModel.trailing.x, y: viewModel.trailing.y)
                        }
                    }
                }
                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.pointColor)
                    .stroke(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(12)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { dragValue in
                                guard !viewModel.allowedMovementAxes.isEmpty else { return }
                                if startingpoint == nil { startingpoint = viewModel.position }
                                guard let pos = startingpoint else { return }
                                let screenPos = pos.toScreenPoint(in: geometry.size)
                                let dx = viewModel.allowedMovementAxes.contains(.horizontal) ? dragValue.translation.width : 0
                                let dy = viewModel.allowedMovementAxes.contains(.vertical) ? dragValue.translation.height : 0
                                let dragPos = screenPos + CGSize(width: dx, height: dy)
                                viewModel.position = dragPos.toUnitPoint(in: geometry.size)
                            }
                            .onEnded { _ in startingpoint = nil }
                    )
                    .onTapGesture {
                        viewModel.controlPointTapped()
                    }
                    .padding(-12)
                
            }
            .position(viewModel.position.toScreenPoint(in: geometry.size))
            .sheet(isPresented: $viewModel.showColorPicker, content: {
                ColorPicker("Color for point \(viewModel.index)", selection: $viewModel.pointColor, supportsOpacity: false)
                    .presentationDetents([.height(100)])
                    .padding()
            })
        }
    }
    
    init(viewModel: ControlPointViewModel) {
        self.viewModel = viewModel
    }
}

//#Preview {
//    
//    GeometryReader { geom in
//        ZStack {
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .red, point: CGPoint(x: 0.0, y: 0.0), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .red, point: CGPoint(x: 0.5, y: 0.0), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .red, point: CGPoint(x: 1.0, y: 0.0), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .green, point: CGPoint(x: 0.0, y: 0.5), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .green, point: CGPoint(x: 0.5, y: 0.5), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .green, point: CGPoint(x: 1.0, y: 0.5), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .blue, point: CGPoint(x: 0.0, y: 1.0), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .blue, point: CGPoint(x: 0.5, y: 1.0), viewSize: geom.size))
//            ControlPointView(viewModel: ControlPointViewModel(index: 0, color: .blue, point: CGPoint(x: 1.0, y: 1.0), viewSize: geom.size))
//        }
//    }
//}

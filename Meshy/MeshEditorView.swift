import SwiftUI

struct MeshEditorView: View {
    
    @State private var viewModel: MeshEditorViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let _ = viewModel.set(viewSize: geometry.size)
            VStack {
                Picker("Control Mode", selection: $viewModel.useBezierHandles) {
                    Text("Simple").tag(false)
                    Text("Bezier").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ZStack {
                    MeshGradient(width: viewModel.width, height: viewModel.height, locations: viewModel.meshPoints, colors: .colors(viewModel.colors), background: viewModel.background)
                    ForEach(viewModel.controlPointVMs) { vm in
                        ControlPointView(viewModel: vm)
                    }
                }
            }
        }
    }
    
    init(viewModel: MeshEditorViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    var vm = MeshEditorViewModel()
    
    MeshEditorView(viewModel: vm)
}

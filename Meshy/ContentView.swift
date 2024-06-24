import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = MeshEditorViewModel()
    
    var body: some View {
        ZStack {
            MeshEditorView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}

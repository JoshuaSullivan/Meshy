import SwiftUI

struct BezierHandleView: View {
    
    let edge: HandleEdge
    
    @Binding var value: CGPoint
    
    @State var startingPosition: CGPoint?
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray)
                .stroke(Color.white)
            edge.symbol
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .fontWeight(.heavy)
                .scaleEffect(0.6)
        }
        .frame(width: 20, height: 20)
        .padding(12)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged({ dragValue in
                    if startingPosition == nil { startingPosition = value }
                    guard let pos = startingPosition else { return }
                    value = pos + dragValue.translation
                })
                .onEnded({ _ in
                    startingPosition = nil
                })
        )
        .padding(-12)
    }
}

#Preview {
    @Previewable @State var topValue: CGPoint = .zero
    @Previewable @State var leadingValue: CGPoint = .zero
    @Previewable @State var bottomValue: CGPoint = .zero
    @Previewable @State var trailingValue: CGPoint = .zero

    VStack {
        BezierHandleView(edge: .top, value: $topValue)
        Spacer()
        HStack {
            BezierHandleView(edge: .trailing, value: $trailingValue)
            Spacer()
            BezierHandleView(edge: .leading, value: $leadingValue)
        }
        Spacer()
        BezierHandleView(edge: .bottom, value: $bottomValue)
    }
    .frame(width: 100, height: 100)
}

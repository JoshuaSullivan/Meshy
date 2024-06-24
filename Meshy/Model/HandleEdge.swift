import SwiftUI

public enum HandleEdge: Int, Hashable, CaseIterable, Identifiable {
    case top, leading, bottom, trailing
    
    public var symbol: Image {
        switch self {
        case .top: return Image(systemName: "arrow.up")
        case .leading: return Image(systemName: "arrow.right")
        case .bottom: return Image(systemName: "arrow.down")
        case .trailing: return Image(systemName: "arrow.left")
        }
    }
    
    public var id: Int { rawValue }
}

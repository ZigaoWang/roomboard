import SwiftUI

struct ResizeHandle: View {
    let size: CGFloat
    let anchor: ResizeAnchor
    var onDelta: (CGSize) -> Void

    @State private var last: CGSize = .zero

    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: size, height: size)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = CGSize(width: value.translation.width - last.width,
                                           height: value.translation.height - last.height)
                        last = value.translation
                        onDelta(delta)
                    }
                    .onEnded { _ in
                        last = .zero
                    }
            )
    }
} 
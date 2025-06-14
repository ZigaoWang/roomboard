import SwiftUI

struct ImageElementView: View {
    let model: ImageElementModel

    var body: some View {
        Group {
            if let img = model.uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray.opacity(0.2)
                VStack {
                    Image(systemName: "photo")
                    Text("Image")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 4)
    }
} 
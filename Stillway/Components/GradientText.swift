import SwiftUI

struct GradientText: View {
    let text: String
    var colors: [Color]
    var font: Font = .system(size: 34, weight: .light)

    var body: some View {
        Text(text)
            .font(font)
            .overlay {
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            }
            .mask(Text(text).font(font))
    }
}

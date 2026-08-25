import SwiftUI

struct GradientText: View {
    let text: String
    var colors: [Color]

    var body: some View {
        Text(text)
            .overlay {
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            }
            .mask(Text(text))
    }
}

import SwiftUI

struct CustomBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                    .transition(.opacity)
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    content()
                }
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .offset(y: max(0, dragOffset))
                .gesture(
                    DragGesture()
                        .onChanged { dragOffset = drag.translation.height }
                        .onEnded { value in
                            if value.translation.height > 120 {
                                dismiss()
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: isPresented)
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            isPresented = false
            dragOffset = 0
        }
    }
}

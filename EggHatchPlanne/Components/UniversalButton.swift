import SwiftUI

struct UniversalButton: View {
    
    let color: Color
    let isDisabled: Bool
    let text: String
    let size: CGFloat
    let pading: Int
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text.uppercased())
                .foregroundStyle(.white)
                .font(.customFont(font: .semiBold, size: size))
                .padding(.horizontal, CGFloat(pading))
                .padding(.vertical, 16)
                .background(color)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white, lineWidth: 4)
                )
//                .shadow(color: color.opacity(0.8), radius: 0, x: 0, y: 4)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    ZStack {
        MainBGView()
        VStack(spacing: 20) {
            UniversalButton(
                color: .yellow,
                isDisabled: false,
                text: "save",
                size: 20,
                pading: 52) {}
            
            UniversalButton(
                color: .yellow,
                isDisabled: true,
                text: "save",
                size: 20,
                pading: 52) {}
        }
        .padding()
        .scaleEffect(2.4)
    }
}

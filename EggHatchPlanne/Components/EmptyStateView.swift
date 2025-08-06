import SwiftUI

struct EmptyStateView: View {
    let imageName: String
    let text: String
    
    var body: some View {
        VStack(spacing: 28) {
            Image(imageName)
            
            Text(text)
                .font(.customFont(font: .bold, size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        MainBGView()
        EmptyStateView(
            imageName: "bigRedXmark",
            text: "There's nothing here yet"
        )
    }
}

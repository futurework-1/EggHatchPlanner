import SwiftUI

struct MainBGView: View {
    var body: some View {
        Image("mainBGImage")
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
    }
}

#Preview {
    MainBGView()
}

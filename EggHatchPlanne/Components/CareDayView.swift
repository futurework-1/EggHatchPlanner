import SwiftUI

struct CareDayView: View {
    let day: Int
    let imageName: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("DAY \(day)")
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 12))
            
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    ZStack {
        MainBGView()
        CareDayView(day: 1, imageName: "eggImage1")
    }
}

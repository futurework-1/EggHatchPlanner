import SwiftUI

struct StatisticsCardView: View {
    let title: String
    let value: String
    let isPercentage: Bool
    
    init(title: String, value: String, isPercentage: Bool = false) {
        self.title = title
        self.value = value
        self.isPercentage = isPercentage
    }
    
    var body: some View {
        VStack(spacing: 13) {
            Text(title)
                .font(.customFont(font: .bold, size: 10))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .lineLimit(2)
            
            Text(value)
                .font(.customFont(font: .bold, size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color("customYellow")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("customDarkGray"))
        )
    }
}

#Preview {
    ZStack {
        MainBGView()
        HStack(spacing: 16) {
            StatisticsCardView(
                title: "Total Eggs",
                value: "12",
                isPercentage: false
            )
            
            StatisticsCardView(
                title: "Hatched",
                value: "8",
                isPercentage: false
            )
            
            StatisticsCardView(
                title: "Success Rate",
                value: "67%",
                isPercentage: true
            )
        }
        .padding(.horizontal, 35)
    }
}

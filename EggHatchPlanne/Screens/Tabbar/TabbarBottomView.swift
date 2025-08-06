import SwiftUI

/// Модель элемента таббара
struct TabbarItem {
    let icon: String
}

struct TabbarBottomView: View {
    
    @Binding var selectedTab: AppTabScreen
    
    /// Элементы таббара с иконками
    private let tabbarItems: [TabbarItem] = [
        TabbarItem(icon: "incubation"),
        TabbarItem(icon: "care"),
        TabbarItem(icon: "hatching"),
        TabbarItem(icon: "settings")
    ]
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            ForEach(tabbarItems.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 0)
                    
                    Image(selectedTab.selectedTabScreenIndex == index ? "\(tabbarItems[index].icon)Painted"  : tabbarItems[index].icon)
                        .resizable()
                        .frame(width: 33, height: 33, alignment: .center)
                        .scaledToFit()
                    
                    Spacer(minLength: 0)
                }
                .onTapGesture {
                    switch index {
                    case 1: selectedTab = .care
                    case 2: selectedTab = .hatching
                    case 3: selectedTab = .settings
                    default: selectedTab = .incubation
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: AppConfig.tabbarHeight)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.customDarkGray)
        }
    }
}

#Preview {
    TabbarBottomView(selectedTab: .constant(AppTabScreen.incubation))
        .environmentObject(AppRouter())
        .environmentObject(TabbarService())
        .preferredColorScheme(.dark)
        .padding(.horizontal)
}

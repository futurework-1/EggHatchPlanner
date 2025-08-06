import SwiftUI

struct HatchingCardView: View {
    let image: UIImage?
    let tag: String?
    let hatchDate: String
    let eggCount: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Левая колонка с изображением и информацией
            VStack(spacing: 10) {
                // Верхняя строка: изображение и тег
                HStack(spacing: 10) {
                    // Изображение птицы
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.customGray)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Group {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 17))
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .foregroundColor(.customLightGray)
                                }
                            }
                        )
                    
                    Spacer()
                    
                    // Тег (отображается только если есть)
                    if let tag = tag, !tag.isEmpty {
                        Text(tag)
                            .font(.customFont(font: .bold, size: 12))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.customVeryLightGray)
                            )
                    }
                }
                
                // Нижняя строка: дата и количество яиц
                HStack(spacing: 17) {
                    // Дата вылупления
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📅 HATCH DATE")
                            .font(.customFont(font: .bold, size: 12))
                            .foregroundColor(.customLightGray)
                            .textCase(.uppercase)
                        
                        Text(hatchDate)
                            .font(.customFont(font: .bold, size: 20))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    // Количество яиц
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🥚 NUMBER")
                            .font(.customFont(font: .bold, size: 12))
                            .foregroundColor(.customLightGray)
                            .textCase(.uppercase)
                        
                        Text(eggCount)
                            .font(.customFont(font: .bold, size: 20))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                    }
                    .frame(alignment: .leading)
                    
                    Spacer()
                }
            }
            
            // Стрелка справа
            Image("forwardImage")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 17)
                .fill(.customDarkGray)
        )
    }
}

#Preview {
    ZStack {
        MainBGView()
        VStack(spacing: 16) {
            HatchingCardView(
                image: nil,
                tag: "first",
                hatchDate: "19.08.2025",
                eggCount: "10"
            )
            
            HatchingCardView(
                image: nil,
                tag: nil,
                hatchDate: "15.08.2025",
                eggCount: "7"
            )
        }
        .padding(.horizontal, 35)
    }
}

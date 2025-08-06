import SwiftUI

struct IncubationCardView: View {
    
    let tipe: String
    let hatchingDate: String
    
    
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(alignment: .center, spacing: 0) {
                    Image(.eggImage1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📅 HATCHING DATE")
                            .foregroundStyle(.customLightGray)
                            .font(.customFont(font: .bold, size: 12))
                        
                        Text(hatchingDate)
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        
                    }
                }
                
                Text(tipe)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 12))
                    .background(RoundedRectangle(cornerRadius: 12).fill(.customGray))
                
            }
            
            Spacer()
            
            Image(.forward)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.customDarkGray)
        )
        
    }
}

#Preview {
    ZStack {
        MainBGView()
        IncubationCardView(tipe: "🐔 CHICKEN", hatchingDate: "19.08.2025")
            .padding()
    }
}


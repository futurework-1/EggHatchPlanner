import SwiftUI

struct CustomSettingsAlert: View {
    /// Binding для закрытия алерта
    @Binding var isPresented: Bool
    
    /// Выбранная единица измерения (временно, не сохраняется)
    @State private var selectedUnit: String = "CELSIUS"
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                Image(.xButton)
                    .onTapGesture {
                        isPresented = false
                    }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 12)
            
            Text("UNIT OF MEASUREMENT")
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 24))
                .padding(.bottom, 8)
            
            Text("CHOOSE BETWEEN")
                .foregroundStyle(.customLightGray)
                .font(.customFont(font: .bold, size: 16))
                .padding(.bottom, 12)
            
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text("CELSIUS (°C)")
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 16))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedUnit == "CELSIUS" ? Color.customVeryLightGray : Color.customGray)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedUnit == "CELSIUS" ? Color.white : Color.clear, lineWidth: 1)
                    )
                    .onTapGesture {
                        selectUnit("CELSIUS")
                    }
                
                Spacer()
                
                Text("FAHRENHEIT (°F)")
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 16))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedUnit == "FAHRENHEIT" ? Color.customVeryLightGray : Color.customGray)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedUnit == "FAHRENHEIT" ? Color.white : Color.clear, lineWidth: 1)
                    )
                    .onTapGesture {
                        selectUnit("FAHRENHEIT")
                    }
                Spacer()
            }
            .padding(.bottom, 32)
            
            Button {
                isPresented = false
            } label: {
                Text("SAVE")
                    .foregroundStyle(.white)
                    .font(.customFont(font: .semiBold, size: 24))
                    .padding(.horizontal, 52)
                    .padding(.vertical, 16)
                    .background(.customYellow)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white, lineWidth: 6)
                    )
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 40).fill(.customGray))
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Private Methods
    
    /// Выбор единицы измерения (временно, не сохраняется)
    private func selectUnit(_ unit: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedUnit = unit
        }
    }
}

#Preview {
    CustomSettingsAlert(isPresented: .constant(true))
        .padding()
        .preferredColorScheme(.dark)
}

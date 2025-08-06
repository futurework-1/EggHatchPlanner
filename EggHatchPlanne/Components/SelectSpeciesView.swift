import SwiftUI

struct SelectSpeciesView: View {
    @Binding var selectedSpecies: BirdSpecies
    
    init(selectedSpecies: Binding<BirdSpecies> = .constant(.chicken)) {
        self._selectedSpecies = selectedSpecies
    }
    
    let species = [
        (BirdSpecies.chicken, "🐔", "CHICKEN"),
        (BirdSpecies.duck, "🦆", "DUCK"),
        (BirdSpecies.goose, "🦆", "GOOSE"),
        (BirdSpecies.turkey, "🦃", "TURKEY"),
        (BirdSpecies.guineaFlow, "🐤", "GUINEA FOWL")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐔 SELECT SPECIES")
                .padding(.bottom, 4)
            
            HStack(alignment: .center, spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    SpeciesButton(
                        emoji: species[index].1,
                        name: species[index].2,
                        isSelected: selectedSpecies == species[index].0,
                        action: {
                            selectedSpecies = species[index].0
                        }
                    )
                }
            }
            
            HStack(alignment: .center, spacing: 8) {
                ForEach(3..<5, id: \.self) { index in
                    SpeciesButton(
                        emoji: species[index].1,
                        name: species[index].2,
                        isSelected: selectedSpecies == species[index].0,
                        action: {
                            selectedSpecies = species[index].0
                        }
                    )
                }
            }
        }
        .foregroundStyle(.white)
        .font(.customFont(font: .bold, size: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpeciesButton: View {
    let emoji: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(emoji) \(name)")
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.customVeryLightGray : Color.customGray)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        MainBGView()
        SelectSpeciesView()
            .padding(.horizontal)
    }
}

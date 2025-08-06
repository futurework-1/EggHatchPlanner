import SwiftUI

struct DateView: View {
    @Binding var selectedDate: Date
    
    init(selectedDate: Binding<Date> = .constant(Date())) {
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 4) {
            Text("📅")
            Text(dateFormatter.string(from: selectedDate))
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 22))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
        
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
}

#Preview {
    ZStack {
        MainBGView()
        DateView()
            .padding(.horizontal)
    }
}

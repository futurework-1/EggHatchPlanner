import SwiftUI

struct ChekBoxView: View {
    @Binding var isChecked: Bool
    let text: String
    let reminderType: ReminderType
    @Binding var selectedReminders: [ReminderType]
    
    init(text: String, reminderType: ReminderType, selectedReminders: Binding<[ReminderType]> = .constant([])) {
        self.text = text
        self.reminderType = reminderType
        self._selectedReminders = selectedReminders
        self._isChecked = Binding(
            get: { selectedReminders.wrappedValue.contains(reminderType) },
            set: { _ in }
        )
    }
    
    var body: some View {
        
        
        HStack(alignment: .center, spacing: 4) {
            Image(isChecked ? .chekBoxDone : .chekBox)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        toggleReminder()
                    }
                }
            
            Text(text)
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 22))
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                toggleReminder()
            }
        }
    }
    
    private func toggleReminder() {
        if selectedReminders.contains(reminderType) {
            selectedReminders.removeAll { $0 == reminderType }
        } else {
            selectedReminders.append(reminderType)
        }
    }
}

#Preview {
    ZStack {
        MainBGView()
        ChekBoxView(text: "TURN EGGS", reminderType: .turnEggs)
            .padding(.horizontal)
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
}

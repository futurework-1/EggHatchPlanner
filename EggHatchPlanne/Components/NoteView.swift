import SwiftUI

struct NoteView: View {
    @State private var isEditing: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @Binding var note: String
    
    init(note: Binding<String> = .constant("")) {
        self._note = note
    }
    
    var body: some View {
        
        VStack {
            if isEditing || !note.isEmpty {
                TextEditor(text: $note)
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 22))
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        isEditing = true
                        isTextFieldFocused = true
                    }
                    .scrollContentBackground(.hidden)
            } else {
                Text("📝 Note")
                    .foregroundStyle(.customLightGray)
                    .font(.customFont(font: .bold, size: 22))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 160)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .onTapGesture {
                        isEditing = true
                        isTextFieldFocused = true
                    }
            }
        }
        .onChange(of: note) { newValue in
            if newValue.isEmpty && !isTextFieldFocused {
                isEditing = false
            }
        }
        .onChange(of: isTextFieldFocused) { newValue in
            if !newValue && note.isEmpty {
                isEditing = false
            }
        }
        
    }
}

#Preview {
    ZStack {
        MainBGView()
        NoteView()
            .padding(.horizontal)
    }
}

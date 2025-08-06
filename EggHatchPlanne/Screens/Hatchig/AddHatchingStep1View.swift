import SwiftUI

struct AddHatchingStep1View: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// ViewModel для управления данными вылуплений
    var hatchingViewModel: HatchingViewModel
    
    // MARK: - State
    @State private var selectedDate: Date?
    @State private var comment: String = ""
    @State private var isDatePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @FocusState private var isCommentFieldFocused: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            MainBGView()
                .onTapGesture {
                    // Скрытие клавиатуры при тапе на пустое место
                    isCommentFieldFocused = false
                }
            
            VStack(spacing: 16) {
                
                // Выбор изображения
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.customDarkGray)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Group {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 130, height: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: 17))
                                } else {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.customMediumGray)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                
                // Выбор даты
                Button(action: {
                    isDatePickerPresented = true
                }) {
                    HStack {
                        Text("📅  \(selectedDate != nil ? selectedDate!.formattedDate : "Hatch Date")")
                            .font(.customFont(font: .bold, size: 20))
                            .foregroundColor(selectedDate != nil ? .white : .customLightGray)
                            .textCase(.uppercase)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 17)
                            .fill(.customDarkGray)
                    )
                }
                .buttonStyle(.plain)
                
                // Поле комментария
                HStack(alignment: .top, spacing: 8) {
                    Text("📝")
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .padding(.top, 2)
                    
                    TextField("Comment (optional)", text: $comment, axis: .vertical)
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .lineLimit(3)
                        .focused($isCommentFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isCommentFieldFocused = false
                                }
                            }
                        }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.customDarkGray)
                )
                
                Spacer()
                
                // Кнопка Next
                UniversalButton(
                    color: selectedDate != nil ? Color("customYellow") : Color("customYellow").opacity(0.25),
                    isDisabled: selectedDate == nil,
                    text: "next",
                    size: 20,
                    pading: 52
                ) {
                    // Сохраняем данные изображения в ViewModel
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    hatchingViewModel.saveTempData(
                        imageData: imageData,
                        selectedDate: selectedDate,
                        comment: comment
                    )
                    
                    appRouter.hatchingRoute.append(.addStep2)
                }
            }
            .padding(.horizontal)
            .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 110 : 72)
            .padding(.bottom, AppConfig.adaptiveTabbarHeight + (AppConfig.isIPhoneSE3rdGeneration ? 150 : 92))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .onTapGesture {
                        appRouter.hatchingRoute.removeLast()
                    }
            }
            
            ToolbarItem(placement: .principal) {
                Image(.addHatching)
            }
        }
        .sheet(isPresented: $isDatePickerPresented) {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { selectedDate ?? Date() },
                        set: { selectedDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Button("Done") {
                    isDatePickerPresented = false
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    NavigationStack {
        AddHatchingStep1View(hatchingViewModel: HatchingViewModel())
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
    }
}

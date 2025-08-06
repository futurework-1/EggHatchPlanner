import SwiftUI

struct HatchingDetailView: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// ViewModel для управления данными вылуплений
    var hatchingViewModel: HatchingViewModel
    
    // MARK: - State
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            MainBGView()
            
            if let hatching = hatchingViewModel.selectedHatching {
                VStack(spacing: 0) {
                //    Spacer()
                    
                    // Карточка с данными
                    VStack(spacing: 22) {
                        // Изображение и имя цыпленка
                        VStack(spacing: 19) {
                            // Изображение
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color("customGray"))
                                .frame(width: 173, height: 173)
                                .overlay(
                                    Group {
                                        if let image = hatching.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 173, height: 173)
                                                .clipShape(RoundedRectangle(cornerRadius: 17))
                                        } else {
                                            Image(systemName: "photo")
                                                .font(.system(size: 80))
                                                .foregroundColor(Color("customLightGray"))
                                        }
                                    }
                                )
                            
                            // Имя цыпленка
                            VStack(spacing: 7) {
                                Text("🐥 Chick Name")
                                    .font(.customFont(font: .bold, size: 15))
                                    .foregroundColor(Color("customLightGray"))
                                    .textCase(.uppercase)
                                
                                Text(hatching.chickName ?? "No name")
                                    .font(.customFont(font: .bold, size: 30))
                                    .foregroundColor(.white)
                                    .textCase(.uppercase)
                            }
                        }
                        
                        // Тег (отображается только если есть)
                        if let tag = hatching.tag, !tag.isEmpty {
                            Text(tag)
                                .font(.customFont(font: .bold, size: 15))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("customVeryLightGray"))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("customMediumGray"), lineWidth: 1)
                                )
                        }
                        
                        // Дата
                        VStack(spacing: 7) {
                            Text("📅 Start Date")
                                .font(.customFont(font: .bold, size: 15))
                                .foregroundColor(Color("customLightGray"))
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity)
                            
                            Text(hatching.hatchDate.formattedDate)
                                .font(.customFont(font: .bold, size: 20))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                        }
                        
                        // Заметка (отображается только если есть)
                        if let note = hatching.note, !note.isEmpty {
                            ScrollView {
                                VStack(spacing: 7) {
                                    Text("📝 Note")
                                        .font(.customFont(font: .bold, size: 15))
                                        .foregroundColor(Color("customLightGray"))
                                        .textCase(.uppercase)
                                    
                                    Text(note)
                                        .font(.customFont(font: .bold, size: 20))
                                        .foregroundColor(.white)
                                        .textCase(.uppercase)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color("customDarkGray"))
                    )
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 110 : 72)
                .padding(.bottom, AppConfig.adaptiveTabbarHeight + (AppConfig.isIPhoneSE3rdGeneration ? 150 : 92))
            } else {
                // Состояние когда запись не найдена
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(Color("customLightGray"))
                    
                    Text("Hatching record not found")
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                }
                .padding(.horizontal)
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 110 : 72)
                .padding(.bottom, AppConfig.adaptiveTabbarHeight + (AppConfig.isIPhoneSE3rdGeneration ? 150 : 92))
            }
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
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(alignment: .center, spacing: 8) {
                                     Button {
                     // Переход к экрану редактирования
                     appRouter.hatchingRoute.append(.edit)
                 } label: {
                     Image("editButtonImage")
                 }
                 .buttonStyle(.plain)
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image("trashButtonImage")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .alert("Delete", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let hatching = hatchingViewModel.selectedHatching {
                    hatchingViewModel.deleteHatching(withId: hatching.id)
                    // Возвращаемся к главному экрану после удаления
                    tabbarService.isTabbarVisible = true
                    appRouter.hatchingRoute.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {
                showDeleteAlert = false
            }
        } message: {
            Text("Are you sure you want to remove this?")
        }
    }
}

#Preview {
    let testViewModel = HatchingViewModel()
    testViewModel.createTestData()
    
    return NavigationStack {
        HatchingDetailView(hatchingViewModel: testViewModel)
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
    }
}

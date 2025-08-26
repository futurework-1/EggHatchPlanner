//
//  NumberOfEggsView.swift
//  EggHatchPlannerV2
//
//  Created by Адам Табиев on 03.08.2025.
//

import SwiftUI

struct NumberOfEggsView: View {
    @State private var numberOfEggsText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Binding var isAnyTextFieldFocused: Bool
    @Binding var numberOfEggs: Int
    
    init(isAnyTextFieldFocused: Binding<Bool> = .constant(false), numberOfEggs: Binding<Int> = .constant(0)) {
        self._isAnyTextFieldFocused = isAnyTextFieldFocused
        self._numberOfEggs = numberOfEggs
        // Инициализируем текстовое поле с переданным значением
        self._numberOfEggsText = State(initialValue: numberOfEggs.wrappedValue > 0 ? String(numberOfEggs.wrappedValue) : "")
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 4) {
            Text("🥚")
            TextField("NUMBER OF EGGS", text: $numberOfEggsText)
                .foregroundStyle(.white)
                .font(.customFont(font: .bold, size: 22))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accentColor(.white)
                .focused($isTextFieldFocused)
                .keyboardType(.numberPad)
                .onChange(of: numberOfEggsText) { newValue in
                    // Фильтруем только цифры
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        numberOfEggsText = filtered
                    }
                    // Обновляем внешнее состояние
                    if let intValue = Int(filtered) {
                        numberOfEggs = intValue
                    }
                }
                .onChange(of: isTextFieldFocused) { newValue in
                    // Синхронизируем с глобальным состоянием фокуса
                    DispatchQueue.main.async {
                        isAnyTextFieldFocused = newValue
                    }
                }
                .onAppear {
                    // Устанавливаем цвет placeholder
                    UITextField.appearance().attributedPlaceholder = NSAttributedString(
                        string: "NUMBER OF EGGS",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(Color.customLightGray)]
                    )
                    
                    // Устанавливаем начальное значение если numberOfEggs больше 0
                    if numberOfEggs > 0 && numberOfEggsText.isEmpty {
                        numberOfEggsText = String(numberOfEggs)
                    }
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))

        
    }
}

#Preview {
    ZStack {
           MainBGView()
        NumberOfEggsView(numberOfEggs: .constant(12))
               .padding(.horizontal)
       }
}

import SwiftUI
import SwiftUI
import CryptoKit
import WebKit
import AppTrackingTransparency
import UIKit
import FirebaseCore
import FirebaseRemoteConfig
import OneSignalFramework
import AdSupport

enum CryptoUtils {
    static func md5Hex(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

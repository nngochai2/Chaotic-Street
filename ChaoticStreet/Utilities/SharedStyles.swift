/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: Shared Components
  Created date: 04/09/2025
  Last modified: 04/09/2025
  Acknowledgement: See README
*/

import SwiftUI

// MARK: - Text Field Styles
struct GameTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color("colorDarkBlue").opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [Color("colorOrange"), Color("colorRed")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ), lineWidth: 1)
            )
    }
}

struct GameSecureFieldStyle: View {
    @Binding var text: String
    @Binding var showPassword: Bool
    let placeholder: String
    let textContentType: UITextContentType?
    
    var body: some View {
        HStack {
            if showPassword {
                TextField(placeholder, text: $text)
                    .textFieldStyle(GameTextFieldStyle())
            } else {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
                    .textFieldStyle(GameTextFieldStyle())
            }
            
            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color("colorDarkRed"))
            }
            .padding(.trailing, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color("colorDarkBlue").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Button Styles
struct PrimaryGameButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors:
                        [Color("colorRed"), Color("colorDarkRed")]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: isEnabled ? Color("colorDarkRed").opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryGameButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isEnabled ? 
                        [Color("colorYellow"), Color("colorOrange")] : 
                        [Color("colorLightGrey"), Color("colorLightGrey")]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: isEnabled ? Color("colorOrange").opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TertiaryGameButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? Color("colorDarkBlue") : Color("colorLightGrey"))
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("colorLightGrey").opacity(0.3),
                        Color("colorLightBrown").opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("colorDarkBlue").opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color("colorDarkBlue").opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DestructiveGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("colorOrange"), Color("colorRed")]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color("colorRed").opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DarkGameButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: 
                        [Color("colorDarkBlue"), Color.black]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: isEnabled ? Color.black.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Input Field Components
struct GameInputField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    
    init(title: String, placeholder: String, icon: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: TextInputAutocapitalization = .sentences) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("colorOrange"))
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("colorDarkBlue"))
            }
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .textFieldStyle(GameTextFieldStyle())
        }
    }
}

struct GameSecureInputField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    @State private var showPassword = false
    let textContentType: UITextContentType?
    let validationIcon: String?
    let isValid: Bool?
    
    init(title: String, placeholder: String, icon: String, text: Binding<String>, textContentType: UITextContentType? = nil, validationIcon: String? = nil, isValid: Bool? = nil) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.textContentType = textContentType
        self.validationIcon = validationIcon
        self.isValid = isValid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("colorOrange"))
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("colorDarkBlue"))
                
                Spacer()
                
                if let validationIcon = validationIcon, let isValid = isValid, !text.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValid ? Color("colorRed") : Color("colorOrange"))
                        .scaleEffect(isValid ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isValid)
                }
            }
            
            GameSecureFieldStyle(
                text: $text,
                showPassword: $showPassword,
                placeholder: placeholder,
                textContentType: textContentType
            )
        }
    }
}

// MARK: - Status Message Views
struct SuccessMessageView: View {
    let message: String
    let icon: String
    
    init(message: String, icon: String = "checkmark.circle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(message)
        }
        .foregroundColor(Color("colorRed"))
        .font(.headline)
        .padding()
        .background(Color("colorYellow").opacity(0.3))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
}

struct ErrorMessageView: View {
    let message: String
    let icon: String
    
    init(message: String, icon: String = "exclamationmark.triangle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(message)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(Color("colorDarkRed"))
        .font(.subheadline)
        .padding()
        .background(Color("colorOrange").opacity(0.2))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Background Views
struct GameBackgroundView: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color] = [Color("colorLightGrey").opacity(0.3), Color("colorDarkBlue").opacity(0.1)], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

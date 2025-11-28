import SwiftUI

struct UpdatePasswordView: View {
    @State var oldPassword = ""
    @State var newPassword = ""
    @State var confirmPassword = ""
    @State private var isAnimating = false
    @EnvironmentObject var userViewModel: UserViewModel
    
    private var passwordsMatch: Bool {
        newPassword == confirmPassword && !confirmPassword.isEmpty
    }
    
    private var isFormValid: Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty && passwordsMatch
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                GameBackgroundView(colors: [
                    Color("colorOrange").opacity(0.2),
                    Color("colorRed").opacity(0.1),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 60)
                        
                        // Header
                        VStack(spacing: 16) {
                            Text("🔐")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Update Password")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Enter your current password and choose a new one")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // Old Password field
                            GameSecureInputField(
                                title: "Current Password",
                                placeholder: "Enter your current password",
                                icon: "key.fill",
                                text: $oldPassword,
                                textContentType: .password
                            )
                            
                            // New Password field
                            GameSecureInputField(
                                title: "New Password",
                                placeholder: "Enter your new password",
                                icon: "lock.fill",
                                text: $newPassword,
                                textContentType: .newPassword
                            )
                            
                            // Confirm New Password field
                            VStack(alignment: .leading, spacing: 8) {
                                GameSecureInputField(
                                    title: "Confirm New Password",
                                    placeholder: "Confirm your new password",
                                    icon: "lock.shield.fill",
                                    text: $confirmPassword,
                                    textContentType: .newPassword,
                                    validationIcon: "checkmark.circle.fill",
                                    isValid: passwordsMatch
                                )
                                
                                if !confirmPassword.isEmpty && !passwordsMatch {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text("Passwords don't match")
                                    }
                                    .font(.caption)
                                    .foregroundColor(Color("colorOrange"))
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Update button
                        Button {
                            userViewModel.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
                        } label: {
                            HStack {
                                if userViewModel.attemptedPasswordUpdate && !userViewModel.passwordUpdateSuccess && userViewModel.errorMessage == nil {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Update Password")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(PrimaryGameButtonStyle(isEnabled: isFormValid))
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        
                        // Status messages
                        if userViewModel.attemptedPasswordUpdate {
                            if userViewModel.passwordUpdateSuccess {
                                SuccessMessageView(
                                    message: "Password updated successfully! 🎉",
                                    icon: "checkmark.shield.fill"
                                )
                                .padding(.horizontal, 20)
                            } else if let errorMessage = userViewModel.errorMessage {
                                ErrorMessageView(message: errorMessage)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
        .onDisappear {
            userViewModel.clearPasswordUpdateState()
        }
    }
}


#Preview {
    UpdatePasswordView()
        .environmentObject(UserViewModel())
}

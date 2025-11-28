import SwiftUI

struct PasswordResetView: View {
    @State var email = ""
    @State private var isAnimating = false
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                GameBackgroundView(colors: [
                    Color("colorLightBrown").opacity(0.2),
                    Color("colorYellow").opacity(0.3),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 80)
                        
                        // Header
                        VStack(spacing: 16) {
                            Text("🔑")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Reset Password")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Enter your email to receive a password reset link")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        // Email input
                        VStack(spacing: 20) {
                            GameInputField(
                                title: "Email Address",
                                placeholder: "Enter your email",
                                icon: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                autocapitalization: .never
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Reset button
                        Button {
                            userViewModel.resetPassword(email: email)
                        } label: {
                            HStack {
                                if userViewModel.attemptedPasswordReset && !userViewModel.passwordResetSuccess && userViewModel.errorMessage == nil {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Reset Link")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(PrimaryGameButtonStyle(isEnabled: !email.isEmpty))
                        .disabled(email.isEmpty)
                        .padding(.horizontal, 20)
                        
                        // Status messages
                        if userViewModel.attemptedPasswordReset {
                            if userViewModel.passwordResetSuccess {
                                SuccessMessageView(
                                    message: "Password reset email sent! 📧",
                                    icon: "envelope.badge.fill"
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
            userViewModel.clearPasswordResetState()
        }
    }
}


#Preview {
    PasswordResetView()
        .environmentObject(UserViewModel())
}

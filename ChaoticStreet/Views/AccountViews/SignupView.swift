import SwiftUI
import FirebaseAuth

struct SignupView: View {
    // MARK: - Properties
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    @State private var isAnimating = false
    @EnvironmentObject var userViewModel: UserViewModel
    
    // Computed property for password validation
    private var passwordsMatch: Bool {
        password == passwordConfirmation && !passwordConfirmation.isEmpty
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty && passwordsMatch
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                GameBackgroundView(colors: [
                    Color("colorYellow").opacity(0.2),
                    Color("colorLightBrown").opacity(0.3),
                    Color("colorDarkBlue").opacity(0.1)
                ])
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 60)
                        
                        // Welcome header
                        VStack(spacing: 16) {
                            Text("🚀")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Join the Game!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Create your account and start playing")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 20)
                        
                        // Sign up form
                        VStack(spacing: 20) {
                            // Email field
                            GameInputField(
                                title: "Email Address",
                                placeholder: "Enter your email",
                                icon: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                autocapitalization: .never
                            )
                            
                            // Password field
                            GameSecureInputField(
                                title: "Password",
                                placeholder: "Create a password",
                                icon: "lock.fill",
                                text: $password,
                                textContentType: .newPassword
                            )
                            
                            // Confirm Password field
                            VStack(alignment: .leading, spacing: 8) {
                                GameSecureInputField(
                                    title: "Confirm Password",
                                    placeholder: "Confirm your password",
                                    icon: "lock.shield.fill",
                                    text: $passwordConfirmation,
                                    textContentType: .newPassword,
                                    validationIcon: "checkmark.circle.fill",
                                    isValid: passwordsMatch
                                )
                                
                                if !passwordConfirmation.isEmpty && !passwordsMatch {
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
                        
                        // Sign up button
                        Button(action: {
                            userViewModel.signUp(email: email, password: password)
                        }) {
                            HStack {
                                if userViewModel.attemptedSignUp && !userViewModel.signUpSuccess && userViewModel.errorMessage == nil {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.badge.plus.fill")
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(PrimaryGameButtonStyle(isEnabled: isFormValid))
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        
                        // Status messages
                        if userViewModel.attemptedSignUp {
                            if userViewModel.signUpSuccess {
                                SuccessMessageView(
                                    message: "Account Created! Check your email to verify your email before logging in (Remember to also check spam folder)! 🎉",
                                    icon: "party.popper.fill"
                                )
                                .padding(.horizontal, 20)
                            } else if let errorMessage = userViewModel.errorMessage {
                                ErrorMessageView(message: errorMessage)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Back to login navigation
                        VStack(spacing: 16) {
                            Text("Already have an account?")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                            
                            NavigationLink(destination: LoginView()) {
                                HStack {
                                    Image(systemName: "arrow.left.circle")
                                    Text("Back to Login")
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(TertiaryGameButtonStyle())
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        
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
            userViewModel.clearSignUpState()
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(UserViewModel())
}

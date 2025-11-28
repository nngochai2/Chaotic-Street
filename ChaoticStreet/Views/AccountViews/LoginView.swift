import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    // MARK: - Properties
    @State var email = ""
    @State var password = ""
    @State private var isAnimating = false

    @EnvironmentObject var userViewModel: UserViewModel

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                GameBackgroundView()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 80)
                        
                        // Welcome header
                        VStack(spacing: 16) {
                            Text("🎮")
                                .font(.system(size: 80))
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("Welcome Back!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("colorDarkBlue"))
                            
                            Text("Sign in to continue your game")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                                .opacity(0.8)
                        }
                        .padding(.bottom, 20)
                        
                        // Login form
                        VStack(spacing: 20) {
                            // Email field
                            GameInputField(
                                title: "Email",
                                placeholder: "Enter your email",
                                icon: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                autocapitalization: .never
                            )
                            
                            // Password field
                            GameSecureInputField(
                                title: "Password",
                                placeholder: "Enter your password",
                                icon: "lock.fill",
                                text: $password,
                                textContentType: .password
                            )
                            
                            // Forgot password link
                            HStack {
                                Spacer()
                                NavigationLink(destination: PasswordResetView()) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.caption)
                                        Text("Forgot Password?")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(Color("colorOrange"))
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color("colorOrange").opacity(0.3)),
                                        alignment: .bottom
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        
                        // Login button
                        Button {
                            userViewModel.login(email: email, password: password)
                        } label: {
                            HStack {
                                if userViewModel.attemptedLogin && !userViewModel.loginSuccess && userViewModel.errorMessage == nil {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "gamecontroller.fill")
                                    Text("Sign In & Play")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .buttonStyle(PrimaryGameButtonStyle(isEnabled: !email.isEmpty && !password.isEmpty))
                        .disabled(email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 20)
                        
                        // Status messages
                        if userViewModel.attemptedLogin {
                            if userViewModel.loginSuccess {
                                SuccessMessageView(
                                    message: "Login Successfully! 🎉",
                                    icon: "party.popper.fill"
                                )
                                .padding(.horizontal, 20)
                            } else if let errorMessage = userViewModel.errorMessage {
                                ErrorMessageView(message: errorMessage)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        // Sign up navigation
                        VStack(spacing: 16) {
                            Text("Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(Color("colorDarkRed"))
                            
                            NavigationLink(destination: SignupView()) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Create New Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(SecondaryGameButtonStyle())
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
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
            userViewModel.clearLoginState()
        }
    }
}


#Preview {
    LoginView()
        .environmentObject(UserViewModel())
}

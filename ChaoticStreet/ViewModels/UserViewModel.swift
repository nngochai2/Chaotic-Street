import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import Cloudinary

class UserViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var loginSuccess: Bool = false
    @Published var attemptedLogin: Bool = false
    @Published var signUpSuccess: Bool = false
    @Published var attemptedSignUp: Bool = false
    @Published var attemptedPasswordReset: Bool = false
    @Published var passwordResetSuccess: Bool = false
    @Published var attemptedPasswordUpdate: Bool = false
    @Published var passwordUpdateSuccess: Bool = false
    @Published var errorMessage: String? = nil
    @Published var profilePictureUrl: String? = nil
    @Published var bioText: String = ""
    
    func setUser(from firebaseUser: User?) {
        if let firebaseUser = firebaseUser {
            self.user = AppUser(from: firebaseUser)
        } else {
            self.user = nil
        }
    }
	
	// Return the current user's email address if they're signed in
	func getCurrentUserEmail() -> String? {
		guard let currentUser = Auth.auth().currentUser else {
			return nil
		}
		return currentUser.email
	}

    func signUp(email: String, password: String) {
        attemptedSignUp = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error as NSError? {
                let errorCode = AuthErrorCode(rawValue: error.code)
                switch errorCode {
                    case .invalidEmail:
                        self.errorMessage = "That doesn't look like a valid email."
                    case .emailAlreadyInUse:
                        self.errorMessage = "An account with this email already exists."
                    case .operationNotAllowed:
                        self.errorMessage = "Email/password sign-up is currently disabled."
                    case .networkError:
                        self.errorMessage = "Network issue. Please check your connection and try again."
                    case .weakPassword:
                        self.errorMessage = "Password is too weak. Please use at least 6 characters."
                    default:
                        self.errorMessage = "Something went wrong. Please try again."
                }
                self.signUpSuccess = false
            } else {
                print("success")
                self.signUpSuccess = true
                self.errorMessage = nil

                // Create user document in Firestore
                if let firebaseUser = result?.user {
                    let db = Firestore.firestore()
                    db.collection("users").document(firebaseUser.uid).setData([
                        "email": firebaseUser.email ?? "",
                        "createdAt": FieldValue.serverTimestamp()
                    ]) { err in
                        if let err = err {
                            print("Error writing user to Firestore: \(err)")
                        } else {
                            print("User document successfully written!")
                        }
                    }
                    // Send email verification
                    firebaseUser.sendEmailVerification { error in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                        } else {
                            print("Verification email sent.")
                        }
                    }
                }
            }
        }
    }
    // Check if the current user's email is verified
    func isEmailVerified() -> Bool {
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }

    func login(email: String, password: String) {
        attemptedLogin = true
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error as NSError? {
                let errorCode = AuthErrorCode(rawValue: error.code)
                switch errorCode {
                    case .invalidEmail:
                        self.errorMessage = "That doesn't look like a valid email."
                    case .userDisabled:
                        self.errorMessage = "Your account has been disabled. Please contact support."
                    case .operationNotAllowed:
                        self.errorMessage = "Email/password sign-in is currently disabled."
                    case .networkError:
                        self.errorMessage = "Network issue. Please check your connection and try again."
                    default:
                        if errorCode!.rawValue == 17004 {
                            self.errorMessage = "Invalid Credential"
                        } else {
                            self.errorMessage = "Something went wrong. Please try again."
                        }
                }
                self.loginSuccess = false
            } else if let user = result?.user {
                if user.isEmailVerified {
                    // Email is verified — proceed with login
                    print("Login successful and email is verified.")
                    self.loginSuccess = true
                    self.errorMessage = nil
                    self.setUser(from: user)
                } else {
                    // Email not verified — sign the user out
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                    self.loginSuccess = false
                    self.errorMessage = "Please verify your email before logging in."
                }
            }
        }
    }

    func logOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }

    func resetPassword(email: String) {
        attemptedPasswordReset = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error as NSError? {
                let errorCode = AuthErrorCode(rawValue: error.code)
                switch errorCode {
                    case .invalidEmail:
                        self.errorMessage = "That doesn't look like a valid email."
                    case .networkError:
                        self.errorMessage = "Network issue. Please check your connection and try again."
                    default:
                        if errorCode!.rawValue == 17004 {
                            self.errorMessage = "No account found with that email"
                        } else {
                            self.errorMessage = "Something went wrong. Please try again."
                        }
                }
                self.passwordResetSuccess = false
            } else {
                self.errorMessage = nil
                self.passwordResetSuccess = true
            }
        }
    }

    func updatePassword(oldPassword: String, newPassword: String) {
        attemptedPasswordUpdate = true
        guard let email = user?.email else {
            self.errorMessage = "No user email found."
            self.passwordUpdateSuccess = false
            return
        }
        // Re-authenticate user
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error as NSError? {
                self?.errorMessage = "Old password is incorrect."
                self?.passwordUpdateSuccess = false
            } else {
                // Update password
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error as NSError? {
                        self?.errorMessage = error.localizedDescription
                        self?.passwordUpdateSuccess = false
                    } else {
                        self?.errorMessage = nil
                        self?.passwordUpdateSuccess = true
                    }
                }
            }
        }
    }

    func setProfilePicture(_ image: UIImage) {
        guard let url = Bundle.main.url(forResource: "Cloudinary-Info", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let cloudName = plist["CLOUDINARY_CLOUD_NAME"] as? String,
              let uploadPreset = plist["CLOUDINARY_UPLOAD_PRESET"] as? String else {
            print("Cloudinary config missing in Info.plist")
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to compress image to JPEG.")
            return
        }
        guard let userId = user?.uid else { return }

        let config = CLDConfiguration(cloudName: cloudName)
        let cloudinary = CLDCloudinary(configuration: config)
        let params = CLDUploadRequestParams()
        params.setUploadPreset(uploadPreset)
        cloudinary.createUploader().upload(data: imageData, uploadPreset: uploadPreset, params: params, progress: nil) { result, error in
            if let error = error {
                print("Cloudinary upload failed: \(error.localizedDescription)")
            } else if let url = result?.secureUrl {
                DispatchQueue.main.async {
                    // Save URL to Firestore
                    let db = Firestore.firestore()
                    db.collection("users").document(userId).setData([
                        "profilePictureUrl": url
                    ], merge: true)
                    
                    // Update profilePictureUrl to update UI
                    self.profilePictureUrl = url
                }
            }
        }
    }

    func fetchProfilePicture() {
        guard let userId = user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let urlString = data["profilePictureUrl"] as? String {
                DispatchQueue.main.async {
                    self.profilePictureUrl = urlString
                }
            } else {
                DispatchQueue.main.async {
                    self.profilePictureUrl = nil
                }
            }
        }
    }
    
    // Bio Functions
    func fetchBio() {
        guard let userId = self.user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let bio = data["bio"] as? String {
                DispatchQueue.main.async {
                    self.bioText = bio
                }
            } else {
                DispatchQueue.main.async {
                    self.bioText = ""
                }
            }
        }
    }

    func saveBio() {
        guard let userId = self.user?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "bio": bioText
        ], merge: true)
    }

    // Delete User Functionality
    func deleteUser(completion: @escaping (Bool, String?) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else {
            completion(false, "No authenticated user.")
            return
        }
        let userId = firebaseUser.uid
        let db = Firestore.firestore()

        // Delete user document from users collection
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
            } else {
                print("User document deleted from Firestore.")
            }
        }

        // Delete all scores for this user from scores collection
        db.collection("scores").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching scores: \(error.localizedDescription)")
            } else if let docs = snapshot?.documents {
                let batch = db.batch()
                for doc in docs {
                    batch.deleteDocument(doc.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error deleting scores: \(error.localizedDescription)")
                    } else {
                        print("Scores deleted from Firestore.")
                    }
                }
            }
        }

        // Delete user from FirebaseAuth
        firebaseUser.delete { error in
            if let error = error {
                print("Error deleting user from FirebaseAuth: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                print("User deleted from FirebaseAuth.")
                self.user = nil
                completion(true, nil)
            }
        }
    }

    // MARK: - Clear Authentication States
    func clearAuthStates() {
        loginSuccess = false
        attemptedLogin = false
        signUpSuccess = false
        attemptedSignUp = false
        attemptedPasswordReset = false
        passwordResetSuccess = false
        attemptedPasswordUpdate = false
        passwordUpdateSuccess = false
        errorMessage = nil
    }
    
    func clearLoginState() {
        loginSuccess = false
        attemptedLogin = false
        errorMessage = nil
    }
    
    func clearSignUpState() {
        signUpSuccess = false
        attemptedSignUp = false
        errorMessage = nil
    }
    
    func clearPasswordResetState() {
        attemptedPasswordReset = false
        passwordResetSuccess = false
        errorMessage = nil
    }
    
    func clearPasswordUpdateState() {
        attemptedPasswordUpdate = false
        passwordUpdateSuccess = false
        errorMessage = nil
    }
}

import Foundation
import FirebaseAuth

struct AppUser {
    let uid: String
    let email: String?
    let profilePictureUrl: String?
    
    init(from firebaseUser: User, profilePictureUrl: String? = nil) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.profilePictureUrl = profilePictureUrl
    }
}
import SwiftUI

struct DeleteUserView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var showAlert = false
    @State private var deleteSuccess = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text("Delete Account")
                .font(.title)
                .bold()
            Text("This will permanently delete your account, all your scores, and all your data. This action cannot be undone.")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Button(role: .destructive) {
                userViewModel.deleteUser { success, error in
                    deleteSuccess = success
                    errorMessage = error
                    showAlert = true
                }
            } label: {
                Text("Delete My Account")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            if deleteSuccess {
                return Alert(title: Text("Account Deleted"), message: Text("Your account and all data have been deleted."), dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("Delete Failed"), message: Text(errorMessage ?? "Unknown error."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    DeleteUserView(userViewModel: UserViewModel())
}
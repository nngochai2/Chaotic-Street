/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Tuan Minh Khoi, S3995060
	Bui Minh Duc, S4070921
  Created date: 10/09/2025
  Last modified: 15/09/2025
  Acknowledgement: See README
*/

import SwiftUI
import UIKit

struct ProfilePictureBioPickerView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var isEditingBio: Bool = false

	var body: some View {
		ZStack {
			GameBackgroundView(colors: [
				Color("colorYellow").opacity(0.1),
				Color("colorOrange").opacity(0.2),
				Color("colorDarkBlue").opacity(0.1)
			])
			
			VStack {
				
			}
			
			VStack(spacing: 16) {
				// Profile Picture
				if let urlString = userViewModel.profilePictureUrl, let url = URL(string: urlString) {
					AsyncImage(url: url) { phase in
						switch phase {
						case .success(let image):
							image.resizable()
								.scaledToFill()
								.frame(width: 120, height: 120)
								.clipShape(Circle())
						default:
							Circle()
								.fill(Color.gray.opacity(0.3))
								.frame(width: 120, height: 120)
								.overlay(Image(systemName: "photo.fill"))
						}
					}
					.onTapGesture {
						showImagePicker = true
					}
				} else {
					Circle()
						.fill(Color.gray.opacity(0.3))
						.frame(width: 120, height: 120)
						.overlay(Image(systemName: "photo.fill"))
						.onTapGesture {
							showImagePicker = true
						}
				}
				
				if isEditingBio {
					TextField("Enter your bio", text: $userViewModel.bioText)
						.textFieldStyle(RoundedBorderTextFieldStyle())
					HStack {
						Button("Save") {
							userViewModel.saveBio()
							isEditingBio = false
						}
						Button("Cancel") {
							isEditingBio = false
						}
					}
				} else {
					Text(userViewModel.bioText.isEmpty ? "No bio set yet." : userViewModel.bioText)
						.foregroundColor(userViewModel.bioText.isEmpty ? .gray : .primary)
					Button("Edit Bio") {
						isEditingBio = true
					}
				}
			}
			.onAppear {
				userViewModel.fetchProfilePicture()
				userViewModel.fetchBio()
			}
			.sheet(isPresented: $showImagePicker) {
				ImagePicker(selectedImage: $selectedImage)
			}
			.onChange(of: selectedImage) {
				if let img = selectedImage {
					userViewModel.setProfilePicture(img)
				}
			}
			
			Spacer()
		}
	}
}

#Preview {
    ProfilePictureBioPickerView()
        .environmentObject(UserViewModel())
}


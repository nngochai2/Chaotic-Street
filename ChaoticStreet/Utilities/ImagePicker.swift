/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Tuan Minh Khoi, S3995060
	Bui Minh Duc, S4070921
  Created date: 12/09/2025
  Last modified: 15/09/2025
  Acknowledgement: See README
*/

import SwiftUI
import UIKit

// Simple UIKit image picker wrapper for SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
	@Binding var selectedImage: UIImage?

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let parent: ImagePicker
		init(_ parent: ImagePicker) { self.parent = parent }
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let image = info[.originalImage] as? UIImage {
				parent.selectedImage = image
			}
			picker.dismiss(animated: true)
		}
	}

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		picker.allowsEditing = false
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 22/08/2025
  Last modified: 15/09/2025
  Acknowledgement: See README
*/

import SwiftUI

struct SettingsView: View {
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var user: UserViewModel
	@Binding var showSettings: Bool
	
	@State private var showImagePicker = false
	@State private var selectedImage: UIImage? = nil
	@State private var isEditingBio: Bool = false
	@State private var showInstructions: Bool = false
	@State private var showCredits: Bool = false
	@State private var showResetAlert: Bool = false
	@State private var showAftermathAlert: Bool = false
	@State private var deleteSuccess = false
	@State private var errorMessage: String? = nil
	
	@AppStorage("bgVolume") private var backgroundVolume: Double = 0.8
	@AppStorage("sfxVolume") private var soundEffectsVolume: Double = 0.8
	@AppStorage("theme") private var theme: String = "System"
	@AppStorage("difficulty") private var difficulty: Int = 0
	@AppStorage("language") private var language: String = "en"
	
    var body: some View {
		NavigationView {
			GeometryReader { geometry in
				ZStack {
					GameBackgroundView(colors: [
						Color("colorYellow").opacity(0.1),
						Color("colorOrange").opacity(0.2),
						Color("colorDarkBlue").opacity(0.1)
					])
					
					Form {
						// MARK: - Account management
						Section(header: Text("settings.account")) {
							if user.user == nil {
								NavigationLink {
									LoginView()
								} label: {
									Text("settings.account.logIn")
								}
							} else {
								Button {
									showImagePicker = true
								} label: {
									HStack(spacing: 12) {
										if let url = URL(string: user.profilePictureUrl ?? "") {
											AsyncImage(url: url) { image in
												image.resizable()
													.scaledToFill()
													.clipShape(Circle())
											} placeholder: {
												Circle().fill(Color.gray.opacity(0.3))
											}
											.frame(width: 44, height: 44)
										} else {
											Image(systemName: "person.circle.fill")
												.resizable()
												.scaledToFill()
												.frame(width: 44, height: 44)
										}
										VStack(alignment: .leading) {
											Text(user.user?.email ?? "Unknown User")
												.font(.headline)
											Text("settings.account.changeProfilePic")
												.font(.caption)
												.foregroundColor(.secondary)
										}
									}
								}
								.onAppear {
									user.fetchProfilePicture()
									user.fetchBio()
								}
								VStack {
									if (user.bioText.isEmpty) {
										Text("settings.account.noBio")
											.font(.caption)
									} else {
										Text(user.bioText)
											.font(.caption)
											.lineLimit(2)
									}
								}
								.frame(height: 44)
								.onTapGesture {
									isEditingBio = true
								}
								NavigationLink {
									UpdatePasswordView()
								} label: {
									Text("settings.account.changePassword")
								}
								Button(action: { user.logOut() }) {
									Text("settings.account.logOut")
								}
							}
						}
						
						// MARK: - Background and Sound effect volume control
						Section(
							header: Text("settings.bgVolume"),
							footer: Text("settings.bgVolume.info")
						) {
							HStack {
								Image(systemName: "speaker.fill")
								Slider(value: $backgroundVolume, in: 0...1)
								Image(systemName: "speaker.wave.3.fill")
							}
						}
						Section(
							header: Text("settings.sfxVolume"),
							footer: Text("settings.sfxVolume.info")
						) {
							HStack {
								Image(systemName: "speaker.fill")
								Slider(value: $soundEffectsVolume, in: 0...1)
								Image(systemName: "speaker.wave.3.fill")
							}
						}
						
						// MARK: - Game difficulty control
						Section(
							header: Text("settings.difficulty"),
							footer: Text(difficultyInfo)
						) {
							Picker("settings.difficulty", selection: $difficulty) {
								Text("settings.difficulty.easy").tag(0)
								Text("settings.difficulty.medium").tag(1)
								Text("settings.difficulty.hard").tag(2)
							}
							.pickerStyle(.segmented)
						}
						
						// MARK: - App theme, language and push notification toggles
						Section {
							Picker("settings.theme", selection: $theme) {
								Text("settings.theme.followSystem").tag("System")
								Text("settings.theme.light").tag("Light")
								Text("settings.theme.dark").tag("Dark")
							}
							Picker("settings.language", selection: $language) {
								Text("English").tag("en")
								Text("Tiếng Việt").tag("vi")
							}
							.onChange(of: language) { oldLanguage, newLanguage in
								Bundle.setLanguage(newLanguage)
								
								if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
								   let window = windowScene.windows.first {
									window.rootViewController = UIHostingController(rootView: GameView().environmentObject(user))
									window.makeKeyAndVisible()
								}
							}
						}
						
						// MARK: - Reset all settings and game data
						Section {
							Button(role: .destructive, action: { showResetAlert = true }) {
								Text("settings.reset")
							}
							.accessibilityLabel(Text("settings.reset"))
							.accessibilityHint(Text("Destructive action. This will delete all your game progress and reset all settings to their default values."))
							.alert(isPresented: $showResetAlert) {
								Alert(
									title: Text("settings.reset.prompt"),
									message: Text("settings.reset.info"),
									primaryButton: .destructive(Text("settings.reset.confirmBtn")) {
										user.deleteUser { success, error in
											deleteSuccess = success
											errorMessage = error
											showAftermathAlert = true
										}
									},
									secondaryButton: .cancel()
								)
							}
						}
						
						// MARK: - Miscellaneous buttons
						Section {
							Button(action: { showInstructions = true }) {
								Text("settings.gameInstruction")
							}
							.sheet(isPresented: $showInstructions) {
								GameInstructionView()
							}
							Button(action: { showCredits = true }) {
								Text("settings.credits")
							}
							.alert(isPresented: $showCredits) {
								Alert(
									title: Text("settings.credits"),
									message: Text("settings.credits.info"),
									dismissButton: .default(Text("OK"))
								)
							}
						}
					}
					.scrollContentBackground(.hidden)
					.alert(isPresented: $showAftermathAlert) {
						if deleteSuccess {
							return Alert(title: Text("settings.reset.success"), message: Text("settings.reset.success.info"), dismissButton: .default(Text("OK")))
						} else {
							return Alert(title: Text("settings.reset.failed"), message: Text(errorMessage ?? "Unknown error."), dismissButton: .default(Text("OK")))
						}
					}
					.sheet(isPresented: $showImagePicker) {
						ImagePicker(selectedImage: $selectedImage)
							.onChange(of: selectedImage) {
								if let img = selectedImage {
									user.setProfilePicture(img)
								}
							}
					}
					.sheet(isPresented: $isEditingBio) {
						NavigationView {
							TextEditor(text: $user.bioText)
								.font(.body)
								.padding(.horizontal, 12)
								.padding(.vertical, 8)
							.navigationTitle("settings.account.editBio")
							.navigationBarTitleDisplayMode(.inline)
							.toolbar {
								ToolbarItem(placement: .navigationBarLeading) {
									Button("settings.account.editBio.cancelBtn") {
										isEditingBio = false
										user.fetchBio() // Revert changes
									}
								}
								ToolbarItem(placement: .navigationBarTrailing) {
									Button("settings.account.editBio.saveBtn") {
										user.saveBio()
										isEditingBio = false
									}
								}
							}
						}
					}
				}
				.navigationTitle("settings")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar(content: {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("settings.done") {
							showSettings.toggle()
						}
					}
				})
				.tint(accentColor)
				.modifier(PreferredColorSchemeModifier(colorScheme: theme == "System" ? nil : (theme == "Light" ? .light : .dark)))
			}
		}
    }
	
	// Localisation keys for difficulty info text.
	private var difficultyInfo: LocalizedStringKey {
		switch difficulty {
		case 0: return "settings.difficulty.easy.info"
		case 1: return "settings.difficulty.medium.info"
		case 2: return "settings.difficulty.hard.info"
		default: return ""
		}
	}
	
	// Use a darker accent color in light mode for better visibility.
	private var accentColor: Color {
		colorScheme == .dark ? Color.accentColor : Color("colorDarkBlue")
	}
}

// MARK: - Custom view modifier to only apply preferredColorScheme when explicitly set as light/dark mode,
// allowing system default when "System" is selected.
struct PreferredColorSchemeModifier: ViewModifier {
	let colorScheme: ColorScheme?
	func body(content: Content) -> some View {
		if let colorScheme {
			content.preferredColorScheme(colorScheme)
		} else {
			content
		}
	}
}

#Preview {
	SettingsView(showSettings: .constant(true))
		.environmentObject(UserViewModel())
}

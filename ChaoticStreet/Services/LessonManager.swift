/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 13/09/2025
  Last modified: 15/09/2025
  Acknowledgement: See README
*/

import Foundation

class LessonManager {
	static let shared = LessonManager()
	private var lessons: Lesson?
	
	private init() {
		loadLessons()
	}
	
	private func loadLessons() {
		if let url = Bundle.main.url(forResource: "lesson", withExtension: "json") {
			print("Found lesson.json at: \(url)")
			if let data = try? Data(contentsOf: url) {
				let decoder = JSONDecoder()
				do {
					lessons = try decoder.decode(Lesson.self, from: data)
					print("Lesson JSON decoded successfully: \(String(describing: lessons))")
				} catch {
					print("Failed to decode lesson.json: \(error)")
				}
			} else {
				print("Failed to load data from lesson.json")
			}
		} else {
			print("lesson.json not found in bundle")
		}
	}
	
	func randomLesson(for language: String) -> String {
		let dict: [String: String]?
		switch language {
		case "en":
			dict = lessons?.en
		case "vi":
			dict = lessons?.vi
		default:
			dict = lessons?.en
		}
		print("Requested language: \(language), dictionary: \(String(describing: dict))")
		let random = dict?.values.randomElement() ?? ""
		print("Random lesson: \(random)")
		return random
	}
}

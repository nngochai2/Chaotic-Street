/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 11/09/2025
  Last modified: 11/09/2025
  Acknowledgement: See README
*/

import Foundation
import ObjectiveC

extension Bundle {
	private static var onLanguageDispatchOnce: () -> Void = {
		object_setClass(Bundle.main, PrivateBundle.self)
		return {}
	}()
	
	static func setLanguage(_ language: String) {
		onLanguageDispatchOnce()
		objc_setAssociatedObject(
			Bundle.main,
			&bundleKey,
			Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? ""),
			.OBJC_ASSOCIATION_RETAIN_NONATOMIC
		)
	}
	
	private static var bundleKey: UInt8 = 0
	
	private class PrivateBundle: Bundle, @unchecked Sendable {
		override func localizedString(forKey key: String, value: String?, table: String?) -> String {
			if let bundle = objc_getAssociatedObject(self, &Bundle.bundleKey) as? Bundle {
				return bundle.localizedString(forKey: key, value: value, table: table)
			} else {
				return super.localizedString(forKey: key, value: value, table: table)
			}
		}
	}
}

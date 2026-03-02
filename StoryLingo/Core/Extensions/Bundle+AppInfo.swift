//
//  Bundle+AppInfo.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var appBuild: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

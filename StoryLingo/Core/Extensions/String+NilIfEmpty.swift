//
//  String+NilIfEmpty.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

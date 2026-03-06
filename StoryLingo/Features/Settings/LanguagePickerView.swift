import SwiftUI
import CoreData

struct LanguagePickerView: View {
    let title: String
    let languages: [Language]
    let selectedLanguage: Language?
    let onSelect: (Language) -> Void

    var body: some View {
        List {
            ForEach(languages) { lang in
                Button {
                    onSelect(lang)
                } label: {
                    HStack(spacing: 12) {
                        Text(lang.flagEmojiSafe)
                            .font(.system(size: 22))

                        Text(lang.displayNameSafe)

                        Spacer()

                        if lang.objectID == selectedLanguage?.objectID {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}

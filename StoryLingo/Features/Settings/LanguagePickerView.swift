import SwiftUI
import CoreData

struct LanguagePickerView: View {
    let languages: [Language]
    @Binding var selection: Language

    var body: some View {
        List {
            ForEach(languages) { lang in
                Button {
                    selection = lang
                } label: {
                    HStack(spacing: 12) {
                        Text(lang.flagEmojiSafe).font(.system(size: 22))
                        Text(lang.displayNameSafe)
                        Spacer()
                        if lang.objectID == selection.objectID {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Target Language")
    }
}

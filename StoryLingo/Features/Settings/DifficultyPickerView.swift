import SwiftUI

struct DifficultyPickerView: View {
    let selection: DifficultyLevel
    let onSelect: (DifficultyLevel) -> Void

    var body: some View {
        List {
            ForEach(DifficultyLevel.allCases) { level in
                Button {
                    onSelect(level)
                } label: {
                    HStack {
                        Text(level.title)
                        Spacer()
                        if level == selection {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Difficulty Level")
    }
}

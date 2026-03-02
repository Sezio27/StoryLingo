import SwiftUI

struct DifficultyPickerView: View {
    @Binding var selection: DifficultyLevel

    var body: some View {
        List {
            ForEach(DifficultyLevel.allCases) { level in
                Button {
                    selection = level
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

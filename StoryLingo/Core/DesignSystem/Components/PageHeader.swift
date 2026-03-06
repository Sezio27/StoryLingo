import SwiftUI

struct PageHeader: View {
    let title: String
    let subtitle: LocalizedStringKey
    var showsBackButton: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(alignment: .top, spacing: showsBackButton ? 14 : 0) {

            if showsBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(Color(.systemBackground)))
                        .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .shadow(color: .black.opacity(0.08), radius: 14, y: 10)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }
}

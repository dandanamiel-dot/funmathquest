import SwiftUI

struct TableView: View {
    @EnvironmentObject private var languageStore: LanguageStore
    @State private var selectedRow = 1
    @State private var selectedColumn = 1

    private let numbers = Array(1...12)

    var body: some View {
        ZStack {
            PlayfulBackground()

            GeometryReader { geo in
                VStack(spacing: 16) {
                    header

                    ScrollView([.vertical, .horizontal]) {
                        grid
                            .padding(8)
                            .padding(.vertical, 28)
                            .padding(.horizontal, 24)
                            .frame(minWidth: geo.size.width - 32, alignment: .center)
                    }
                }
                .padding(16)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(languageStore.t(.multiplicationTable))
                .font(Theme.titleFont(26))
                .foregroundStyle(Theme.ink)
            Text(languageStore.t(.tapRowColumn))
                .font(Theme.bodyFont(16))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var grid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                cell("×", highlight: false, isHeader: true)
                ForEach(numbers, id: \.self) { number in
                    cell("\(number)", highlight: number == selectedColumn, isHeader: true)
                        .onTapGesture { selectedColumn = number }
                }
            }

            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 8) {
                    cell("\(row)", highlight: row == selectedRow, isHeader: true)
                        .onTapGesture { selectedRow = row }

                    ForEach(numbers, id: \.self) { column in
                        let highlight = row == selectedRow || column == selectedColumn
                        cell("\(row * column)", highlight: highlight, isHeader: false)
                            .onTapGesture {
                                selectedRow = row
                                selectedColumn = column
                            }
                    }
                }
            }
        }
    }

    private func cell(_ text: String, highlight: Bool, isHeader: Bool) -> some View {
        Text(text)
            .font(isHeader ? Theme.titleFont(16) : Theme.bodyFont(16))
            .frame(width: 44, height: 44)
            .background(highlight ? Theme.highlight : Theme.card, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    TableView()
        .environmentObject(LanguageStore())
}

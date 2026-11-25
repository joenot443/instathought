//
//  FontPickerView.swift
//  InstaThought
//
//  Created by Joe Crozier on 1/3/26.
//

import SwiftUI

struct FontPickerView: View {
    @Binding var selectedFont: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    // Recommended section
                    if searchText.isEmpty {
                        Section {
                            ForEach(FontLibrary.recommended, id: \.self) { font in
                                FontRow(
                                    fontName: font,
                                    isSelected: selectedFont == font,
                                    onSelect: { selectFont(font) }
                                )
                            }
                        } header: {
                            Text("Recommended")
                        }
                    }

                    // Search results or categorized fonts
                    if searchText.isEmpty {
                        ForEach(FontLibrary.categories, id: \.name) { category in
                            Section {
                                ForEach(category.fonts, id: \.self) { font in
                                    FontRow(
                                        fontName: font,
                                        isSelected: selectedFont == font,
                                        onSelect: { selectFont(font) }
                                    )
                                }
                            } header: {
                                Text(category.name)
                            }
                        }
                    } else {
                        Section {
                            ForEach(filteredFonts, id: \.self) { font in
                                FontRow(
                                    fontName: font,
                                    isSelected: selectedFont == font,
                                    onSelect: { selectFont(font) }
                                )
                            }
                        } header: {
                            Text("Results")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Cloud.sky)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search fonts")
                .navigationTitle("Font")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var filteredFonts: [String] {
        let allFonts = FontLibrary.allFonts
        guard !searchText.isEmpty else { return allFonts }
        return allFonts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private func selectFont(_ font: String) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        selectedFont = font
        dismiss()
    }
}

struct FontRow: View {
    let fontName: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(displayName)
                    .font(.custom(fontName, size: 18))
                    .foregroundStyle(Theme.shared.colors.primaryText)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Cloud.night)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Cloud.white)
    }

    private var displayName: String {
        // Clean up font names for display
        fontName
            .replacingOccurrences(of: "-Regular", with: "")
            .replacingOccurrences(of: "-Roman", with: "")
            .replacingOccurrences(of: "_Regular", with: "")
            .replacingOccurrences(of: "Roman-", with: "")
    }
}

// MARK: - Font Library

struct FontCategory {
    let name: String
    let fonts: [String]
}

struct FontLibrary {
    static let recommended: [String] = [
        "Helvetica",
        "Georgia",
        "Avenir Next",
        "Baskerville",
        "Futura",
        "Garamond",
        "Gill Sans",
        "Palatino",
        "Times New Roman",
        "SF Pro Display"
    ]

    static let categories: [FontCategory] = [
        FontCategory(name: "Sans Serif", fonts: [
            "Arial",
            "Avenir",
            "Avenir Next",
            "DIN Alternate",
            "Futura",
            "Gill Sans",
            "Helvetica",
            "Helvetica Neue",
            "Lato-Regular",
            "Montserrat-Regular",
            "MontserratRoman-Regular",
            "Nunito-Regular",
            "Open Sans",
            "OpenSans-Regular",
            "Poppins-Medium",
            "Quicksand-Regular",
            "Roboto-Regular",
            "SF Pro Display",
            "SF Pro Rounded",
            "SF Pro Text",
            "SourceSans3-Roman_Regular",
            "System Font"
        ]),
        FontCategory(name: "Serif", fonts: [
            "Alice-Regular",
            "Baskerville",
            "Cardo-Regular",
            "Charter",
            "CrimsonText-Regular",
            "EBGaramond-Regular",
            "FanwoodText-Regular",
            "FaunaOne-Regular",
            "Garamond",
            "Georgia",
            "Iowan Old Style",
            "Ledger-Regular",
            "LibreBaskerville-Regular",
            "Merriweather-Regular",
            "New York",
            "Palatino",
            "ProzaLibre-Regular",
            "PT Serif",
            "PTSans-Regular",
            "QuattrocentoSans",
            "SourceSerif4-Regular",
            "Times New Roman"
        ]),
        FontCategory(name: "Display", fonts: [
            "Academy Engraved LET",
            "American Typewriter",
            "Copperplate",
            "Didot",
            "JosefinSansRoman-Regular",
            "Marker Felt",
            "Noteworthy",
            "Optima",
            "Papyrus",
            "PontanoSans-Regular",
            "Rockwell",
            "Savoye LET",
            "Slabo27px-Regular",
            "Snell Roundhand",
            "Superclarendon",
            "Trattatello",
            "Zapfino"
        ]),
        FontCategory(name: "Monospace", fonts: [
            "Courier",
            "Courier New",
            "Inconsolata-Regular",
            "Menlo",
            "Monaco",
            "SF Mono"
        ]),
        FontCategory(name: "Handwritten", fonts: [
            "Andika",
            "Bradley Hand",
            "Brush Script MT",
            "Chalkboard SE",
            "Chalkduster",
            "Cochin",
            "Party LET",
            "SignPainter"
        ])
    ]

    static var allFonts: [String] {
        var fonts = Set(recommended)
        for category in categories {
            fonts.formUnion(category.fonts)
        }
        return fonts.sorted()
    }
}

#Preview {
    FontPickerView(selectedFont: .constant("Helvetica"))
}

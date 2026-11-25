//
//  FontPickerView.swift
//  InstaThought
//
//  The font chooser: a half-height sheet over the Style screen, so the page stays in view.
//  Every row shows the font's name and your own opening words in that font, and tapping a
//  row restyles the page straight away. Starred and recently used fonts sit at the top,
//  and a letter rail down the side jumps through the list.
//

import SwiftUI

// MARK: - Catalog

struct FontFace: Identifiable, Hashable {
  enum Kind: String, CaseIterable { case serif = "Serif", sans = "Sans", script = "Script", mono = "Mono" }
  /// The PostScript name stored in the style.
  let id: String
  let name: String
  let kind: Kind
}

enum FontCatalog {
  /// Every face offered, by kind. Bundled fonts plus the iOS system fonts that suit a page of text.
  private static let source: [(String, FontFace.Kind)] = [
    // Serif
    ("Alice-Regular", .serif), ("Baskerville", .serif), ("BodoniSvtyTwoITCTT-Book", .serif), ("Cardo-Regular", .serif),
    ("Charter-Roman", .serif), ("Cochin", .serif), ("CrimsonText-Regular", .serif), ("Didot", .serif),
    ("EBGaramond-Regular", .serif), ("FanwoodText-Regular", .serif), ("FaunaOne-Regular", .serif), ("Georgia", .serif),
    ("HoeflerText-Regular", .serif), ("IowanOldStyle-Roman", .serif), ("Ledger-Regular", .serif),
    ("LibreBaskerville-Regular", .serif), ("Lora-Regular", .serif), ("Merriweather-Regular", .serif),
    ("Palatino-Roman", .serif), ("PlayfairDisplay-Regular", .serif), ("Rockwell-Regular", .serif),
    ("Slabo27px-Regular", .serif), ("SourceSerif4-Regular", .serif), ("Superclarendon-Regular", .serif),
    ("TimesNewRomanPSMT", .serif), ("Copperplate", .serif),
    // Sans
    ("Andika", .sans), ("ArialMT", .sans), ("Avenir-Book", .sans), ("AvenirNext-Regular", .sans), ("Cabin-Regular", .sans),
    ("Cantarell-Regular", .sans), ("Futura-Medium", .sans), ("GillSans", .sans), ("Helvetica", .sans),
    ("HelveticaNeue", .sans), ("Hind-Medium", .sans), ("JosefinSansRoman-Regular", .sans), ("Karla-Regular", .sans),
    ("Lato-Regular", .sans), ("MontserratRoman-Regular", .sans), ("MulishRoman-Regular", .sans), ("Nunito-Regular", .sans),
    ("OpenSans-Regular", .sans), ("Optima-Regular", .sans), ("PontanoSans-Regular", .sans), ("Poppins-Medium", .sans),
    ("ProzaLibre-Regular", .sans), ("PTSans-Regular", .sans), ("QuattrocentoSans", .sans), ("Quicksand-Regular", .sans),
    ("Roboto-Regular", .sans), ("SourceSans3-Roman_Regular", .sans), ("Verdana", .sans),
    // Script and hand-drawn
    ("BradleyHandITCTT-Bold", .script), ("ChalkboardSE-Regular", .script), ("Chalkduster", .script),
    ("MarkerFelt-Thin", .script), ("Noteworthy-Light", .script), ("Papyrus", .script), ("PartyLetPlain", .script),
    ("SavoyeLetPlain", .script), ("SignPainter-HouseScript", .script), ("SnellRoundhand", .script), ("Zapfino", .script),
    // Mono and typewriter
    ("AmericanTypewriter", .mono), ("Courier", .mono), ("CourierNewPSMT", .mono), ("Inconsolata-Regular", .mono),
    ("Menlo-Regular", .mono),
  ]

  /// The faces that actually load on this device, A to Z.
  static let all: [FontFace] = source
    .compactMap { id, kind in UIFont(name: id, size: 17).map { FontFace(id: id, name: $0.familyName, kind: kind) } }
    .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

  private static let byID = Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

  /// A face for any stored font name, including ones from older drafts that aren't in the list.
  static func face(_ id: String) -> FontFace {
    byID[id] ?? FontFace(id: id, name: UIFont(name: id, size: 17)?.familyName ?? id, kind: .sans)
  }
}

// MARK: - Starred and recent

/// Starred and recently chosen fonts, kept between launches.
final class FontShelf: ObservableObject {
  static let shared = FontShelf()
  private let defaults = UserDefaults.standard

  @Published private(set) var starred: [String]
  @Published private(set) var recent: [String]

  private init() {
    starred = defaults.stringArray(forKey: "fonts.starred") ?? []
    recent = defaults.stringArray(forKey: "fonts.recent") ?? []
  }

  func isStarred(_ id: String) -> Bool { starred.contains(id) }

  func toggleStar(_ id: String) {
    if let index = starred.firstIndex(of: id) { starred.remove(at: index) } else { starred.append(id) }
    defaults.set(starred, forKey: "fonts.starred")
  }

  func used(_ id: String) {
    recent.removeAll { $0 == id }
    recent.insert(id, at: 0)
    recent = Array(recent.prefix(5))
    defaults.set(recent, forKey: "fonts.recent")
  }
}

// MARK: - Sheet

struct FontPickerView: View {
  @Binding var selectedFont: String
  /// Your own words, shown in every font.
  let sample: String
  @Environment(\.dismiss) private var dismiss
  @ObservedObject private var shelf = FontShelf.shared
  @State private var search = ""
  @State private var kind: FontFace.Kind? = nil
  /// The letter under the finger on the rail, shown big beside it.
  @State private var scrubLetter: String? = nil
  @FocusState private var isSearching: Bool

  private enum Filter: Hashable { case all, kind(FontFace.Kind) }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Font").font(Cloud.font(22, .black))
        Spacer()
        Button("Done") {
          Cloud.tap()
          dismiss()
        }
        .buttonStyle(CloudChipStyle(fill: Cloud.sun, ink: Cloud.onSun))
      }
      .padding(.horizontal, 18)
      .padding(.top, 18)
      .padding(.bottom, 10)

      searchField
        .padding(.horizontal, 18)
        .padding(.bottom, 10)

      CloudSegmented(options: [Filter.all] + FontFace.Kind.allCases.map(Filter.kind),
                     selection: Binding(get: { kind.map(Filter.kind) ?? .all },
                                        set: { if case .kind(let k) = $0 { kind = k } else { kind = nil } }),
                     height: 32,
                     accessibilityLabel: { label(for: $0) }) { filter, _ in
        Text(label(for: filter)).font(Cloud.font(14, .extraBold))
      }
      .padding(.horizontal, 18)
      .padding(.bottom, 6)

      list
    }
    .foregroundStyle(Cloud.night)
    .background(Cloud.white.ignoresSafeArea())
  }

  private func label(for filter: Filter) -> String {
    switch filter {
    case .all: return "All"
    case .kind(let k): return k.rawValue
    }
  }

  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .bold)).foregroundStyle(Cloud.quiet)
      TextField("", text: $search, prompt: Text("Search \(FontCatalog.all.count) fonts").foregroundStyle(Cloud.placeholder))
        .font(Cloud.font(16, .bold))
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .submitLabel(.search)
        .focused($isSearching)
      if !search.isEmpty {
        Button {
          search = ""
        } label: {
          Image(systemName: "xmark.circle.fill").font(.system(size: 16)).foregroundStyle(Cloud.soft)
        }
        .accessibilityLabel("Clear search")
      }
    }
    .padding(.horizontal, 14)
    .frame(height: 42)
    .cloudRecessed(Capsule())
  }

  // MARK: List

  private struct Section: Identifiable {
    let id: String
    let title: String
    let faces: [FontFace]
  }

  private var sections: [Section] {
    let query = search.trimmingCharacters(in: .whitespaces)
    let pool = FontCatalog.all.filter { kind == nil || $0.kind == kind }
    if !query.isEmpty {
      let hits = FontCatalog.all.filter { $0.name.localizedCaseInsensitiveContains(query) }
      return [Section(id: "results", title: hits.isEmpty ? "No fonts called “\(query)”" : "Results", faces: hits)]
    }
    var out: [Section] = []
    if kind == nil {
      let current = FontCatalog.face(selectedFont)
      let starred = shelf.starred.map(FontCatalog.face)
      if !starred.isEmpty { out.append(Section(id: "★", title: "Starred", faces: starred)) }
      let recent = shelf.recent.filter { !shelf.isStarred($0) }.map(FontCatalog.face)
      if !recent.isEmpty { out.append(Section(id: "◷", title: "Recent", faces: recent)) }
      // A font from an older draft that isn't in the list still shows, so it can be seen as chosen.
      if !FontCatalog.all.contains(where: { $0.id == current.id }), !shelf.isStarred(current.id), !shelf.recent.contains(current.id) {
        out.insert(Section(id: "•", title: "In use", faces: [current]), at: 0)
      }
    }
    let byLetter = Dictionary(grouping: pool) { String($0.name.prefix(1)).uppercased() }
    out += byLetter.keys.sorted().map { Section(id: $0, title: $0, faces: byLetter[$0]!) }
    return out
  }

  /// The letter section holding the font in use (not Starred or Recent).
  private var selectedSectionID: String? {
    sections.last { $0.faces.contains { $0.id == selectedFont } }?.id
  }

  private var list: some View {
    let sections = sections
    let rail = sections.map(\.id).filter { $0 != "results" && $0 != "•" }
    return ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: 2) {
          ForEach(sections) { section in
            Text(section.title)
              .font(Cloud.font(13, .black))
              .foregroundStyle(Cloud.quiet)
              .padding(.horizontal, 14)
              .padding(.top, 12)
              .padding(.bottom, 2)
              .id(section.id)
            ForEach(section.faces) { face in
              if face.id == selectedFont && section.id == selectedSectionID {
                // A marker just above the font in use, to scroll to when the sheet opens.
                Color.clear.frame(height: 0).id("selected")
              }
              FontRow(face: face, sample: sampleLine, isSelected: face.id == selectedFont,
                      isStarred: shelf.isStarred(face.id),
                      onSelect: { choose(face) },
                      onStar: { withAnimation(.snappy) { shelf.toggleStar(face.id) } })
            }
          }
        }
        .padding(.leading, 18)
        .padding(.trailing, rail.count > 1 ? 34 : 18)
        .padding(.bottom, 30)
      }
      .scrollDismissesKeyboard(.immediately)
      .task {
        // Open on the font in use, in its place in the A–Z list, once the sheet is up.
        try? await Task.sleep(for: .milliseconds(350))
        proxy.scrollTo("selected", anchor: .top)
      }
      .overlay(alignment: .trailing) {
        if rail.count > 1 {
          LetterRail(letters: rail, current: $scrubLetter) { letter in
            proxy.scrollTo(letter, anchor: .top)
          }
          .padding(.trailing, 4)
        }
      }
      .overlay(alignment: .trailing) {
        if let scrubLetter {
          Text(scrubLetter)
            .font(Cloud.font(26, .black))
            .foregroundStyle(Cloud.onSun)
            .frame(width: 56, height: 56)
            .cloudRaised(Circle(), fill: Cloud.sun, depth: 3, lineWidth: Cloud.line)
            .padding(.trailing, 46)
            .transition(.scale(scale: 0.6).combined(with: .opacity))
            .allowsHitTesting(false)
        }
      }
      .animation(.snappy(duration: 0.18), value: scrubLetter)
    }
  }

  /// The first words of your thought, or a stand-in if there's nothing yet.
  private var sampleLine: String {
    let words = sample.split(whereSeparator: \.isWhitespace).prefix(8).joined(separator: " ")
    return words.isEmpty ? "The quick brown fox jumps over the lazy dog" : words
  }

  private func choose(_ face: FontFace) {
    guard face.id != selectedFont else { return }
    Cloud.tick()
    selectedFont = face.id
    shelf.used(face.id)
  }
}

// MARK: - Row

struct FontRow: View {
  let face: FontFace
  let sample: String
  let isSelected: Bool
  let isStarred: Bool
  let onSelect: () -> Void
  let onStar: () -> Void

  var body: some View {
    HStack(spacing: 6) {
      Button(action: onSelect) {
        VStack(alignment: .leading, spacing: 1) {
          Text(face.name)
            .font(.custom(face.id, size: 21))
            .lineLimit(1)
          Text(sample)
            .font(.custom(face.id, size: 15))
            .foregroundStyle(Cloud.quiet)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel(face.name)
      .accessibilityAddTraits(isSelected ? .isSelected : [])

      if isSelected {
        Image(systemName: "checkmark")
          .font(.system(size: 11, weight: .black))
          .foregroundStyle(Cloud.onSun)
          .frame(width: 24, height: 24)
          .background(Circle().fill(Cloud.sun))
          .overlay(Circle().strokeBorder(Cloud.stroke, lineWidth: Cloud.controlLine))
          .accessibilityHidden(true)
      }
      Button(action: onStar) {
        Image(systemName: isStarred ? "star.fill" : "star")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(isStarred ? Cloud.sunInk : Cloud.soft)
          .frame(width: 36, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel(isStarred ? "Unstar \(face.name)" : "Star \(face.name)")
    }
    .foregroundStyle(Cloud.night)
    .padding(.leading, 14)
    .padding(.trailing, 4)
    .padding(.vertical, 6)
    .background {
      if isSelected {
        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Cloud.thumb)
          .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Cloud.stroke, lineWidth: Cloud.controlLine))
          .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Cloud.edge).offset(y: 3))
      }
    }
    .padding(.bottom, isSelected ? 3 : 0)
  }
}

// MARK: - Letter rail

/// Drag (or tap) down the rail to jump through the list, with a click at each new letter.
struct LetterRail: View {
  let letters: [String]
  @Binding var current: String?
  let onLetter: (String) -> Void

  var body: some View {
    GeometryReader { geo in
      let rowHeight = min(16, geo.size.height / CGFloat(max(letters.count, 1)))
      VStack(spacing: 0) {
        ForEach(letters, id: \.self) { letter in
          Text(letter)
            .font(Cloud.font(11, .black))
            .foregroundStyle(current == letter ? Cloud.night : Cloud.quiet)
            .frame(width: 24, height: rowHeight)
        }
      }
      .frame(maxHeight: .infinity)
      .contentShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            let top = (geo.size.height - rowHeight * CGFloat(letters.count)) / 2
            let index = Int((value.location.y - top) / rowHeight)
            let letter = letters[min(max(index, 0), letters.count - 1)]
            if letter != current {
              current = letter
              Cloud.tick()
              onLetter(letter)
            }
          }
          .onEnded { _ in current = nil }
      )
    }
    .frame(width: 24)
    .padding(.vertical, 8)
    .accessibilityElement()
    .accessibilityLabel("Jump to letter")
    .accessibilityAdjustableAction { direction in
      let index = letters.firstIndex(of: current ?? letters[0]) ?? 0
      let next = direction == .increment ? min(index + 1, letters.count - 1) : max(index - 1, 0)
      onLetter(letters[next])
      current = nil
    }
  }
}

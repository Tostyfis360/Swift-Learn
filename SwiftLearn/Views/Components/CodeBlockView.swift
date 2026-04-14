import SwiftUI

// MARK: - CodeBlockView
// Syntax highlighting using AttributedString (iOS 26 compatible)

struct CodeBlockView: View {
    let code: String
    var fontSize: CGFloat = 13

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(highlighted(code))
                .font(.system(size: fontSize, design: .monospaced))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .background(Color(hex: "0A0F1A"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    // MARK: - AttributedString builder

    private func highlighted(_ source: String) -> AttributedString {
        var result = AttributedString()
        let lines = source.components(separatedBy: "\n")
        for (i, line) in lines.enumerated() {
            result.append(highlightLine(line))
            if i < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }
        return result
    }

    private func highlightLine(_ line: String) -> AttributedString {
        // Full-line comment
        if let commentIdx = line.range(of: "//") {
            let codePart    = String(line[line.startIndex..<commentIdx.lowerBound])
            let commentPart = String(line[commentIdx.lowerBound...])
            var result = tokenizeLine(codePart)
            var comment = AttributedString(commentPart)
            comment.foregroundColor = UIColor(hex: "6A7B8C")
            result.append(comment)
            return result
        }
        return tokenizeLine(line)
    }

    private func tokenizeLine(_ text: String) -> AttributedString {
        var result = AttributedString()
        var remaining = text[text.startIndex...]

        while !remaining.isEmpty {
            // String literal
            if remaining.first == "\"" {
                let after = remaining.dropFirst()
                if let closeIdx = after.firstIndex(of: "\"") {
                    let strRange = remaining.startIndex...closeIdx
                    var token = AttributedString(String(remaining[strRange]))
                    token.foregroundColor = UIColor(hex: "FF9050")
                    result.append(token)
                    remaining = remaining[remaining.index(after: closeIdx)...]
                    continue
                }
            }

            // Word boundary
            if let wordEnd = remaining.firstIndex(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "@" }) {
                let word = String(remaining[remaining.startIndex..<wordEnd])
                if !word.isEmpty {
                    result.append(colored(word))
                    remaining = remaining[wordEnd...]
                    continue
                }
                // Single non-word character
                var ch = AttributedString(String(remaining.first!))
                ch.foregroundColor = UIColor(hex: "C8D8E8")
                result.append(ch)
                remaining = remaining.dropFirst()
            } else {
                result.append(colored(String(remaining)))
                break
            }
        }
        return result
    }

    private func colored(_ word: String) -> AttributedString {
        var attr = AttributedString(word)
        attr.foregroundColor = tokenColor(for: word)
        return attr
    }

    private func tokenColor(for word: String) -> UIColor {
        let keywords: Set<String> = [
            "let", "var", "func", "class", "struct", "enum", "if", "else",
            "guard", "return", "async", "await", "actor", "throws", "throw",
            "try", "for", "in", "while", "switch", "case", "default", "where",
            "import", "protocol", "extension", "init", "self", "super",
            "static", "final", "override", "private", "public", "internal",
            "weak", "unowned", "lazy", "mutating", "nil", "true", "false",
            "do", "catch", "break", "continue", "Task", "@MainActor",
            "@Observable", "@State", "@Binding", "@Environment",
            "nonisolated", "some", "any"
        ]
        let typeNames: Set<String> = [
            "String", "Int", "Double", "Float", "Bool", "Data", "Date",
            "URL", "Array", "Dictionary", "Set", "Optional", "Result",
            "Error", "View", "Void", "AnyObject", "Character", "UInt"
        ]

        if keywords.contains(word)             { return UIColor(hex: "00D4FF") }   // cyan
        if typeNames.contains(word)            { return UIColor(hex: "7EE8A2") }   // green
        if word.first?.isUppercase == true     { return UIColor(hex: "7EE8A2") }   // green (types)
        return UIColor(hex: "C8D8E8")                                               // white
    }
}

// MARK: - UIColor hex helper

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8)  & 0xFF) / 255
        let b = CGFloat(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - Preview

#Preview {
    CodeBlockView(code: """
    @Observable
    class ViewModel {
        var items: [String] = []

        func load() async throws {
            // Carga datos del servidor
            items = try await api.fetchItems()
        }
    }
    """)
    .padding()
    .background(Color(hex: "050A14"))
}

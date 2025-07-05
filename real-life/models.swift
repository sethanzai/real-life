import Foundation
import SwiftUI

struct Category: Decodable, Identifiable {
    let id = UUID()
    let label: String
    let color: String
    let questions: [Question]

    enum CodingKeys: String, CodingKey {
        case label, color, questions
    }
}

struct Question: Decodable, Hashable {
    let q: String?
    let a: String?
    let text: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.text = stringValue
            self.q = nil
            self.a = nil
        } else {
            let objectContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.q = try objectContainer.decodeIfPresent(String.self, forKey: .q)
            self.a = try objectContainer.decodeIfPresent(String.self, forKey: .a)
            self.text = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case q, a
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

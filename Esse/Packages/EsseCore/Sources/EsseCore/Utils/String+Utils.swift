import Foundation
import NaturalLanguage

public extension String {
    func lowercaseFirst() -> String {
        guard count > 0 else { return self }

        let indexOfSecondChar = index(startIndex, offsetBy: 1)
        return String(self[startIndex]).lowercased() + String(self[indexOfSecondChar...])
    }

    func capitaliseFirst() -> String {
        guard count > 0 else { return self }

        let indexOfSecondChar = index(startIndex, offsetBy: 1)
        return String(self[startIndex]).capitalized + String(self[indexOfSecondChar...])
    }

    func toArray() -> [String] {
        components(separatedBy: "\n")
    }

    func getUnits(of unitType: NSLinguisticTaggerUnit) -> [String] {
        guard count > 0 else { return [] }

        var units = [String]()
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .joinNames]
        tagger.string = self
        let range = NSRange(location: 0, length: utf16.count)
        tagger.enumerateTags(in: range, unit: unitType, scheme: .tokenType, options: options) { _, tokenRange, _ in
            let unit = (self as NSString).substring(with: tokenRange)
            units.append(unit)
        }
        return units
    }

    func words() -> [String] {
        let range = Range(uncheckedBounds: (lower: startIndex, endIndex))
        var words = [String]()

        enumerateSubstrings(in: range, options: NSString.EnumerationOptions.byWords) { substring, _, _, _ in
            if let substring {
                words.append(substring)
            }
        }

        return words
    }

    func inserting(separator: String, every n: Int) -> String {
        var result = ""
        let characters = Array(self)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0 ..< min($0 + n, characters.count)])
            if $0 + n < characters.count {
                result += separator
            }
        }
        return result
    }

    /// word - lemma
    func lemmas() -> [String: String] {
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

        var result: [String: String] = [:]

        tagger.string = self
        let range = NSRange(location: 0, length: utf16.count)

        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange, _ in
            let word = (self as NSString).substring(with: tokenRange)
            if let lemma = tag?.rawValue {
                print("Lemma: \(lemma)")
                result[word] = lemma
            }
        }

        return result
    }

    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }

    subscript(_ range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        let subString = self[start ..< end]
        return String(subString)
    }
}

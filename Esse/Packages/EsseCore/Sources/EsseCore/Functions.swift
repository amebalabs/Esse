import CryptoKit
import Foundation

// MARK: Case Functions

struct CaseFunctions {
    static let all: [TextFunction] = [
        lowerCase,
        upperCase,
        capitaliseWords,
        sentenceCase,
        camelCase,
        snakeCase,
        paskalCase,
        randomCase,
        kebabCase,
        chmosCase,
    ]

    static let lowerCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.lowerCase", title: "Lowercase", description: "Returns a version of the text with all letters converted to lowercase", category: .Case) { text -> String in
        text.localizedLowercase
    }

    static let upperCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.upperCase", title: "Uppercase", description: "Returns a version of the text with all letters converted to uppercase", category: .Case) { text -> String in
        text.localizedUppercase
    }

    static let sentenceCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.sentenceCase", title: "Sentence Case", description: "Replaces the first character in each sentence to its corresponding uppercase value", category: .Case) { text -> String in
        var sentences = text.getUnits(of: .sentence)
        return sentences.map { $0.capitaliseFirst() }.reduce("", +)
    }

    static let capitaliseWords = TextFunction(id: "co.ameba.Esse.CaseFunctions.capitaliseWords", title: "Capitalize Words", description: "Replace the first character in each word changed to its corresponding uppercase value, and all remaining characters set to their corresponding lowercase values.", category: .Case) { text -> String in
        text.localizedCapitalized
    }

    static let camelCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.camelCase", title: "Camel Case", description: "Transforms by concatenating capitalized words but first character is lowercased", category: .Case) { text -> String in
        guard text.count > 0 else { return "" }

        var words = text.words()
        guard words.count > 0 else { return "" }

        words = words.map(\.localizedCapitalized)
        words[0] = words[0].localizedLowercase
        return words.reduce("", +)
    }

    static let snakeCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.snakeCase", title: "Snake Case", description: "Transforms by separating words with underscore symbol (_) instead of a space", category: .Case) { text -> String in
        guard text.count > 0 else { return "" }

        var words = text.words()
        guard words.count > 0 else { return "" }

        return words.joined(separator: "_")
    }

    static let kebabCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.kebabCase", title: "Kebab Case", description: "Transforms by separating words with dash symbol (-) instead of a space", category: .Case) { text -> String in
        guard text.count > 0 else { return "" }

        var words = text.words()
        guard words.count > 0 else { return "" }

        return words.joined(separator: "-")
    }

    static let paskalCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.paskalCase", title: "Pascal Case", description: "Transforms by concatenating capitalized words", category: .Case) { text -> String in
        guard text.count > 0 else { return "" }

        var words = text.words()
        guard words.count > 0 else { return "" }

        return words.map(\.localizedCapitalized).joined(separator: "")
    }

    static let randomCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.randomCase", title: "RaNdOm CasE", description: "Transforms by RaNdOmLy applying uppercase or lowercase to each character", category: .Case) { text -> String in
        guard text.count > 0 else { return "" }
        var newText = ""
        for char in text {
            if Bool.random() {
                newText.append(String(char).uppercased())
                continue
            }
            newText.append(String(char).lowercased())
        }
        return newText
    }

    static let chmosCase = TextFunction(id: "co.ameba.Esse.CaseFunctions.chmosCase", title: "Chicago Manual of Style", description: "Do Not Capitalize Words Based on Length", category: .Case) { text -> String in
        let text = [text].map { CleaningFunctions.collapseWhitespace.run($0) }.map { CaseFunctions.lowerCase.run($0) }.first
        guard var cleaned = text, !cleaned.isEmpty else { return "" }
        cleaned = cmosJS(text: cleaned)

        var words = cleaned.components(separatedBy: " ")
        words[0] = capitaliseWords.run(words[0])
        words[words.endIndex - 1] = capitaliseWords.run(words[words.endIndex - 1])
        let lowercased: Set = ["about", "above", "across", "after", "against", "along", "among", "around", "at", "before", "behind", "below", "beneath", "beside", "between", "beyond", "but", "by", "despite", "down", "during", "except", "for", "from", "in", "inside", "into", "like", "near", "of", "off", "on", "onto", "out", "outside", "over", "past", "per", "since", "through", "throughout", "till", "to", "toward", "under", "underneath", "until", "up", "upon", "via", "with", "within", "without", "a", "an", "the", "and", "but", "or", "nor", "for", "yet", "so", "if", "en", "as", "vs.", "v."]
        let exceptions: Set = ["macOS", "iPhone", "iPad", "MacBook", "iMac", "iPod", "MacPro", "iOS", "tvOS", "HomePod", "OmniFocus"]

        words = words.map { word in
            let wordLowercased = word.lowercased()
            for exception in exceptions {
                if wordLowercased == exception.lowercased() {
                    return exception
                }
            }

            if lowercased.contains(word) {
                return lowerCase.run(word)
            }

            if word.contains("://") || word.contains("@") || wordLowercased.contains(".com") || wordLowercased.contains(".net") {
                return lowerCase.run(word)
            }

            return word
        }
        return words.joined(separator: " ")
    }
}

// MARK: ASCII

enum ASCIIFunctions {
    static let all: [TextFunction] = [
        ASCIICowSay,
        signBunny,
    ]

    static func speechBubble(_ text: String) -> String {
        let maxStringLength = 40
        var out = ""
        if text.count <= maxStringLength, !text.contains("\n") {
            let border = String(repeating: "-", count: text.count + 2)
            out = "  " + border + "\n"
                + "< " + text + " >" + "\n"
                + "  " + border
            return out
        }
        var longestLine = 0
        var intermidiateResult = ""
        for line in text.components(separatedBy: "\n") {
            if line.count > maxStringLength {
                for line in line.inserting(separator: "\n", every: maxStringLength).components(separatedBy: "\n") {
                    intermidiateResult = intermidiateResult + line + "\n"
                }
                longestLine = maxStringLength
                continue
            }
            intermidiateResult = intermidiateResult + line + "\n"
            longestLine = max(longestLine, line.count)
        }

        for line in intermidiateResult.dropLast().components(separatedBy: "\n") {
            out = out + "| " + line + String(repeating: " ", count: longestLine - line.count) + " |" + "\n"
        }
        let border = " " + String(repeating: "-", count: longestLine + 2)
        out = [border, String(out.dropLast()), border].joined(separator: "\n")

        return out
    }

    static func cowOne() -> String {
        """
             \\   ^__^
              \\ (oo)\\_______
                 (__)\\            )\\/\\
                      ||----w |
                      ||          ||
        """
    }

    static func attachToBubble(_ text: String, bubble: String) -> String {
        var out = ""
        out = bubble + "\n"
        let padding = String(repeating: " ", count: 3)
        for line in text.components(separatedBy: "\n") {
            out = out + padding + line + "\n"
        }
        return out
    }

    static let ASCIICowSay = TextFunction(id: "co.ameba.Esse.ASCIIFunctions.ASCIICowSay", title: "Cowsay", description: "Cow says whatever you want! Non-monospaced font, may look odd...", category: .ASCII) { text -> String in
        guard text != "" else { return "" }
        return attachToBubble(cowOne(), bubble: speechBubble(text))
    }

    static func textSign(_ text: String) -> String {
        let maxStringLength = 30
        var out = ""

        var longestLine = 0
        var intermidiateResult = ""
        for line in text.components(separatedBy: "\n") {
            if line.count > maxStringLength {
                for line in line.inserting(separator: "\n", every: maxStringLength).components(separatedBy: "\n") {
                    intermidiateResult = intermidiateResult + line + "\n"
                }
                longestLine = maxStringLength
                continue
            }
            intermidiateResult = intermidiateResult + line + "\n"
            longestLine = max(longestLine, line.count)
        }

        for line in intermidiateResult.dropLast().components(separatedBy: "\n") {
            out = out + "| " + line + String(repeating: " ", count: longestLine - line.count) + " |" + "\n"
        }
        let upBorder = " " + String(repeating: "_", count: longestLine + 2)
        let downBorder = "|" + String(repeating: "_", count: longestLine + 2) + "|"
        out = [upBorder, String(out.dropLast()), downBorder].joined(separator: "\n")

        return out
    }

    static func attachToSign(_ text: String, sign: String) -> String {
        var out = ""
        let shift = sign.components(separatedBy: "\n").first!.count >= 12 ? 5 : (14 - text.components(separatedBy: "\n").first!.count / 2)
        let padding = String(repeating: " ", count: shift)
        for line in sign.components(separatedBy: "\n") {
            out = out + padding + line + "\n"
        }
        out = out + text
        return out
    }

    static func bunnyOne() -> String {
        """
            (\\__/)  ||
            (•ㅅ•) ||
            / 　 づ
        """
    }

    static let signBunny = TextFunction(id: "co.ameba.Esse.ASCIIFunctions.signBunny", title: "Sign Bunny", description: "Bunny with an important message! Non-monospaced font, may look odd...", category: .ASCII) { text -> String in
        guard text != "" else { return "" }
        return attachToSign(bunnyOne(), sign: textSign(text))
    }
}

// MARK: Quatation Marks

enum QuotationMarksFunctions {
    static let all: [TextFunction] = [
        curvedQuotes,
        striaghtQuotes,
        angleQuotes,
        CJKQuotes,
        singleToDoubleQuotes,
        doubleToSingleQuotes,
        smartWrapInQuotes,
        wrapParagraphInQuotes,
        removeSentenceQuotes,
    ]
    struct Quotes {
        let openning: String
        let closing: String
    }

    enum QuotesTypes {
        case Guillemet
        case Straight
        case Angle
        case CJK
    }

    private static let doubleQuotes: [QuotesTypes: Quotes] = [
        .Guillemet: Quotes(openning: "«", closing: "»"),
        .Straight: Quotes(openning: "\"", closing: "\""),
        .Angle: Quotes(openning: "“", closing: "”"),
        .CJK: Quotes(openning: "「", closing: "」"),
    ]
    private static let singleQuotes: [QuotesTypes: Quotes] = [
        .Guillemet: Quotes(openning: "‹", closing: "›"),
        .Straight: Quotes(openning: "\'", closing: "\'"),
        .Angle: Quotes(openning: "‘", closing: "’"),
        .CJK: Quotes(openning: "「", closing: "」"),
    ]

    static func replaceAllDoubleQuotes(with quoteType: QuotesTypes, input: String) -> String {
        guard let quote = doubleQuotes[quoteType] else { return input }
        var out = input
        for dq in doubleQuotes.values {
            out = out.replacingOccurrences(of: dq.openning, with: quote.openning).replacingOccurrences(of: dq.closing, with: quote.closing)
        }
        return out
    }

    static func replaceAllSingleQuotes(with quoteType: QuotesTypes, input: String) -> String {
        guard let quote = singleQuotes[quoteType] else { return input }
        var out = input
        for dq in singleQuotes.values {
            out = out.replacingOccurrences(of: dq.openning, with: quote.openning).replacingOccurrences(of: dq.closing, with: quote.closing)
        }
        return out
    }

    static let curvedQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.curvedQuotes", title: "Guillemet Quotes", description: "Replace all quotes with Guillemet(Angle) quotes", category: .QuotationMarks) { text -> String in
        text.replaceAllQuotes(with: .Guillemet)
    }

    static let striaghtQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.striaghtQuotes", title: "Straight Quotes", description: "Replace all quotes with Straight quotes", category: .QuotationMarks) { text -> String in
        text.replaceAllQuotes(with: .Straight)
    }

    static let angleQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.angleQuotes", title: "Curly Quotes", description: "Replace all quotes with Curly(Citation) quotes", category: .QuotationMarks) { text -> String in
        text.replaceAllQuotes(with: .Angle)
    }

    static let CJKQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.CJKQuotes", title: "CJK Quotes", description: "Replace all quotes with CJK Brackets", category: .QuotationMarks) { text -> String in
        text.replaceAllQuotes(with: .CJK)
    }

    static let singleToDoubleQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.singleToDoubleQuotes", title: "Single to Double Quotes", description: "Replace all single quotes with double quotes", category: .QuotationMarks) { text -> String in
        var out = text
        for (type, quote) in singleQuotes {
            out = out.replacingOccurrences(of: quote.openning, with: doubleQuotes[type]!.openning).replacingOccurrences(of: quote.closing, with: doubleQuotes[type]!.closing)
        }
        return out
    }

    static let doubleToSingleQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.doubleToSingleQuotes", title: "Double to Single Quotes", description: "Replace all double quotes with single quotes", category: .QuotationMarks) { text -> String in
        var out = text
        for (type, quote) in doubleQuotes {
            out = out.replacingOccurrences(of: quote.openning, with: singleQuotes[type]!.openning).replacingOccurrences(of: quote.closing, with: singleQuotes[type]!.closing)
        }
        return out
    }

    static let _wrapInQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions._wrapInQuotes", title: "Wrap in Quotes", description: "Wraps provided text in quotes", category: .QuotationMarks) { text -> String in
        doubleQuotes[.Angle]!.openning + text + doubleQuotes[.Angle]!.closing
    }

    static let smartWrapInQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.smartWrapInQuotes", title: "Wrap in Quotes", description: "Wraps provided text in quotes, replacing all existing double quotes with single quotes", category: .QuotationMarks) { text -> String in

        QuotationMarksFunctions._wrapInQuotes.run(
            QuotationMarksFunctions.doubleToSingleQuotes.run(text)
        )
    }

    static let wrapParagraphInQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.wrapParagraphInQuotes", title: "Wrap Paragraph in Quotes", description: "Wraps each paragraph in provided text in quotes, replacing all existing double quotes with single quotes", category: .QuotationMarks) { text -> String in

        text.components(separatedBy: .newlines).map { text in
            let out = QuotationMarksFunctions._wrapInQuotes.run(
                QuotationMarksFunctions.doubleToSingleQuotes.run(text)
            )
            return out.count == 2 ? "" : out
        }.joined(separator: "\n")
    }

    static let removeSentenceQuotes = TextFunction(id: "co.ameba.Esse.QuotationMarksFunctions.removeSentenceQuotes", title: "Unquote Sentence", description: "Unquotes sentence, ignores quotes within the sentence.", category: .QuotationMarks) { text -> String in
        let allQuotes = doubleQuotes.values.map(\.openning) + doubleQuotes.values.map(\.closing)
            + singleQuotes.values.map(\.openning) + singleQuotes.values.map(\.closing)
        return text.components(separatedBy: .newlines).map { text in
            text.getUnits(of: .sentence).map { sentence -> String in
                var out = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let first = out.first, let last = out.last else { return "" }

                if allQuotes.contains(String(first)), allQuotes.contains(String(last)) {
                    out = String(out.dropFirst())
                    out = String(out.dropLast())
                }
                return out
            }.joined(separator: " ")
        }.joined(separator: "\n")
    }
}

// MARK: Cleaning

enum CleaningFunctions {
    static let all: [TextFunction] = [
        removeSpaces,
        removeQuotePrefixes,
        removeEmptyLines,
        removeLineNumbers,
        removeDuplicateLines,
        collapseWhitespace,
        removeNewLines,
        removeNonDigitCharacters,
        removeDigitCharacters,
        removeNonAlphaNumericCharacters,
        removeNonAlphaNumericCharactersPlus,
        //        removeJunkFromURL
    ]

    static let removeSpaces = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeSpaces", title: "Truncate Spaces", description: "Removes empty space in the beginning and end of the text", category: .Cleaning) { text -> String in
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static let removeQuotePrefixes = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeQuotePrefixes", title: "Remove Quote Prefixes", description: "Cleans quotes marks(>>) from the beginning of each line in text", category: .Cleaning) { text -> String in
        let components = text.components(separatedBy: .newlines)
        return components.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: ">")) }.joined(separator: "\n")
    }

    static let removeEmptyLines = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeEmptyLines", title: "Remove Empty Lines", description: "Removes all empty lines from text", category: .Cleaning) { text -> String in
        let components = text.components(separatedBy: .newlines)
        return components.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static let removeLineNumbers = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeLineNumbers", title: "Remove Line Numbers", description: "Removes line numbers from a numbered list", category: .Cleaning) { text -> String in
        let components = text.components(separatedBy: .newlines)
        return components.map { $0.trimmingCharacters(in: .decimalDigits)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
            .trimmingCharacters(in: .whitespaces)
        }.joined(separator: "\n")
    }

    static let removeDuplicateLines = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeDuplicateLines", title: "Remove Duplicate Lines", description: "Removes duplicate lines", category: .Cleaning) { text -> String in
        text.toArray().removingDuplicates().joined(separator: "\n")
    }

    static let collapseWhitespace = TextFunction(id: "co.ameba.Esse.CleaningFunctions.collapseWhitespace", title: "Remove White Space", description: "Truncates empty space, including empty lines, tabs and multiple spaces", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines)
            .map { $0.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }.joined(separator: " ")
            }
            .joined(separator: "\n")
    }

    static let removeNewLines = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeNewLines", title: "Remove New Lines", description: "Removes new lines, merging all in, separated by a space", category: .Cleaning) { text -> String in
        let components = text.components(separatedBy: .newlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    static let removeNonDigitCharacters = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeNonDigitCharacters", title: "Strip non Numeric Characters", description: "Removes all non numeric characters", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            line.replacingOccurrences(of: "[^\\d]", with: "", options: String.CompareOptions.regularExpression, range: line.startIndex ..< line.endIndex)
        }.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static let removeDigitCharacters = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeDigitCharacters", title: "Strip Numeric Characters", description: "Removes all numeric characters", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            line.words().map { $0.components(separatedBy: .decimalDigits).joined() }.joined(separator: " ")
        }.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static let removeNonAlphaNumericCharacters = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeNonAlphaNumericCharacters", title: "Strip non Alphanumeric Characters", description: "Removes all non alphanumeric characters, spaces and new lines stay in place", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            line.words().map { $0.components(separatedBy: CharacterSet.alphanumerics.inverted).joined() }.joined(separator: " ")
        }.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static let removeNonAlphaNumericCharactersPlus = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeNonAlphaNumericCharactersPlus", title: "Strip non Alphanumeric Characters Plus", description: "Removes all non alphanumeric characters, spaces, new lines and punctuation stay in place", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            line.filter { $0.isLetter || $0.isNumber || $0.isWhitespace || [".", ",", "!", ":", ";", "?", "@", "$", "%", "'", "/", "\\"].contains($0) }
        }.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static let removeJunkFromURL = TextFunction(id: "co.ameba.Esse.CleaningFunctions.removeJunkFromURL", title: "Clean URL from Junk", description: "Cleans clutter from URLs such as all sorts of UTM tracking and subdomains like m. for mobile sites", category: .Cleaning) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            line.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        }.filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

// MARK: Convert

enum ConvertFunctions {
    static let all: [TextFunction] = [
        increaseIndent,
        decreaseIndent,
        sortLinesAscending,
        sortLinesDescending,
        shuffleWords,
        shuffleSentences,
        spellOutNumbers,
    ]

    static let increaseIndent = TextFunction(id: "co.ameba.Esse.ConvertFunctions.increaseIndent", title: "Increase Indent", description: "Adds tab in the beginning of each line, increasing indentation", category: .Convert) { text -> String in
        text.components(separatedBy: .newlines).map { "\t" + $0 }.joined(separator: "\n")
    }

    static let decreaseIndent = TextFunction(id: "co.ameba.Esse.ConvertFunctions.decreaseIndent", title: "Decrease Indent", description: "Removes tab in the beginning of each line, decreasing indentation", category: .Convert) { text -> String in
        text.components(separatedBy: .newlines)
            .map { str in
                if str.first == "\t" {
                    return String(str.dropFirst())
                }
                return str
            }.joined(separator: "\n")
    }

    static let sortLinesAscending = TextFunction(id: "co.ameba.Esse.ConvertFunctions.sortLinesAscending", title: "Sort Lines Ascending", description: "Sorts lines in accessing order", category: .Convert) { text -> String in
        var arr = text.toArray()
        arr.sort { $0.localizedCompare($1) == ComparisonResult.orderedAscending }
        return arr.joined(separator: "\n")
    }

    static let sortLinesDescending = TextFunction(id: "co.ameba.Esse.ConvertFunctions.sortLinesDescending", title: "Sort Lines Descending", description: "Sorts lines in descending order", category: .Convert) { text -> String in
        var arr = text.toArray()
        arr.sort { $0.localizedCompare($1) == ComparisonResult.orderedDescending }
        return arr.joined(separator: "\n")
    }

    static let shuffleWords = TextFunction(id: "co.ameba.Esse.ConvertFunctions.shuffleWords", title: "Shuffle Words", description: "Randomly shuffles words", category: .Convert) { text -> String in
        text.words().shuffled().joined(separator: " ")
    }

    static let shuffleSentences = TextFunction(id: "co.ameba.Esse.ConvertFunctions.shuffleSentences", title: "Shuffle Sentences", description: "Randomly shuffles sentences", category: .Convert) { text -> String in
        text.getUnits(of: .sentence).shuffled().joined(separator: " ")
    }

    static let spellOutNumbers = TextFunction(id: "co.ameba.Esse.ConvertFunctions.spellOutNumbers", title: "Spell Out Numbers", description: "Converts all numbers into words, i.e. 9 ->'nine', 22 -> 'twenty two', etc.", category: .Convert) { text -> String in
        text.components(separatedBy: .newlines).map { line -> String in
            replaceNumberWithSpellOut(input: line)
        }.joined(separator: "\n")
    }

    static func replaceNumberWithSpellOut(input: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.spellOut

        return input.components(separatedBy: .whitespaces).map { word -> String in
            guard let number = Int(word), let spellOutText = formatter.string(for: number) else { return word }
            return spellOutText
        }.joined(separator: " ")
    }
}

enum ExtractFunctions {
    static let all: [TextFunction] = [
        extractURL,
        extractPhone,
        extractDate,
        extractEmail,
        extractAddress,
    ]

    static let extractURL = TextFunction(id: "co.ameba.Esse.ExtractFunctions.extractURL", title: "Extract URLs", description: "Extracts URLs from given text, outputs one URL per line.", category: .Extract) { text -> String in
        var urls: [String] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            detector.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.count), using: { result, _, _ in
                if let match = result, let url = match.url {
                    urls.append(url.absoluteString)
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls.joined(separator: "\n")
    }

    static let extractPhone = TextFunction(id: "co.ameba.Esse.ExtractFunctions.extractPhone", title: "Extract Phone Numbers", description: "Extracts phone numbers from given text, outputs one phone per line.", category: .Extract) { text -> String in
        var phones: [String] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            detector.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.count), using: { result, _, _ in
                if let match = result, let phone = match.phoneNumber {
                    phones.append(phone)
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return phones.joined(separator: "\n")
    }

    static let extractDate = TextFunction(id: "co.ameba.Esse.ExtractFunctions.extractDate", title: "Extract Dates", description: "Extracts dates from given text, outputs one date per line.", category: .Extract) { text -> String in
        var phones: [String] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            detector.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.count), using: { result, _, _ in
                if let match = result, let date = match.date {
                    phones.append(text[match.range])
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return phones.joined(separator: "\n")
    }

    static let extractAddress = TextFunction(id: "co.ameba.Esse.ExtractFunctions.extractAddress", title: "Extract Address", description: "Extracts addresses from given text, outputs one date per line.", category: .Extract) { text -> String in
        var address: [String] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
            detector.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.count), using: { result, _, _ in
                if let match = result, let _ = match.addressComponents {
                    address.append(text[match.range])
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return address.joined(separator: "\n")
    }

    static let extractEmail = TextFunction(id: "co.ameba.Esse.ExtractFunctions.extractEmail", title: "Extract Emails", description: "Extracts emails from given text, outputs one email per line.", category: .Extract) { text -> String in
        text.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { $0.isValidEmail() }.joined(separator: "\n")
    }
}

// MARK: Developer

enum DeveloperFunctions {
    static let all: [TextFunction] = [
        prettyJSON,
        prettySortedJSON,
        htmlToPlainText,
        urlDecoded,
        urlEncoded,
        minifyJSON,
        sha256,
        sha384,
        sha512,
        md5,
        base64,
    ]

    static let prettyJSON = TextFunction(id: "co.ameba.Esse.OtherFunctions.prettyJSON", title: "Prettify JSON", description: "Returns nicely formatted JSON. Returns nothing if input text is not valid JSON", category: .Developer) { text -> String in
        guard let data = text.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonStr = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let out = String(data: jsonStr, encoding: .utf8)
        else { return "" }
        return out
    }

    static let prettySortedJSON = TextFunction(id: "co.ameba.Esse.OtherFunctions.prettySortedJSON", title: "Prettify and Sort JSON", description: "Returns nicely formatted and sorted JSON. Returns nothing if input text is not valid JSON", category: .Developer) { text -> String in
        guard let data = text.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonStr = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let out = String(data: jsonStr, encoding: .utf8)
        else { return "" }
        return out
    }

    static let minifyJSON = TextFunction(id: "co.ameba.Esse.OtherFunctions.minifyJSON", title: "Minify JSON", description: "Returns a minimized version of JSON, everething is in one string", category: .Developer) { text -> String in
        guard let data = text.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonStr = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
              let out = String(data: jsonStr, encoding: .utf8)?
              .replacingOccurrences(of: "\n", with: "")
              .replacingOccurrences(of: "\t", with: "")
              .replacingOccurrences(of: "\r", with: "")
        else { return "" }
        return out
    }

    static let htmlToPlainText = TextFunction(id: "co.ameba.Esse.ConvertFunctions.htmlToPlainText", title: "HTML to Plain Text", description: "Converts provided HTML code to plain text", category: .Developer) { text -> String in
        let data = Data(text.utf8)
        #if !os(macOS)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                return attributedString.string
            }
        #endif
        return "Something went wrong"
    }

    static let urlEncoded = TextFunction(id: "co.ameba.Esse.ConvertFunctions.urlEncoded", title: "URL Encoded", description: "", category: .Developer) { text -> String in
        text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    static let urlDecoded = TextFunction(id: "co.ameba.Esse.ConvertFunctions.urlDecoded", title: "URL Decoded", description: "", category: .Developer) { text -> String in
        text.removingPercentEncoding ?? ""
    }

    static let sha256 = TextFunction(id: "co.ameba.Esse.ConvertFunctions.sha256", title: "SHA-256", description: "", category: .Developer) { text -> String in
        SHA256.hash(data: Data(text.utf8)).description.components(separatedBy: " ")[2]
    }

    static let sha384 = TextFunction(id: "co.ameba.Esse.ConvertFunctions.sha384", title: "SHA-384", description: "", category: .Developer) { text -> String in
        SHA384.hash(data: Data(text.utf8)).description.components(separatedBy: " ")[2]
    }

    static let sha512 = TextFunction(id: "co.ameba.Esse.ConvertFunctions.sha512", title: "SHA-512", description: "", category: .Developer) { text -> String in
        SHA512.hash(data: Data(text.utf8)).description.components(separatedBy: " ")[2]
    }

    static let md5 = TextFunction(id: "co.ameba.Esse.ConvertFunctions.md5", title: "MD5", description: "", category: .Developer) { text -> String in
        Insecure.MD5.hash(data: Data(text.utf8)).description.components(separatedBy: " ")[2]
    }

    static let base64 = TextFunction(id: "co.ameba.Esse.ConvertFunctions.base64", title: "Base64", description: "", category: .Developer) { text -> String in
        Data(text.utf8).base64EncodedString()
    }
}

// MARK: Other

enum OtherFunctions {
    static let all: [TextFunction] = [
        hashTag,
        reversed,
        upsideDown,
        circleLetters,
        circleLettersFilled,
        squareLetters,
        rot13,
        uniqueWords,
        textStatistics,
        addLineNumbers,
        addLineNumbersDot,
        addLineNumbersParentheses,
        addLineBulletDash,
        addLineBulletStar,
    ]

    static let reversed = TextFunction(id: "co.ameba.Esse.OtherFunctions.reversed", title: "Reversed", description: "Returns input in reversed order.", category: .Other) { text -> String in
        String(text.reversed())
    }

    static let hashTag = TextFunction(id: "co.ameba.Esse.OtherFunctions.hashTag", title: "Hashtags", description: "Adds hash sign(#) to each word.", category: .Other) { text -> String in
        text.localizedLowercase.components(separatedBy: CharacterSet.whitespacesAndNewlines).map { "#\($0)" }.reduce("") { text, word -> String in
            "\(text) \(word)"
        }
    }

    private static let lowerUpsideDown: [Character: Character] = [
        "a": "ɐ", "b": "q", "c": "ɔ", "d": "p", "e": "ǝ", "f": "ɟ", "g": "ƃ", "h": "ɥ", "i": "ı", "j": "ɾ", "k": "ʞ", "l": "ן", "m": "ɯ", "n": "u",
        "o": "o", "p": "d", "q": "b", "r": "ɹ", "s": "s", "t": "ʇ", "u": "n", "v": "ʌ", "w": "ʍ", "x": "x", "y": "ʎ", "z": "z",
    ]

    private static let upperUpsideDown: [Character: Character] = [
        "A": "Ɐ", "B": "ᗺ", "C": "Ɔ", "D": "ᗡ", "E": "Ǝ", "F": "ᖵ", "G": "⅁", "H": "H", "I": "I", "J": "ᒋ", "K": "⋊", "L": "Ꞁ", "M": "W", "N": "N",
        "O": "O", "P": "Ԁ", "Q": "Ꝺ", "R": "ᴚ", "S": "S", "T": "⊥", "U": "∩", "V": "Ʌ", "W": "M", "X": "X", "Y": "⅄", "Z": "Z",
    ]

    private static let digitUpsideDown: [Character: Character] = [
        "0": "0", "1": "І", "2": "ᘔ", "3": "Ɛ", "4": "ᔭ", "5": "5", "6": "9", "7": "Ɫ", "8": "8", "9": "6",
    ]

    private static let symbolsUpsideDown: [Character: Character] = [
        "!": "¡",
        "\"": "„",
        "&": "⅋",
        "'": ",",
        ",": "'",
        "?": "¿",
    ]

    static let upsideDown = TextFunction(id: "co.ameba.Esse.OtherFunctions.upsideDown", title: "Upside Down", description: "Transform text to upside down -> ʇxǝʇ", category: .Other) { text -> String in
        String(text.reversed()
            .map { char in
                if let ch = lowerUpsideDown[char] {
                    return ch
                }
                if let ch = upperUpsideDown[char] {
                    return ch
                }
                if let ch = digitUpsideDown[char] {
                    return ch
                }
                if let ch = symbolsUpsideDown[char] {
                    return ch
                }
                return char
            })
    }

    private static let circleLetter: [Character: Character] = [
        "A": "Ⓐ", "B": "Ⓑ", "C": "Ⓒ", "D": "Ⓓ", "E": "Ⓔ", "F": "Ⓕ", "G": "Ⓖ", "H": "Ⓗ", "I": "Ⓘ", "J": "Ⓙ",
        "K": "Ⓚ", "L": "Ⓛ", "M": "Ⓜ", "N": "Ⓝ", "O": "Ⓞ", "P": "Ⓟ", "Q": "Ⓠ", "R": "Ⓡ", "S": "Ⓢ", "T": "Ⓣ",
        "U": "Ⓤ", "V": "Ⓥ", "W": "Ⓦ", "X": "Ⓧ", "Y": "Ⓨ", "Z": "Ⓩ",
        "a": "ⓐ", "b": "ⓑ", "c": "ⓒ", "d": "ⓓ", "e": "ⓔ", "f": "ⓕ", "g": "ⓖ", "h": "ⓗ", "i": "ⓘ", "j": "ⓙ",
        "k": "ⓚ", "l": "ⓛ", "m": "ⓜ", "n": "ⓝ", "o": "ⓞ", "p": "ⓟ", "q": "ⓠ", "r": "ⓡ", "s": "ⓢ", "t": "ⓣ",
        "u": "ⓤ", "v": "ⓥ", "w": "ⓦ", "x": "ⓧ", "y": "ⓨ", "z": "ⓩ",
        "0": "⓪", "1": "①", "2": "②", "3": "③", "4": "④", "5": "⑤", "6": "⑥", "7": "⑦", "8": "⑧", "9": "⑨",
    ]
    static let circleLetters = TextFunction(id: "co.ameba.Esse.OtherFunctions.circleLetters", title: "Circle Letters: Empty", description: "All letters are placed in ⓔⓜⓟⓣⓨ circles", category: .Other) { text -> String in
        String(spacedString(string: text).map { char in
            if let ch = circleLetter[char] {
                return ch
            }
            return char
        })
    }

    private static let circleLetterFilled: [Character: Character] = [
        "A": "🅐", "B": "🅑", "C": "🅒", "D": "🅓", "E": "🅔", "F": "🅕", "G": "🅖", "H": "🅗", "I": "🅘", "J": "🅙",
        "K": "🅚", "L": "🅛", "M": "🅜", "N": "🅝", "O": "🅞", "P": "🅟", "Q": "🅠", "R": "🅡", "S": "🅢", "T": "🅣",
        "U": "🅤", "V": "🅥", "W": "🅦", "X": "🅧", "Y": "🅨", "Z": "🅩",
        "0": "⓿", "1": "➊", "2": "➋", "3": "➌", "4": "➍", "5": "➎", "6": "➏", "7": "➐", "8": "➑", "9": "➒",
    ]

    static let circleLettersFilled = TextFunction(id: "co.ameba.Esse.OtherFunctions.circleLettersFilled", title: "Circle Letters: Filled", description: "All letters are placed in filled circles", category: .Other) { text -> String in
        String(spacedString(string: text).localizedUppercase
            .map { char in
                if let ch = circleLetterFilled[char] {
                    return ch
                }
                return char
            })
    }

    private static let squareLetter: [Character: Character] = [
        "A": "🄰", "B": "🄱", "C": "🄲", "D": "🄳", "E": "🄴", "F": "🄵", "G": "🄶", "H": "🄷", "I": "🄸", "J": "🄹",
        "K": "🄺", "L": "🄻", "M": "🄼", "N": "🄽", "O": "🄾", "P": "🄿", "Q": "🅀", "R": "🅁", "S": "🅂", "T": "🅃",
        "U": "🅄", "V": "🅅", "W": "🅆", "X": "🅇", "Y": "🅈", "Z": "🅉",
        "0": "0︎⃣", "1": "1︎⃣", "2": "2︎⃣", "3": "3︎⃣", "4": "4︎⃣", "5": "5︎⃣", "6": "6︎⃣", "7": "7︎⃣", "8": "8︎⃣", "9": "9︎⃣",
    ]

    static let squareLetters = TextFunction(id: "co.ameba.Esse.OtherFunctions.squareLetters", title: "Square Letters", description: "All letters are placed in squares", category: .Other) { text -> String in
        String(spacedString(string: text).localizedUppercase
            .map { char in
                if let ch = squareLetter[char] {
                    return ch
                }
                return char
            })
    }

    private static let rot13Lookup: [Character: Character] = [
        "A": "N", "B": "O", "C": "P", "D": "Q", "E": "R", "F": "S", "G": "T", "H": "U", "I": "V", "J": "W", "K": "X", "L": "Y",
        "M": "Z", "N": "A", "O": "B", "P": "C", "Q": "D", "R": "E", "S": "F", "T": "G", "U": "H", "V": "I", "W": "J", "X": "K",
        "Y": "L", "Z": "M", "a": "n", "b": "o", "c": "p", "d": "q", "e": "r", "f": "s", "g": "t", "h": "u", "i": "v", "j": "w",
        "k": "x", "l": "y", "m": "z", "n": "a", "o": "b", "p": "c", "q": "d", "r": "e", "s": "f", "t": "g", "u": "h", "v": "i",
        "w": "j", "x": "k", "y": "l", "z": "m",
    ]

    static let rot13 = TextFunction(id: "co.ameba.Esse.OtherFunctions.rot13", title: "ROT13", description: "ROT13 is a simple letter substitution cipher that replaces a letter with the 13th letter after it, in the alphabet", category: .Other) { text -> String in
        String(text
            .map { char in
                if let ch = rot13Lookup[char] {
                    return ch
                }
                return char
            })
    }

    static func spacedString(string: String) -> String {
        var out = ""
        for char in string.localizedUppercase {
            out.append(char)
            if char == Character("\t") || char == Character("\n") {
                continue
            }
            out.append(" ")
        }
        return out
    }

    static let emojify = TextFunction(id: "co.ameba.Esse.OtherFunctions.emojify", title: "Emojify", description: "Translates text to Emoji: 'Chickens and cows live on a farm.' -> '🐔 and 🐮 live on a farm.'", category: .Other) { text -> String in
        var result = ""
        let lemmas = text.lemmas()
        text.enumerateSubstrings(in: text.startIndex ..< text.endIndex, options: .byWords) { word, substringRange, enclosingEndingRange, _ in
            guard let word else { return }

            var lemmaEmojii: String?
            if let lemma = lemmas[word] {
                lemmaEmojii = Emojii.mapping[lemma]?.first
            }
            let wordEmojii = Emojii.mapping[word.lowercased()]?.first
            if lemmaEmojii != nil || wordEmojii != nil {
                let resultEmojii = wordEmojii ?? (lemmaEmojii ?? "")
                result += resultEmojii
                if substringRange.upperBound != enclosingEndingRange.upperBound {
                    result += String(text[substringRange.upperBound ..< enclosingEndingRange.upperBound])
                }
            } else {
                result += String(text[enclosingEndingRange]) // substringRange.lowerBound...enclosingEndingRange.upperBound])
            }
        }
        return result // "Implement me!"
    }

    static let uniqueWords = TextFunction(id: "co.ameba.Esse.OtherFunctions.uniqueWords", title: "Count Unique Words", description: "Counts unique words", category: .Other) { text -> String in
        guard text.count > 0 else { return "" }

        var words = text.words()
        guard words.count > 0 else { return "" }

        var counts: [String: Int] = [:]
        words.forEach { word in
            counts[word] = (counts[word] ?? 0) + 1
        }
        var output: [String] = counts.sorted { $0.value > $1.value }.map { "\($0.key):\($0.value)" }
        output.insert("Total Unique Words:\(counts.count)", at: 0)
        output.insert("Total Words:\(counts.values.reduce(0, +))", at: 0)
        return output.joined(separator: "\n")
    }

    static let textStatistics = TextFunction(id: "co.ameba.Esse.OtherFunctions.textStatistics", title: "Text Stats", description: "Returns basic statistics for provided text", category: .Other) { text -> String in
        guard text.count > 0 else { return "" }
        var out = ""
        out = "Characters count: \(text.count)"
        out += "\nParagraphs: \(text.getUnits(of: .paragraph).count)"
        out += "\tSentences: \(text.getUnits(of: .sentence).count)"
        out += "\nWords: \(text.getUnits(of: .word).count)"
        out += "\t\tUnique words: \(Set(text.getUnits(of: .word)).count)"
        out += "\nLetters: \(text.filter(\.isLetter).count)"
        out += "\t\tDigits: \(text.filter(\.isNumber).count)"
        out += "\nSpaces: \(text.filter(\.isWhitespace).count)"
        out += "\t\tPunctuation: \(text.filter(\.isPunctuation).count)"

        return out
    }

    static func addLineBullets(text: String, numbers: Bool = true, char: String = "") -> String {
        guard text.count > 0 else { return "" }
        var out = ""
        for (i, text) in text.components(separatedBy: .newlines).enumerated() {
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                out += "\(text) \n"
                continue
            }
            if numbers {
                out += "\(i + 1)\(char) \(text) \n"
            } else {
                out += "\(char) \(text) \n"
            }
        }

        return out
    }

    static let addLineNumbers = TextFunction(id: "co.ameba.Esse.OtherFunctions.addLineNumbers", title: "List: Add Line Numbers (1 2 3)", description: "Numbers each line", category: .Other) { text -> String in
        addLineBullets(text: text, numbers: true, char: "")
    }

    static let addLineNumbersDot = TextFunction(id: "co.ameba.Esse.OtherFunctions.addLineNumbersDot", title: "List: Add Line Numbers (1. 2. 3.)", description: "Numbers each line, numbers followed by dot", category: .Other) { text -> String in
        addLineBullets(text: text, numbers: true, char: ".")
    }

    static let addLineNumbersParentheses = TextFunction(id: "co.ameba.Esse.OtherFunctions.addLineNumbersParentheses", title: "List: Add Line Numbers (1) 2) 3))", description: "Numbers each line, numbers followed by parentheses", category: .Other) { text -> String in
        addLineBullets(text: text, numbers: true, char: ")")
    }

    static let addLineBulletDash = TextFunction(id: "co.ameba.Esse.OtherFunctions.addLineBulletDash", title: "List: Add Line Bullet (-)", description: "Adds dash(-) to each line", category: .Other) { text -> String in
        addLineBullets(text: text, numbers: false, char: "-")
    }

    static let addLineBulletStar = TextFunction(id: "co.ameba.Esse.OtherFunctions.addLineBulletStar", title: "List: Add Line Bullet (*)", description: "Adds star(*) to each line", category: .Other) { text -> String in
        addLineBullets(text: text, numbers: false, char: "*")
    }
}

// f characters: spaces, letters, numeric, alphanumeric/punctuation, words, sentences, lines, paragraphs.

public let AllFunctions = (
    CaseFunctions.all
        + QuotationMarksFunctions.all
        + CleaningFunctions.all
        + ConvertFunctions.all
        + ExtractFunctions.all
        + ASCIIFunctions.all
        + OtherFunctions.all
        + DeveloperFunctions.all).sorted(by: { $0.title < $1.title })

extension String {
    func replaceAllDoubleQuotes(with quoteType: QuotationMarksFunctions.QuotesTypes) -> String {
        QuotationMarksFunctions.replaceAllDoubleQuotes(with: quoteType, input: self)
    }

    func replaceAllSingleQuotes(with quoteType: QuotationMarksFunctions.QuotesTypes) -> String {
        QuotationMarksFunctions.replaceAllSingleQuotes(with: quoteType, input: self)
    }

    func replaceAllQuotes(with quoteType: QuotationMarksFunctions.QuotesTypes) -> String {
        QuotationMarksFunctions.replaceAllDoubleQuotes(with: quoteType, input: self).replaceAllSingleQuotes(with: quoteType)
    }
}

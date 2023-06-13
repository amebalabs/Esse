import Foundation

typealias TextToEmojiMapping = [String: [String]]

enum Emojii {
    static let mapping: TextToEmojiMapping = parseEmojiiFile()

    private static func parseEmojiiFile() -> TextToEmojiMapping {
        guard let path = Bundle(for: Storage.self).path(forResource: "emojis", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDictionary = json as? NSDictionary
        else {
            return [:]
        }
        var result: TextToEmojiMapping = [:]
        for (key, value) in jsonDictionary {
            if let key = key as? String,
               let dictionary = value as? [String: AnyObject],
               let emojiCharacter = dictionary["char"] as? String
            {
                // Dictionary keys from emojis.json have higher priority then keywords.
                // That's why they're added at the beginning of the array.
                addKey(key, value: emojiCharacter, atBeginning: true, to: &result)

                if let keywords = dictionary["keywords"] as? [String] {
                    for keyword in keywords {
                        addKey(keyword, value: emojiCharacter, atBeginning: false, to: &result)
                    }
                }
            }
        }
        return result
    }

    private static func addKey(_ key: String, value: String, atBeginning: Bool, to dict: inout TextToEmojiMapping) {
        // ignore short words because they're non-essential
        guard key.lengthOfBytes(using: String.Encoding.utf8) > 2 else {
            return
        }

        if dict[key] == nil {
            dict[key] = []
        }

        if atBeginning {
            dict[key]?.insert(value, at: 0)
        } else {
            dict[key]?.append(value)
        }
    }
}

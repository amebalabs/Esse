//
//  Based on string_score 0.1.21 by Joshaven Potter.
//  https://github.com/joshaven/string_score/
//
//  Copyright (c) 2016-present YICHI ZHANG
//  https://github.com/yichizhang
//  zhang-yi-chi@hotmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

private extension String {
    func charAt(_ i: Int) -> Character {
        let index = index(startIndex, offsetBy: i)
        return self[index]
    }

    func charStrAt(_ i: Int) -> String {
        String(charAt(i))
    }
}

public extension String {
    func score(word: String, fuzziness: Double? = nil) -> Double {
        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }

        // if it's not a perfect match and is empty return 0
        if word.isEmpty || isEmpty {
            return 0
        }

        var runningScore = 0.0
        var charScore = 0.0
        var finalScore = 0.0

        let string = self
        let lString = string.lowercased()
        let strLength = string.count
        let lWord = word.lowercased()
        let wordLength = word.count

        var idxOf: String.Index!
        var startAt = lString.startIndex
        var fuzzies = 1.0
        var fuzzyFactor = 0.0
        var fuzzinessIsNil = true

        // Cache fuzzyFactor for speed increase
        if let fuzziness {
            fuzzyFactor = 1 - fuzziness
            fuzzinessIsNil = false
        }

        for i in 0 ..< wordLength {
            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".

            if let range = lString.range(
                of: lWord.charStrAt(i),
                options: [.caseInsensitive, .diacriticInsensitive],
                range: startAt ..< lString.endIndex,
                locale: nil
            ) {
                // start index of word's i-th character in string.
                idxOf = range.lowerBound

                if startAt == idxOf {
                    // Consecutive letter & start-of-string Bonus
                    charScore = 0.7
                } else {
                    charScore = 0.1

                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if string[string.index(before: idxOf)] == " " {
                        charScore += 0.8
                    }
                }
            } else {
                // Character not found.
                if fuzzinessIsNil {
                    // Fuzziness is nil. Return 0.
                    return 0
                } else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }

            // Same case bonus.
            if string[idxOf] == word[word.index(word.startIndex, offsetBy: i)] {
                charScore += 0.1
            }

            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = string.index(idxOf, offsetBy: 1)
        }

        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(strLength) + runningScore / Double(wordLength)) / fuzzies

        if finalScore < 0.85,
           lWord.charStrAt(0).compare(lString.charStrAt(0), options: .diacriticInsensitive) == .orderedSame
        {
            finalScore += 0.15
        }

        return finalScore
    }
}

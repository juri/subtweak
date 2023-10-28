import Foundation
import Parsing

/*
 1
 00:05:00,400 --> 00:05:15,300
 This is an example of
 a subtitle.

 2
 00:05:16,400 --> 00:05:25,300
 This is an example of
 a subtitle - 2nd subtitle.

 */

struct Timestamp: Equatable {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var fraction: Int
    var fractionDigitCount: Int
}

struct Subtitle: Equatable {
    var number: Int
    var start: Timestamp
    var end: Timestamp
    var text: String
}

let timestamp = ParsePrint(input: Substring.self) {
    Digits(2)
    ":"
    Digits(2)
    ":"
    Digits(2)
    ","
    Prefix(while: { $0.isASCII && $0.isNumber })
}.map(
    AnyConversion(
        apply: { (h: Int, m: Int, s: Int, fd: Substring) in
            let fraction = Int(String(fd))!
            let fractionDigitCount = fd.count
            return Timestamp(
                hours: h,
                minutes: m,
                seconds: s,
                fraction: fraction,
                fractionDigitCount: fractionDigitCount
            )
        },
        unapply: { timeStamp in
            let fractionLength = magnitude(timeStamp.fraction)
            let zeroes = String(repeating: "0", count: timeStamp.fractionDigitCount - fractionLength)
            let fds = String(timeStamp.fraction) + zeroes
            return (timeStamp.hours, timeStamp.minutes, timeStamp.seconds, fds[...])
        }
    )
)

private func magnitude(_ i: Int) -> Int {
    var i = i
    var m = 1
    i /= 10

    while i > 0 {
        m += 1
        i /= 10
    }
    return m
}

let subtitle = ParsePrint(input: Substring.self) {
    Int.parser()
    Whitespace(1, .vertical)
    timestamp
    " --> "
    timestamp
    Whitespace(1, .vertical)
    PrefixUpTo("\n\n")
    "\n\n"
}.map(
    AnyConversion(
        apply: { n, s, e, t in
            Subtitle(number: n, start: s, end: e, text: String(t))
        },
        unapply: { subtitle in
            (subtitle.number, subtitle.start, subtitle.end, subtitle.text[...])
        }
    )
)

struct Subtext<Input: Collection>: Parser where Input.SubSequence == Input, Input.Element == Character {
    func parse(_ input: inout Input) throws -> Input {
        let doubleNewlineIndex = input.firstSubsequenceIndex(where: { subs in
            guard let first = subs.first, let second = subs.dropFirst().first else {
                return false
            }
            let match = (first == "\n" && second == "\n") || (first == "\r\n" && second == "\r\n")
            return match
        })
        guard let doubleNewlineIndex else {
            let output = input
            input.removeFirst(output.count)
            return output
        }

        let prefix = input[input.startIndex ..< doubleNewlineIndex]
        input.removeFirst(prefix.count)
        return prefix
    }
}

extension Subtext: ParserPrinter where Input: PrependableCollection {
    func print(_ output: Input, into input: inout Input) throws {
        input.prepend(contentsOf: "\n\n")
        input.prepend(contentsOf: output)
    }
}

extension Collection {
    func firstSubsequenceIndex(where test: (SubSequence) -> Bool) -> Self.Index? {
        for index in self.indices {
            if test(self[index...]) {
                return index
            }
        }
        return nil
    }
}

let srtNewline = OneOf {
    "\r\n"
    "\n"
}

let subtitle_ = ParsePrint(input: Substring.self) {
    Int.parser()
    srtNewline
    timestamp
    " --> "
    timestamp
    srtNewline
    Subtext()
    srtNewline
    srtNewline
}.map(
    AnyConversion(
        apply: { n, s, e, t in
            Subtitle(number: n, start: s, end: e, text: String(t))
        },
        unapply: { subtitle in
            (subtitle.number, subtitle.start, subtitle.end, subtitle.text[...])
        }
    )
)

let subtitles = Many {
    subtitle_
}

let subtitlesDocument = ParsePrint {
    subtitles
    Whitespace()
}

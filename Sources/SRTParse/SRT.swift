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

public struct Timestamp: Equatable {
    public var hours: Int
    public var minutes: Int
    public var seconds: Int
    public var fraction: Int
    public var fractionDigitCount: Int
}

struct Subtitle: Equatable {
    var number: Int
    var start: Timestamp
    var end: Timestamp
    var text: String
}

public let timestamp = ParsePrint(input: Substring.self) {
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
            let fds = zeroes + String(timeStamp.fraction)
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
    "\n"
    timestamp
    " --> "
    timestamp
    "\n"
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

let subtitles = Many {
    subtitle
}

let subtitlesDocument = ParsePrint {
    subtitles
    Whitespace()
}

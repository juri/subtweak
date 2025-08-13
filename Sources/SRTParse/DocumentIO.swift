import Foundation
import Subtitles

/// Parse a SRT document.
public func parseSRT(string: String, encoding: String.Encoding) throws -> SRTSubs {
    let newlineMode = detectNewlineMode(string)
    var string = string
    string = string.replacingOccurrences(of: "\r\n", with: "\n")
    let subtitles = try subtitlesDocument.parse(string)
    return SRTSubs(
        subs: subtitles.map(Subtitles.Sub.init(_:)),
        newlineMode: newlineMode,
        encoding: encoding
    )
}

/// Print a SRT document.
public func printSRT(srtSubs: SRTSubs) throws -> String {
    let subtitles = Subtitle.subtitles(from: srtSubs.subs)
    var str = String(try subtitlesDocument.print(subtitles))
    while !str.hasSuffix("\n\n") {
        str.append("\n")
    }

    guard srtSubs.newlineMode != .lf else {
        return str
    }
    return str.replacingOccurrences(of: "\n", with: "\r\n")
}

/// A parsed SRT document.
public struct SRTSubs {
    /// The subtitles contained in the SRT document.
    public var subs: [Sub]
    /// The newline format used in the SRT document.
    public var newlineMode: NewlineMode
    /// The encoding used in the SRT document.
    public var encoding: String.Encoding

    public init(
        subs: [Sub],
        newlineMode: NewlineMode,
        encoding: String.Encoding = .utf8
    ) {
        self.subs = subs
        self.newlineMode = newlineMode
        self.encoding = encoding
    }
}

/// The newline format used in a SRT document.
public enum NewlineMode {
    /// CR LF newlines.
    case crLF

    /// LF newlines.
    case lf
}

func detectNewlineMode(_ string: String) -> NewlineMode {
    let utf8 = string.utf8
    guard let firstLFIndex = utf8.firstIndex(of: lineFeed) else { return .lf }
    guard firstLFIndex > utf8.startIndex else { return .lf }
    let previousIndex = utf8.index(before: firstLFIndex)
    return utf8[previousIndex] == carriageReturn ? .crLF : .lf
}

private let lineFeed: UInt8 = 10
private let carriageReturn: UInt8 = 13

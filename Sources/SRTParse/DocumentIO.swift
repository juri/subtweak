import Foundation
import Subtitles

/// Parse a SRT document.
public func parseSRT(string: String) throws -> SRTSubs {
    let newlineMode = detectNewlineMode(string)
    var string = string
    string = string.replacingOccurrences(of: "\r\n", with: "\n")
    let subtitles = try subtitlesDocument.parse(string)
    return SRTSubs(
        subs: Subs(entries: subtitles.map(Subtitles.Sub.init(_:))),
        newlineMode: newlineMode
    )
}

/// Print a SRT document.
public func printSRT(srtSubs: SRTSubs) throws -> String {
    let subtitles = Subtitle.subtitles(from: srtSubs.subs)
    let str = String(try subtitlesDocument.print(subtitles))
    guard srtSubs.newlineMode != .lf else {
        return str
    }
    return str.replacingOccurrences(of: "\n", with: "\r\n")
}

/// A parsed SRT document.
public struct SRTSubs {
    /// The subtitles contained in the SRT document.
    public var subs: Subs
    /// The newline format used in the SRT document.
    public var newlineMode: NewlineMode

    public init(subs: Subs, newlineMode: NewlineMode) {
        self.subs = subs
        self.newlineMode = newlineMode
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

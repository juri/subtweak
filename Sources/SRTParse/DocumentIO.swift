import Foundation
import Subtitles

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

public func printSRT(srtSubs: SRTSubs) throws -> String {
    let subtitles = Subtitle.subtitles(from: srtSubs.subs)
    let str = String(try subtitlesDocument.print(subtitles))
    guard srtSubs.newlineMode != .lf else {
        return str
    }
    return str.replacingOccurrences(of: "\n", with: "\r\n")
}

public struct SRTSubs {
    public var subs: Subs
    public var newlineMode: NewlineMode
}

public struct InputSRTFormat: Equatable {
    public var newlineMode: NewlineMode
}

public enum NewlineMode {
    case crLF
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

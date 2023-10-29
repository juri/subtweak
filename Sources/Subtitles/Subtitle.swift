import Foundation

/// A subtitle.
///
/// One subtitle from a subtitle document, with the associated timing information.
public struct Sub: Equatable {
    public var start: Duration
    public var duration: Duration
    public var text: String

    public init(
        start: Duration,
        duration: Duration,
        text: String
    ) {
        self.duration = duration
        self.start = start
        self.text = text
    }

    public var end: Duration {
        self.start + self.duration
    }
}

/// A list of subtitles.
public struct Subs: Equatable {
    public var entries: [Sub]

    public init(entries: [Sub]) {
        self.entries = entries
    }
}

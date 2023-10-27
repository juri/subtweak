import Foundation

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
}

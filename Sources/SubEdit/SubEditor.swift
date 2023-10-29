import Foundation
import SRTParse
@_exported import Subtitles

public struct SubEditor {
    public private(set) var srtSubs: SRTSubs

    public init(srtSubs: SRTSubs) {
        self.srtSubs = srtSubs
    }

    public func write(target: Output) throws {
        let str = try printSRT(srtSubs: self.srtSubs)
        try target.write(data: Data(str.utf8))
    }
}

public extension SubEditor {
    init(source: Input) throws {
        let data = try source.read()
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncodingError()
        }

        let subs = try parseSRT(string: string)
        self.init(srtSubs: subs)
    }
}

public extension SubEditor {
    mutating func remove(number: Int) throws {
        let index = number - 1
        guard index < self.srtSubs.subs.entries.endIndex else {
            throw SubtitleNumberError(numberOfEntries: self.srtSubs.subs.entries.count)
        }
        self.srtSubs.subs.entries.remove(at: index)
    }

    mutating func setStart(number: Int, at newStart: Duration, shouldAdjustRest: Bool) throws {
        guard newStart.components.seconds >= 0 && newStart.components.attoseconds >= 0 else {
            throw InvalidDurationError(duration: newStart)
        }
        let index = number - 1
        guard index < self.srtSubs.subs.entries.endIndex else {
            throw SubtitleNumberError(numberOfEntries: self.srtSubs.subs.entries.count)
        }
        var entries = self.srtSubs.subs.entries
        if newStart < entries[index].start && index > 0 && entries[index - 1].end > newStart {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedStart: newStart,
                overlappingNumber: number - 1,
                overlappingSub: entries[index - 1]
            )
        }
        if newStart > entries[index].start &&
            index < entries.index(before: entries.endIndex) &&
            !shouldAdjustRest &&
            newStart > entries[index + 1].start
        {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedStart: newStart,
                overlappingNumber: number + 1,
                overlappingSub: entries[index + 1]
            )
        }
        let difference = newStart - entries[index].start
        entries[index].start = newStart
        if shouldAdjustRest {
            for index in entries.indices.dropFirst(index + 1) {
                entries[index].start += difference
            }
        }
        self.srtSubs.subs.entries = entries
    }
}

public struct EncodingError: Error {}

public struct SubtitleNumberError: Error {
    var numberOfEntries: Int
}

public struct TimeOverlapError: Error, Equatable {
    public var targetNumber: Int
    public var targetSub: Sub
    public var requestedStart: Duration
    public var overlappingNumber: Int
    public var overlappingSub: Sub

    public init(
        targetNumber: Int,
        targetSub: Sub,
        requestedStart: Duration,
        overlappingNumber: Int,
        overlappingSub: Sub
    ) {
        self.targetNumber = targetNumber
        self.targetSub = targetSub
        self.requestedStart = requestedStart
        self.overlappingNumber = overlappingNumber
        self.overlappingSub = overlappingSub
    }
}

public struct InvalidDurationError: Error, Equatable {
    public var duration: Duration

    public init(duration: Duration) {
        self.duration = duration
    }
}

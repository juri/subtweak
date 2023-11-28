import Foundation
import SRTParse
@_exported import Subtitles

/// `SubEditor` reads, edits and writes subtitles.
public struct SubEditor {
    public private(set) var srtSubs: SRTSubs

    /// Initializes `SubEditor` with subtitles read from a SRT file.
    public init(srtSubs: SRTSubs) {
        self.srtSubs = srtSubs
    }

    /// Write `SubEditor`'s subtitles to an ``Output`` target.
    public func write(target: Output) throws {
        let str = try printSRT(srtSubs: self.srtSubs)
        guard let data = str.data(using: self.srtSubs.encoding) else {
            throw OutputEncodingError(encoding: self.srtSubs.encoding)
        }
        try target.write(data: data)
    }
}

public extension SubEditor {
    /// Initialize `SubEditor` with SRT data from an ``Input``.
    init(source: Input) throws {
        let data = try source.read()
        let decoded = try decode(source: source, data: data)
        let subs = try parseSRT(string: decoded.string, encoding: decoded.encoding)
        self.init(srtSubs: subs)
    }
}

public extension SubEditor {
    /// Remove a subtitle.
    ///
    /// - Parameter number: Subtitle number. The numbering starts at 1.
    mutating func remove(number: Int) throws {
        try self.checkNumber(number)
        let index = number - 1
        self.srtSubs.subs.remove(at: index)
    }

    /// Set the start time of a subtitle.
    ///
    /// The start time is sanity checked so that it does not overlap the end time of the preceding subtitle and the new end
    /// time does not overlap the start time of the next subtitle.
    ///
    /// - Parameters:
    ///     - number: Subtitle number. The numbering starts at 1.
    ///     - newStart: New start time.
    ///     - shouldAdjustRest: Flag that tells if the start times of the subtitles following this one
    ///            should be adjusted with the difference between the old and new start times.
    mutating func setStart(number: Int, at newStart: Duration, shouldAdjustRest: Bool) throws {
        try self.checkNumber(number)
        try checkDuration(newStart)
        let index = number - 1
        var entries = self.srtSubs.subs
        if newStart < entries[index].start && index > 0 && entries[index - 1].end >= newStart {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedTime: .start(newStart),
                overlappingNumber: number - 1,
                overlappingSub: entries[index - 1]
            )
        }
        if newStart > entries[index].start &&
            index < entries.index(before: entries.endIndex) &&
            !shouldAdjustRest &&
            newStart + entries[index].duration >= entries[index + 1].start
        {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedTime: .start(newStart),
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
        self.srtSubs.subs = entries
    }

    /// Set the duration of a subtitle.
    ///
    /// The duration is sanity checked so that it does not cause the subtitle to overlap the next subtitle.
    ///
    /// - Parameters:
    ///     - number: Subtitle number. The numbering starts at 1.
    ///     - duration: New duration.
    ///     - shouldAdjustRest: Flag that tells if the start times of the subtitles following this one
    ///            should be adjusted with the difference between the old and new durations.
    mutating func setDuration(number: Int, duration: Duration, shouldAdjustRest: Bool) throws {
        try self.checkNumber(number)
        try checkDuration(duration)

        let index = number - 1
        var entries = self.srtSubs.subs
        if duration > entries[index].duration &&
            index < entries.index(before: entries.endIndex) &&
            !shouldAdjustRest &&
            entries[index].start + duration >= entries[index + 1].start
        {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedTime: .duration(duration),
                overlappingNumber: number + 1,
                overlappingSub: entries[index + 1]
            )
        }

        let difference = duration - entries[index].duration
        entries[index].duration = duration
        if shouldAdjustRest {
            for index in entries.indices.dropFirst(index + 1) {
                entries[index].start += difference
            }
        }
        self.srtSubs.subs = entries
    }

    /// Set the end time of a subtitle.
    ///
    /// - Parameters:
    ///     - number: Subtitle number. The numbering starts at 1.
    ///     - newEnd: New end time.
    ///     - shouldAdjustRest: Flag that tells if the start times of the subtitles following this one
    ///            should be adjusted with the difference between the old and new durations.
    mutating func setEnd(number: Int, at newEnd: Duration, shouldAdjustRest: Bool) throws {
        try self.checkNumber(number)
        try checkDuration(newEnd)

        let index = number - 1
        var entries = self.srtSubs.subs
        if newEnd < entries[index].start {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedTime: .end(newEnd),
                overlappingNumber: number,
                overlappingSub: entries[index]
            )
        }

        if newEnd > entries[index].end &&
            index < entries.index(before: entries.endIndex) &&
            !shouldAdjustRest &&
            newEnd >= entries[index + 1].start
        {
            throw TimeOverlapError(
                targetNumber: number,
                targetSub: entries[index],
                requestedTime: .end(newEnd),
                overlappingNumber: number + 1,
                overlappingSub: entries[index + 1]
            )
        }

        let difference = newEnd - entries[index].end
        entries[index].duration += difference
        if shouldAdjustRest {
            for index in entries.indices.dropFirst(index + 1) {
                entries[index].start += difference
            }
        }
        self.srtSubs.subs = entries
    }

    mutating func setText(number: Int, text: String) throws {
        try self.checkNumber(number)
        let index = number - 1
        self.srtSubs.subs[index].text = text
    }

    /// List the current subtitles.
    var subs: [Sub] {
        self.srtSubs.subs
    }

    /// List gaps between subtitles in the specified range.
    func listGaps(numberRange: ClosedRange<Int>) throws -> [GapListEntry] {
        try self.checkNumber(numberRange.lowerBound)
        try self.checkNumber(numberRange.upperBound)
        guard numberRange.lowerBound < numberRange.upperBound else { return [] }

        let entries = self.srtSubs.subs
        var gapList = [GapListEntry]()
        for number in numberRange.lowerBound ..< numberRange.upperBound {
            let index = number - 1
            let entry = entries[index]
            let nextEntry = entries[index + 1]
            let gapListEntry = GapListEntry(
                number: number,
                sub: entry,
                gap: nextEntry.start - entry.end
            )
            gapList.append(gapListEntry)
        }

        let lastNumber = numberRange.upperBound
        let lastIndex = lastNumber - 1
        let gap = if lastIndex < entries.index(before: entries.endIndex) {
            entries[lastIndex + 1].start - entries[lastIndex].end
        } else {
            Duration.zero
        }
        gapList.append(GapListEntry(number: lastNumber, sub: entries[lastIndex], gap: gap))
        return gapList
    }
}

private extension SubEditor {
    private func checkNumber(_ number: Int) throws {
        guard number > 0 && number <= self.srtSubs.subs.endIndex else {
            throw SubtitleNumberError(
                number: number,
                numberOfEntries: self.srtSubs.subs.count
            )
        }
    }
}

private func checkDuration(_ duration: Duration) throws {
    guard duration.components.seconds >= 0 && duration.components.attoseconds >= 0 else {
        throw InvalidDurationError(duration: duration)
    }
}

/// Represents a subtitle with information about its position in the
/// list and the empty duration that comes after it.
public struct GapListEntry: Equatable {
    /// The number of the subtitle in the subtitle document.
    public var number: Int
    /// The subtitle.
    public var sub: Sub
    /// The duration between this subtitle and the next one.
    public var gap: Duration

    public init(number: Int, sub: Sub, gap: Duration) {
        self.number = number
        self.sub = sub
        self.gap = gap
    }
}

/// Error thrown when decoding of the input fails.
public struct InputDecodingError: Error, Equatable {
    public var input: Input

    public init(input: Input) {
        self.input = input
    }
}

/// Error throws when encoding of the document fails.
public struct OutputEncodingError: Error, Equatable {
    public var encoding: String.Encoding

    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }
}

/// Error thrown when an invalid subtitle number is specified.
public struct SubtitleNumberError: Error, Equatable {
    public var number: Int
    public var numberOfEntries: Int

    public init(number: Int, numberOfEntries: Int) {
        self.number = number
        self.numberOfEntries = numberOfEntries
    }
}

/// Error thrown when editor operation would result in overlapping subtitle times.
public struct TimeOverlapError: Error, Equatable {
    public enum TimeField: Equatable {
        case start(Duration)
        case duration(Duration)
        case end(Duration)
    }

    public var targetNumber: Int
    public var targetSub: Sub
    public var requestedTime: TimeField
    public var overlappingNumber: Int
    public var overlappingSub: Sub

    public init(
        targetNumber: Int,
        targetSub: Sub,
        requestedTime: TimeField,
        overlappingNumber: Int,
        overlappingSub: Sub
    ) {
        self.targetNumber = targetNumber
        self.targetSub = targetSub
        self.requestedTime = requestedTime
        self.overlappingNumber = overlappingNumber
        self.overlappingSub = overlappingSub
    }
}

/// Error thrown when an invalid duration is specified.
///
/// In practice this means the duration had negative values.
public struct InvalidDurationError: Error, Equatable {
    public var duration: Duration

    public init(duration: Duration) {
        self.duration = duration
    }
}

import CustomDump
@testable import SRTParse
import Subtitles
import XCTest

final class ConversionTests: XCTestCase {
    func testTimestampFromDuration() throws {
        // 9296 seconds = 2:34:56
        let duration = Duration(secondsComponent: 9296, attosecondsComponent: 123_600_000_000_000_000)
        let ts = Timestamp(duration)
        expectNoDifference(ts, Timestamp(hours: 2, minutes: 34, seconds: 56, fraction: 124, fractionDigitCount: 3))
    }

    func testTimestampToDuration() throws {
        // 9296 seconds = 2:34:56
        let ts = Timestamp(hours: 2, minutes: 34, seconds: 56, fraction: 124, fractionDigitCount: 3)
        let duration = ts.duration
        expectNoDifference(duration, Duration(secondsComponent: 9296, attosecondsComponent: 124_000_000_000_000_000))
    }

    func testSubtitleToSub() throws {
        let subtitle = Subtitle(
            number: 2,
            start: Timestamp(hours: 1, minutes: 1, seconds: 1, fraction: 23, fractionDigitCount: 3),
            end: Timestamp(hours: 1, minutes: 1, seconds: 3, fraction: 24, fractionDigitCount: 3),
            text: "Hello!"
        )
        let sub = Sub(subtitle)
        expectNoDifference(
            sub,
            Sub(
                start: Duration(secondsComponent: 3661, attosecondsComponent: 23_000_000_000_000_000),
                duration: Duration(secondsComponent: 2, attosecondsComponent: 1_000_000_000_000_000),
                text: "Hello!"
            )
        )
    }

    func testSubToSubtitle() throws {
        let sub = Sub(
            start: Duration(secondsComponent: 3661, attosecondsComponent: 23_000_000_000_000_000),
            duration: Duration(secondsComponent: 2, attosecondsComponent: 1_000_000_000_000_000),
            text: "Hello!"
        )
        let subtitle = Subtitle(number: 3, sub: sub)
        expectNoDifference(
            subtitle,
            Subtitle(
                number: 3,
                start: Timestamp(hours: 1, minutes: 1, seconds: 1, fraction: 23, fractionDigitCount: 3),
                end: Timestamp(hours: 1, minutes: 1, seconds: 3, fraction: 24, fractionDigitCount: 3),
                text: "Hello!"
            )
        )
    }

    func testSubsToSubtitles() throws {
        let subs = [
            Sub(
                start: Duration(secondsComponent: 3661, attosecondsComponent: 23_000_000_000_000_000),
                duration: Duration(secondsComponent: 2, attosecondsComponent: 1_000_000_000_000_000),
                text: "Hello 1"
            ),
            Sub(
                start: Duration(secondsComponent: 3663, attosecondsComponent: 451_000_000_000_000_000),
                duration: Duration(secondsComponent: 1, attosecondsComponent: 18_000_000_000_000_000),
                text: "Hello 2"
            ),
        ]
        let subtitles = Subtitle.subtitles(from: subs)
        expectNoDifference(
            subtitles,
            [
                Subtitle(
                    number: 1,
                    start: Timestamp(hours: 1, minutes: 1, seconds: 1, fraction: 23, fractionDigitCount: 3),
                    end: Timestamp(hours: 1, minutes: 1, seconds: 3, fraction: 24, fractionDigitCount: 3),
                    text: "Hello 1"
                ),
                Subtitle(
                    number: 2,
                    start: Timestamp(hours: 1, minutes: 1, seconds: 3, fraction: 451, fractionDigitCount: 3),
                    end: Timestamp(hours: 1, minutes: 1, seconds: 4, fraction: 469, fractionDigitCount: 3),
                    text: "Hello 2"
                ),
            ]
        )
    }
}

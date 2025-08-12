import CustomDump
@testable import SRTParse
import XCTest

final class SRTTests: XCTestCase {
    func testParseDocument() throws {
        let srt = """
        1
        00:05:00,040 --> 00:05:15,300
        This is an example of
        a subtitle.

        2
        00:05:16,400 --> 00:05:25,300
        This is an example of
        a subtitle - 2nd subtitle.


        """

        let subs = try subtitlesDocument.parse(srt)
        expectNoDifference(
            subs,
            [
                Subtitle(
                    number: 1,
                    start: Timestamp(hours: 0, minutes: 5, seconds: 0, fraction: 040, fractionDigitCount: 3),
                    end: Timestamp(hours: 0, minutes: 5, seconds: 15, fraction: 300, fractionDigitCount: 3),
                    text: "This is an example of\na subtitle."
                ),

                Subtitle(
                    number: 2,
                    start: Timestamp(hours: 0, minutes: 5, seconds: 16, fraction: 400, fractionDigitCount: 3),
                    end: Timestamp(hours: 0, minutes: 5, seconds: 25, fraction: 300, fractionDigitCount: 3),
                    text: "This is an example of\na subtitle - 2nd subtitle."
                ),
            ]
        )
    }

    func testPrintTimestamp() throws {
        let ts = Timestamp(hours: 0, minutes: 1, seconds: 2, fraction: 3, fractionDigitCount: 3)
        let str = String(try timestamp.print(ts))
        expectNoDifference(str, "00:01:02,003")
    }

    func testPrintSubtitle() throws {
        let sub = Subtitle(
            number: 1,
            start: Timestamp(hours: 0, minutes: 5, seconds: 0, fraction: 400, fractionDigitCount: 3),
            end: Timestamp(hours: 0, minutes: 5, seconds: 15, fraction: 300, fractionDigitCount: 3),
            text: "This is an example of\na subtitle."
        )
        let str = String(try subtitle.print(sub))
        expectNoDifference(
            str,
            """
            1
            00:05:00,400 --> 00:05:15,300
            This is an example of
            a subtitle.


            """
        )
    }

    func testPrintDocument() throws {
        let subs = [
            Subtitle(
                number: 1,
                start: Timestamp(hours: 0, minutes: 5, seconds: 0, fraction: 040, fractionDigitCount: 3),
                end: Timestamp(hours: 0, minutes: 5, seconds: 15, fraction: 300, fractionDigitCount: 3),
                text: "This is an example of\na subtitle."
            ),

            Subtitle(
                number: 2,
                start: Timestamp(hours: 0, minutes: 5, seconds: 16, fraction: 400, fractionDigitCount: 3),
                end: Timestamp(hours: 0, minutes: 5, seconds: 25, fraction: 300, fractionDigitCount: 3),
                text: "This is an example of\na subtitle - 2nd subtitle."
            ),
        ]
        let doc = String(try subtitlesDocument.print(subs))
        let expect = """
        1
        00:05:00,040 --> 00:05:15,300
        This is an example of
        a subtitle.

        2
        00:05:16,400 --> 00:05:25,300
        This is an example of
        a subtitle - 2nd subtitle.


        """

        expectNoDifference(doc, expect)
    }
}

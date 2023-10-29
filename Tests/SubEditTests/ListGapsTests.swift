import CustomDump
import SRTParse
import SubEdit
import XCTest

final class ListGapsTests: XCTestCase {
    func testListGaps() throws {
        let subs = [
            Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
            Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
            Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
            Sub(start: Duration.seconds(10), duration: Duration.seconds(1), text: "s4"),
            Sub(start: Duration.seconds(15), duration: Duration.seconds(1), text: "s5"),
            Sub(start: Duration.seconds(21), duration: Duration.seconds(1), text: "s6"),
            Sub(start: Duration.seconds(28), duration: Duration.seconds(1), text: "s7"),
            Sub(start: Duration.seconds(36), duration: Duration.seconds(1), text: "s8"),
        ]
        let editor = SubEditor(
            srtSubs: SRTSubs(
                subs: subs,
                newlineMode: .lf
            )
        )

        let gaps = try editor.listGaps(numberRange: 2 ... 6)
        XCTAssertNoDifference(
            gaps,
            [
                GapListEntry(number: 2, sub: subs[1], gap: .seconds(2)),
                GapListEntry(number: 3, sub: subs[2], gap: .seconds(3)),
                GapListEntry(number: 4, sub: subs[3], gap: .seconds(4)),
                GapListEntry(number: 5, sub: subs[4], gap: .seconds(5)),
                GapListEntry(number: 6, sub: subs[5], gap: .seconds(6)),
            ]
        )
    }

    func testListGapsWithLast() throws {
        let subs = [
            Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
            Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
            Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
            Sub(start: Duration.seconds(10), duration: Duration.seconds(1), text: "s4"),
            Sub(start: Duration.seconds(15), duration: Duration.seconds(1), text: "s5"),
            Sub(start: Duration.seconds(21), duration: Duration.seconds(1), text: "s6"),
        ]
        let editor = SubEditor(
            srtSubs: SRTSubs(
                subs: subs,
                newlineMode: .lf
            )
        )

        let gaps = try editor.listGaps(numberRange: 2 ... 6)
        XCTAssertNoDifference(
            gaps,
            [
                GapListEntry(number: 2, sub: subs[1], gap: .seconds(2)),
                GapListEntry(number: 3, sub: subs[2], gap: .seconds(3)),
                GapListEntry(number: 4, sub: subs[3], gap: .seconds(4)),
                GapListEntry(number: 5, sub: subs[4], gap: .seconds(5)),
                GapListEntry(number: 6, sub: subs[5], gap: .zero),
            ]
        )
    }

    func testListEmpty() throws {
        let subs = [
            Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
            Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
        ]
        let editor = SubEditor(
            srtSubs: SRTSubs(
                subs: subs,
                newlineMode: .lf
            )
        )

        let gaps = try editor.listGaps(numberRange: 2 ... 2)
        XCTAssertNoDifference(gaps, [])
    }

    func testBadLower() throws {
        let subs = [
            Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
            Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
        ]
        let editor = SubEditor(
            srtSubs: SRTSubs(
                subs: subs,
                newlineMode: .lf
            )
        )

        XCTAssertThrowsError(try editor.listGaps(numberRange: 3 ... 4)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(numberError, SubtitleNumberError(number: 3, numberOfEntries: 2))
        }
    }

    func testBadUpper() throws {
        let subs = [
            Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
            Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
        ]
        let editor = SubEditor(
            srtSubs: SRTSubs(
                subs: subs,
                newlineMode: .lf
            )
        )

        XCTAssertThrowsError(try editor.listGaps(numberRange: 2 ... 4)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(numberError, SubtitleNumberError(number: 4, numberOfEntries: 2))
        }
    }
}

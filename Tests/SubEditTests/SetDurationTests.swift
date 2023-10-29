import CustomDump
import SRTParse
import SubEdit
import XCTest

final class SetDurationTests: XCTestCase {
    func testSetDurationNegative() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setDuration(number: 1, duration: Duration.seconds(-1), shouldAdjustRest: false)
        ) { error in
            guard let durationError = error as? InvalidDurationError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(durationError, InvalidDurationError(duration: .seconds(-1)))
        }
    }

    func testDurationTooSmallNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setDuration(number: 0, duration: .seconds(3), shouldAdjustRest: true)
        ) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 0, numberOfEntries: 2))
        }
    }

    func testDurationTooLargeNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setDuration(number: 3, duration: .seconds(3), shouldAdjustRest: true)
        ) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 3, numberOfEntries: 2))
        }
    }

    func testSetDurationOverlap() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setDuration(number: 1, duration: Duration.seconds(3), shouldAdjustRest: false)
        ) { error in
            guard let durationError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(
                durationError,
                TimeOverlapError(
                    targetNumber: 1,
                    targetSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    requestedTime: .duration(.seconds(3)),
                    overlappingNumber: 2,
                    overlappingSub: Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2")
                )
            )
        }
    }

    func testSetDurationOverlapAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setDuration(number: 1, duration: Duration.seconds(3), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(3), text: "s1"),
                Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetDuration() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setDuration(number: 1, duration: Duration.seconds(2), shouldAdjustRest: false)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(2), text: "s1"),
                Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetDurationAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setDuration(number: 1, duration: Duration.seconds(2), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(2), text: "s1"),
                Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }
}

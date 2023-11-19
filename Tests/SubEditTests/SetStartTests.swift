import CustomDump
import SRTParse
import SubEdit
import XCTest

final class SetStartTests: XCTestCase {
    func testSetStartBackwardsNoAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setStart(number: 1, at: Duration.milliseconds(500), shouldAdjustRest: false)

        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.milliseconds(500), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetStartNegative() {
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
            try editor.setStart(number: 1, at: Duration.seconds(-1), shouldAdjustRest: false)
        ) { error in

            guard let durationError = error as? InvalidDurationError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(durationError, InvalidDurationError(duration: .seconds(-1)))
        }
    }

    func testSetStartOverlapPrevious() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setStart(number: 2, at: .seconds(1), shouldAdjustRest: false)) { error in
            guard let overlapError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(
                overlapError,
                TimeOverlapError(
                    targetNumber: 2,
                    targetSub: Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                    requestedTime: .start(.seconds(1)),
                    overlappingNumber: 1,
                    overlappingSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1")
                )
            )
        }
    }

    func testSetStartOverlapEndOfPrevious() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setStart(number: 2, at: .seconds(2), shouldAdjustRest: false)) { error in
            guard let overlapError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(
                overlapError,
                TimeOverlapError(
                    targetNumber: 2,
                    targetSub: Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                    requestedTime: .start(.seconds(2)),
                    overlappingNumber: 1,
                    overlappingSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1")
                )
            )
        }
    }

    func testSetStartOverlapNext() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setStart(number: 1, at: .seconds(3), shouldAdjustRest: false)) { error in
            guard let overlapError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(
                overlapError,
                TimeOverlapError(
                    targetNumber: 1,
                    targetSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    requestedTime: .start(.seconds(3)),
                    overlappingNumber: 2,
                    overlappingSub: Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2")
                )
            )
        }
    }

    func testSetStartOverlapNextWithAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setStart(number: 1, at: .seconds(3), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetStartTooSmallNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setStart(number: 0, at: .seconds(3), shouldAdjustRest: true)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 0, numberOfEntries: 2))
        }
    }

    func testSetStartTooLargeNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setStart(number: 3, at: .seconds(3), shouldAdjustRest: true)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 3, numberOfEntries: 2))
        }
    }

    func testSetStartBackwardAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(4), duration: Duration.seconds(1), text: "s2"),
                    Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
                    Sub(start: Duration.seconds(8), duration: Duration.seconds(1), text: "s4"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setStart(number: 2, at: .seconds(3), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s3"),
                Sub(start: Duration.seconds(7), duration: Duration.seconds(1), text: "s4"),
            ]
        )
    }

    func testSetStartBackwardNoAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s3"),
                    Sub(start: Duration.seconds(7), duration: Duration.seconds(1), text: "s4"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setStart(number: 1, at: .seconds(0), shouldAdjustRest: false)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(0), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s3"),
                Sub(start: Duration.seconds(7), duration: Duration.seconds(1), text: "s4"),
            ]
        )
    }

    func testSetStartForwardAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s3"),
                    Sub(start: Duration.seconds(7), duration: Duration.seconds(1), text: "s4"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setStart(number: 2, at: .seconds(4), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(4), duration: Duration.seconds(1), text: "s2"),
                Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
                Sub(start: Duration.seconds(8), duration: Duration.seconds(1), text: "s4"),
            ]
        )
    }

    func testSetStartForwardNoAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(4), duration: Duration.seconds(1), text: "s2"),
                    Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
                    Sub(start: Duration.seconds(8), duration: Duration.seconds(1), text: "s4"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setStart(number: 1, at: .seconds(2), shouldAdjustRest: false)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(2), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(4), duration: Duration.seconds(1), text: "s2"),
                Sub(start: Duration.seconds(6), duration: Duration.seconds(1), text: "s3"),
                Sub(start: Duration.seconds(8), duration: Duration.seconds(1), text: "s4"),
            ]
        )
    }
}

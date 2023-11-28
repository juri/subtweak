import CustomDump
import SRTParse
import SubEdit
import XCTest

final class SetTextTests: XCTestCase {
    func testSetTextInvalidNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        XCTAssertThrowsError(try editor.setText(number: 10, text: "foo")) { error in
            guard let error = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }

            XCTAssertNoDifference(error, SubtitleNumberError(number: 10, numberOfEntries: 2))
        }
    }

    func testSetText() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        try editor.setText(number: 2, text: "asdf")
        XCTAssertNoDifference(
            editor.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "asdf"),
            ]
        )
    }
}

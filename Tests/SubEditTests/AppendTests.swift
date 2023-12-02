import CustomDump
import SRTParse
import SubEdit
import XCTest

final class AppendTests: XCTestCase {
    func testAppendToEmpty() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [],
                newlineMode: .lf
            )
        )

        editor.append()
        XCTAssertNoDifference(editor.subs, [
            Sub(start: .seconds(1), duration: .seconds(1), text: ""),
        ])
    }

    func testAppendToNonEmpty() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: .seconds(1), duration: .seconds(1), text: ""),
                ],
                newlineMode: .lf
            )
        )

        editor.append()
        XCTAssertNoDifference(editor.subs, [
            Sub(start: .seconds(1), duration: .seconds(1), text: ""),
            Sub(start: .seconds(3), duration: .seconds(1), text: ""),
        ])
    }
}

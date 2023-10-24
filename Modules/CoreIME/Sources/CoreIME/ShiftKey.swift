//
//  ShiftKey.swift
//
//
//  Created by zengwx on 2023/10/20.
//

import AppKit

/// 在我的MacOS上，按一下shift键会产生4个事件序列（在极低概率情况下如下4个事件序列会不符合预期，2和3会错位，因为概率极低，所以暂不处理2和3错位的这种情况）：
/// ```log
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.0 flags=0x20000 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.0 flags=0x20000 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.1 flags=0 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.1 flags=0 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// ```
///
/// 在其他人的MacOS上，按一下shift键只会产生2个事件序列：
/// ```log
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.0 flags=0x20000 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// NSEvent: type=FlagsChanged loc=(0,0) time=502606.1 flags=0 win=0x0 winNum=0 ctxt=0x0 keyCode=56
/// ```
/// 威注音输入法和业火输入法作者都没有考虑4个事件序列（因为他们之前都没发现）的情况，虽然都是按2个事件序列的情况处理的，但“碰巧”也能处理4个事件序列的情况：
/// https://github.com/vChewing/vChewing-macOS/tree/main/Packages/Qwertyyb_ShiftKeyUpChecker
///
public struct ShiftKey {
    private static var shiftKeyFlag = NSEvent.ModifierFlags.shift
    private static var shiftKeyCode: [UInt16] = [56, 60]
    private static var shiftKeyDownSignal = 0
    private static var shiftKeyUpSignal = 0

    public static func isShiftKeyTapped(event: NSEvent) -> Bool {
        func reset() {
            shiftKeyDownSignal = 0
            shiftKeyUpSignal = 0
        }

        guard event.type == .flagsChanged && shiftKeyCode.contains(event.keyCode)
        else { reset(); return false }

        if event.modifierFlags == shiftKeyFlag {
            shiftKeyDownSignal += 1
        } else if event.modifierFlags == .init(rawValue: 0) {
            shiftKeyUpSignal += 1
        }

        // 可以处理2*n(n = 1,2,3...)个事件序列的情况
        let isNonZeroEqual = shiftKeyDownSignal > 0 && shiftKeyUpSignal > 0 && shiftKeyDownSignal == shiftKeyUpSignal
        guard isNonZeroEqual else { return false }
        reset()
        return true
    }
}

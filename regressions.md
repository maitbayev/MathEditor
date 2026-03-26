# MTEditableMathLabelSwift regressions vs legacy ObjC

## Confirmed from prior review

### P2: Redraw the math label after applying a highlight

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L129)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L835)

`highlightCharacter(at:)` mutates `label.displayList`, but the Swift port invalidates the wrapper view instead of the embedded `MTMathUILabel` that actually renders the expression. In the ObjC implementation, `highlightCharacterAtIndex:` calls `[self.label setNeedsDisplay]`. In Swift, the redraw can be missed until some unrelated update forces the label to repaint.

### P2: Clear highlights by relayouting the inner label, not the wrapper

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L137)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L849)

The highlight state lives in the label display list. The ObjC implementation clears it by calling `[self.label setNeedsLayout]`, forcing the embedded math label to rebuild its layout/display list. The Swift port calls `setNeedsLayout()` on the wrapper instead, which can leave stale highlights visible.

## Additional regressions found by comparing ObjC and Swift

### P1: `insertMathList(_:at:)` becomes a no-op when there is no display list

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L161)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L369)

The Swift implementation does `guard let detailedIndex = closestIndex(to: point) else { return }`. That means inserting into an empty label, or a label whose display list has not been built yet, silently does nothing. The ObjC version still inserts at top-level index `0`, because `detailedIndex.atomIndex` on `nil` collapses to `0` under Objective-C nil messaging. This is a functional regression for insertion into empty/not-yet-laid-out editors.

### P1: Swift dropped nib/storyboard initialization support

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L113)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L36)

The legacy ObjC control supports both programmatic initialization and archive-based initialization via `awakeFromNib`. The Swift port marks `init(coder:)` unavailable and unconditionally traps. Any existing XIB, storyboard, or archived view usage that worked with the ObjC implementation cannot be migrated to the Swift class without breaking at runtime.

### P2: Editing taps now show the caret handle instead of hiding it

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L379)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L216)

When the user taps while already editing, the ObjC implementation moves the insertion point and hides the caret handle with `showHandle:NO`. The Swift port changed this to `showHandle(true)`. That changes visible behavior and also expands the active touch target after every tap because hit testing includes the caret view.

### P1: Swift dropped Objective-C-visible `delegate` and `keyboard` integration points

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L86)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.h](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.h#L77)

The legacy control exposes `delegate` and `keyboard` as public Objective-C properties backed by Objective-C protocols, so existing ObjC hosts can assign delegates, provide custom keyboards, and receive editing callbacks. In the Swift rewrite, both properties are Swift-only: the properties themselves are not marked `@objc`, and their protocol types are not Objective-C protocols. That means mixed ObjC code cannot wire up these integration points to the Swift class, which is a migration blocker for existing legacy consumers.

### P2: `textColor = nil` no longer clears the embedded label color

- Swift: [mathEditorSwift/MTEditableMathLabelSwift.swift](/Users/madiyar/Dev/iOS/MathEditor/mathEditorSwift/MTEditableMathLabelSwift.swift#L74)
- ObjC reference: [mathEditor/editor/MTEditableMathLabel.m](/Users/madiyar/Dev/iOS/MathEditor/mathEditor/editor/MTEditableMathLabel.m#L112)

The ObjC setter forwards the assigned value directly to `self.label.textColor`, so callers can reset the math label to its default rendering by assigning `nil`. The Swift setter coalesces `nil` back to the current value with `newValue ?? label.textColor`, so clearing the color becomes a no-op. Any code that relied on clearing a previously customized text color now behaves differently.

## Notes

- The legacy ObjC implementation does not have the two highlight invalidation regressions. It correctly targets `self.label` in both `highlightCharacterAtIndex:` and `clearHighlights`.
- Keyboard-state logic in `setKeyboardMode()` appears materially equivalent between ObjC and Swift.

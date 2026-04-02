# Swift vs Objective-C regression review

## Scope
Compared `MTEditableMathLabelSwift` against legacy `MTEditableMathLabel` implementation in Objective-C.

## Status update (April 1, 2026)
The previously reported guard/early-return insert regressions have been resolved in Swift by consistently using a fallback insertion index (`resolvedInsertionIndex()`) and by applying display invalidation directly to `label`.

## Resolved regressions

1. `insertMathList(_:at:)` no longer drops inserts when no closest index is available.
2. Normal typed input no longer no-ops when `insertionIndex` is `nil`.
3. Special insert operations (`^`, `_`, `/`, radicals, paired inserts) no longer no-op when `insertionIndex` is `nil`.
4. Paired shortcuts (`"()"`, `"||"`) no longer drop due to nil-index early return.
5. First-key race after tap-to-edit no longer drops operators due to nil-index guards.
6. Highlight redraw now invalidates `MTMathUILabel` directly.
7. Clearing highlights now relayouts the inner label directly.
8. `textColor` setter no longer coalesces nil to current color (the prior no-op behavior is removed).

## Active regressions / parity gaps

### 1) Swift class cannot be initialized from nib/storyboard (`init(coder:)` unavailable)
- **Swift behavior**: `init(coder:)` is unavailable and traps.
- **Legacy Objective-C behavior**: Supports archive-based initialization via `awakeFromNib`.
- **Impact**: Existing nib/storyboard integrations that worked with `MTEditableMathLabel` are not drop-in compatible with `MTEditableMathLabelSwift`.
- **Relevant files**:
  - `MathEditorSwift/Sources/MathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 2) Tap-while-editing shows caret handle (legacy hides it)
- **Swift behavior**: In `handleTap(at:)`, already-editing taps call `caretView.showHandle(true)`.
- **Legacy Objective-C behavior**: `handleTapAtPoint:` calls `[_caretView showHandle:NO]` in the same branch.
- **Impact**: Visible interaction behavior and hit area differ from legacy.
- **Relevant files**:
  - `MathEditorSwift/Sources/MathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 3) Objective-C integration points for `delegate`/`keyboard` are not API-compatible
- **Swift behavior**: `delegate` and `keyboard` are Swift protocol-typed properties using non-`@objc` protocols.
- **Legacy Objective-C behavior**: Public ObjC properties use ObjC protocols (`id<MTEditableMathLabelDelegate>`, `MTView<MTMathKeyboard>*`).
- **Impact**: Legacy ObjC hosts cannot use the same delegate/keyboard contracts as a drop-in migration.
- **Relevant files**:
  - `MathEditorSwift/Sources/MathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.h`

### 4) `mathList = nil` clear semantics are not preserved in Swift API
- **Swift behavior**: `mathList` is non-optional and cannot be assigned `nil` in Swift.
- **Legacy Objective-C behavior**: `setMathList:` treats `nil` as clear and replaces with a new empty `MTMathList`.
- **Impact**: Hosts depending on nil-assignment clear behavior must switch to `clear()` or equivalent logic.
- **Relevant files**:
  - `MathEditorSwift/Sources/MathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 5) Keyboard `equalsAllowed` behavior differs from legacy
- **Swift behavior**: `setKeyboardMode()` resets `keyboard?.equalsAllowed = true` and then disables in superscript, numerator, and denominator.
- **Legacy Objective-C behavior**: No unconditional reset; denominator disabling remains commented out.
- **Impact**: `=` availability can diverge from legacy based on cursor transitions and denominator context.
- **Relevant files**:
  - `MathEditorSwift/Sources/MathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

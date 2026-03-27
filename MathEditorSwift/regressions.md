# Swift vs Objective-C regression review

## Scope
Compared `mathEditorSwift` against legacy `mathEditor`, with emphasis on Swift-only `guard` and early-return behavior.

## Regressions

### 1) `insertMathList(_:at:)` silently drops inserts when no closest index is available
- **Swift behavior**: Returns early when `closestIndex(to:)` is `nil`.
  - `guard let detailedIndex = closestIndex(to: point) else { return }`
- **Legacy Objective-C behavior**: No early return; code proceeds using `detailedIndex.atomIndex` even when `detailedIndex` is `nil` (Objective-C nil messaging effectively falls back to index `0`), so list content still gets inserted.
- **Impact**: Programmatic inserts can be lost in Swift in edge cases where the display list is not yet ready.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 2) Swift drops normal typed input when `insertionIndex` is `nil`
- **Swift behavior**: In `insertText(_:)`, normal atom insertion is gated by `if let insertedAtom, let insertionIndex { ... }`; when `insertionIndex` is `nil`, nothing is inserted and no fallback index is chosen.
- **Legacy Objective-C behavior**: Uses `_insertionIndex` directly; with Objective-C nil messaging, insertion APIs are still invoked rather than skipped.
- **Impact**: Input can be ignored in transient states (e.g., before insertion point is initialized) instead of being inserted at a default position.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 3) Swift special insert operations no-op when `insertionIndex` is `nil`
- **Swift behavior**: Multiple operations immediately return on missing `insertionIndex`:
  - `handleScriptButton(_:)`
  - `handleSlashButton()`
  - `handleRadical(withDegreeButtonPressed:)`
  - `insertPairedAtoms(open:close:)`
- **Legacy Objective-C behavior**: Same operations execute without explicit index guards; nil messaging allows the methods to proceed instead of immediate no-op.
- **Impact**: `^`, `_`, `/`, radicals, and paired insertions (`()`, `||`) can be dropped in Swift under the same transient nil-index state.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

## Guard-specific note requested
The Swift pattern `guard let insertionIndex else { return }` (and similar early returns) is the main source of these regressions. In Objective-C, equivalent paths commonly continued because messaging `nil` did not short-circuit the entire operation.

## Additional regressions (added)

### 4) Paired insert shortcuts (`"()"`, `"||"`) can be dropped entirely by Swift early return
- **Swift behavior**: `insertText(_:)` routes to `insertParens()` / `insertAbsValue()`, which both call `insertPairedAtoms(open:close:)`. That helper has `guard let insertionIndex ... else { return }`, so the whole shortcut no-ops when the insertion index is temporarily nil.
- **Legacy Objective-C behavior**: `insertParens`/`insertAbsValue` directly execute insertions with `_insertionIndex` and do not short-circuit on a nil guard.
- **Impact**: User-visible shortcuts can be ignored in transient index-init windows where legacy behavior still inserted delimiters.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 5) First-key race after tap-to-edit: Swift can drop operators due guard-based nil-index exits
- **Swift behavior**: `handleTap(at:)` sets `insertionIndex = nil` before `startEditing()`. If a key arrives before `doBecomeFirstResponder()` reinitializes the index, operations like `^`, `_`, `/`, radicals, and paired insertions can return early through Swift guards.
- **Legacy Objective-C behavior**: The same tap path nils `_insertionIndex`, but operation handlers do not use `guard` exits and continue through nil-messaging paths.
- **Impact**: The first key after entering edit mode can be intermittently dropped in Swift under timing-sensitive input sequences.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

## Additional regressions (highlighting / API parity)

### 6) Highlight redraw targets wrapper view instead of `MTMathUILabel`
- **Swift behavior**: `highlightCharacter(at:)` updates `displayList` and calls `setNeedsDisplayCompat()` on the wrapper view.
- **Legacy Objective-C behavior**: `highlightCharacterAtIndex:` calls `[self.label setNeedsDisplay]` on the embedded math label.
- **Impact**: Highlight changes can be visually delayed/missed until some other update repaints `MTMathUILabel`.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 7) Clearing highlights relayouts wrapper instead of the inner math label
- **Swift behavior**: `clearHighlights()` calls `setNeedsLayout()` on the wrapper view.
- **Legacy Objective-C behavior**: `clearHighlights` calls `[self.label setNeedsLayout]`, directly invalidating the display-list owner.
- **Impact**: Stale highlight state may persist because the label display list is not explicitly rebuilt.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 8) Swift class cannot be initialized from nib/storyboard (`init(coder:)` unavailable)
- **Swift behavior**: `init(coder:)` is marked unavailable and traps.
- **Legacy Objective-C behavior**: Supports archive-based initialization via `awakeFromNib`.
- **Impact**: Existing nib/storyboard integrations that worked with `MTEditableMathLabel` are not drop-in compatible with `MTEditableMathLabelSwift`.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 9) Tap-while-editing now shows the caret handle (legacy hid it)
- **Swift behavior**: In `handleTap(at:)`, already-editing taps call `caretView.showHandle(true)`.
- **Legacy Objective-C behavior**: `handleTapAtPoint:` uses `[_caretView showHandle:NO]` in the same branch.
- **Impact**: Visible interaction behavior changes and touch-hit area around caret becomes active after each editing tap.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 10) `textColor = nil` no longer clears custom text color
- **Swift behavior**: Setter coalesces nil with `newValue ?? label.textColor`, turning nil assignment into a no-op.
- **Legacy Objective-C behavior**: Setter forwards `textColor` directly to `self.label.textColor`, allowing nil reset semantics.
- **Impact**: Hosts that clear a previously set color by assigning nil no longer get legacy behavior.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 11) Objective-C integration points for `delegate`/`keyboard` are not API-compatible
- **Swift behavior**: `delegate` and `keyboard` are Swift-only protocol-typed properties (not exposed with Objective-C protocol-compatible types).
- **Legacy Objective-C behavior**: Public ObjC properties use ObjC protocols (`id<MTEditableMathLabelDelegate>`, `MTView<MTMathKeyboard>*`).
- **Impact**: Legacy ObjC hosts cannot wire the same delegate/keyboard contracts to `MTEditableMathLabelSwift` as a drop-in migration.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.h`

### 12) `mathList = nil` no longer clears the editor
- **Swift behavior**: `mathList` is a non-optional property, so callers cannot clear the editor by assigning `nil`.
- **Legacy Objective-C behavior**: `setMathList:` explicitly treats `nil` as a clear operation and replaces it with a new empty `MTMathList`.
- **Impact**: Existing hosts that reset the editor by assigning `nil` lose that API behavior and must switch to a different clearing path.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

### 13) Keyboard `equalsAllowed` state differs from legacy behavior
- **Swift behavior**: `setKeyboardMode()` unconditionally resets `keyboard?.equalsAllowed = true`, then disables it in superscripts, numerators, and denominators.
- **Legacy Objective-C behavior**: `setKeyboardMode` does not reset `equalsAllowed` to `YES` up front, disables it for superscripts and numerators, and leaves the denominator branch commented out.
- **Impact**: Keyboard availability for `=` can differ from legacy, especially after moving the caret between contexts or when editing in a denominator. This is an inference from the two implementations' state transitions.
- **Relevant files**:
  - `mathEditorSwift/MTEditableMathLabelSwift.swift`
  - `mathEditor/editor/MTEditableMathLabel.m`

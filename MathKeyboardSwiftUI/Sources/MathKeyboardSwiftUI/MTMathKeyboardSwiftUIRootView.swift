#if os(iOS)

  import MathEditor
  import MathKeyboard
  import SwiftUI
  import UIKit

  public final class MTMathKeyboardSwiftUIRootView: UIView, MTMathKeyboard, UIInputViewAudioFeedback
  {
    private static let defaultTab: KeyboardTab = .numbers
    private static let shared = MTMathKeyboardSwiftUIRootView()

    private var state = KeyboardState()
    private weak var textInput: (any UIView & UIKeyInput)?
    private lazy var hostingController = UIHostingController(
      rootView: makeRootView()
    )

    public var enableInputClicksWhenVisible: Bool {
      true
    }

    public override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }

    public required init?(coder: NSCoder) {
      super.init(coder: coder)
      commonInit()
    }

    public static func sharedInstance() -> MTMathKeyboardSwiftUIRootView {
      shared
    }

    public func switchToDefaultTab() {
      updateState { $0.currentTab = Self.defaultTab }
    }

    public var equalsAllowed: Bool {
      get { state.equalsAllowed }
      set { updateState { $0.equalsAllowed = newValue } }
    }

    public var fractionsAllowed: Bool {
      get { state.fractionsAllowed }
      set { updateState { $0.fractionsAllowed = newValue } }
    }

    public var variablesAllowed: Bool {
      get { state.variablesAllowed }
      set { updateState { $0.variablesAllowed = newValue } }
    }

    public var numbersAllowed: Bool {
      get { state.numbersAllowed }
      set { updateState { $0.numbersAllowed = newValue } }
    }

    public var operatorsAllowed: Bool {
      get { state.operatorsAllowed }
      set { updateState { $0.operatorsAllowed = newValue } }
    }

    public var exponentHighlighted: Bool {
      get { state.exponentHighlighted }
      set { updateState { $0.exponentHighlighted = newValue } }
    }

    public var squareRootHighlighted: Bool {
      get { state.squareRootHighlighted }
      set { updateState { $0.squareRootHighlighted = newValue } }
    }

    public var radicalHighlighted: Bool {
      get { state.radicalHighlighted }
      set { updateState { $0.radicalHighlighted = newValue } }
    }

    public func startedEditing(_ label: (any UIView & UIKeyInput)!) {
      textInput = label
      updateRootView()
    }

    public func finishedEditing(_ label: (any UIView & UIKeyInput)!) {
      if textInput === label {
        textInput = nil
        updateRootView()
      }
    }

    private func updateState(_ update: (inout KeyboardState) -> Void) {
      update(&state)
      updateRootView()
    }

    private func makeRootView() -> MathKeyboardRootView {
      MathKeyboardRootView(
        state: state,
        textInput: textInput,
        onTabSelected: { [weak self] tab in
          self?.updateState { $0.currentTab = tab }
        }
      )
    }

    private func commonInit() {
      backgroundColor = .white
      autoresizingMask = [.flexibleWidth, .flexibleHeight]

      let hostedView = hostingController.view!
      if #available(iOS 16.4, *) {
        hostingController.safeAreaRegions = []
      }
      hostedView.backgroundColor = .clear
      addSubview(hostedView)
      hostedView.pinToSuperview()

      updateRootView()
    }

    private func updateRootView() {
      hostingController.rootView = makeRootView()
    }
  }

#endif

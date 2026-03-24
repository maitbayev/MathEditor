#if os(iOS)

  import SwiftUI
  import UIKit

  final class LettersKeyboardUIView: UIView, KeyboardConfigurable {
    private var keyboardState = KeyboardState()
    private var isLowercase = true
    private weak var textInput: (any UIView & UIKeyInput)?
    private lazy var hostingController = UIHostingController(rootView: makeRootView())

    override init(frame: CGRect) {
      super.init(frame: frame)
      commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setTextInput(_ textView: (any UIView & UIKeyInput)?) {
      textInput = textView
    }

    func applyKeyboardState(_ state: KeyboardState) {
      updateState { $0 = state }
    }

    private func commonInit() {
      translatesAutoresizingMaskIntoConstraints = false
      backgroundColor = .white

      let hostedView = hostingController.view!
      if #available(iOS 16.4, *) {
        hostingController.safeAreaRegions = []
      }
      hostedView.backgroundColor = .clear
      addSubview(hostedView)
      hostedView.pinToSuperview()

      hostingController.rootView = makeRootView()
    }

    private func makeRootView() -> LettersKeyboardView {
      LettersKeyboardView(
        state: keyboardState,
        isLowercase: isLowercase,
        onShift: { [weak self] in
          guard let self else { return }
          self.isLowercase.toggle()
          self.hostingController.rootView = self.makeRootView()
        },
        onAction: { [weak self] action in self?.handle(action) }
      )
    }

    private func handle(_ action: KeyboardAction) {
      playClickForCustomKeyTap()

      switch action {
      case .insertText(let text):
        textInput?.insertText(text)
      case .backspace:
        textInput?.deleteBackward()
      case .dismiss:
        textInput?.resignFirstResponder()
      }
    }

    private func playClickForCustomKeyTap() {
      UIDevice.current.playInputClick()
    }

    private func updateState(_ update: @escaping (inout KeyboardState) -> Void) {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        let previousState = self.keyboardState
        update(&self.keyboardState)
        guard self.keyboardState != previousState else { return }
        self.hostingController.rootView = self.makeRootView()
      }
    }
  }

#endif  // os(iOS)

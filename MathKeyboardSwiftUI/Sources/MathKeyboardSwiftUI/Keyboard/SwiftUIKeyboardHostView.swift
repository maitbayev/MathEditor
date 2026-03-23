#if os(iOS)

  import SwiftUI
  import UIKit

  final class SwiftUIKeyboardHostView: UIView, KeyboardConfigurable, UIInputViewAudioFeedback {
    typealias RootViewBuilder = (KeyboardState, @escaping (KeyboardAction) -> Void) -> AnyView

    private var keyboardState = KeyboardState()
    private weak var editingTarget: (any UIView & UIKeyInput)?
    private let rootViewBuilder: RootViewBuilder
    private lazy var hostingController = UIHostingController(rootView: AnyView(EmptyView()))

    init(rootViewBuilder: @escaping RootViewBuilder) {
      self.rootViewBuilder = rootViewBuilder
      super.init(frame: .zero)
      commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setEditingTarget(_ textView: (any UIView & UIKeyInput)?) {
      editingTarget = textView
    }

    func applyKeyboardState(_ state: KeyboardState) {
      updateState { $0 = state }
    }

    var enableInputClicksWhenVisible: Bool { true }

    private func commonInit() {
      backgroundColor = .white

      let hostedView = hostingController.view!
      if #available(iOS 16.4, *) {
        hostingController.safeAreaRegions = []
      }
      hostedView.backgroundColor = .clear
      hostedView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(hostedView)

      NSLayoutConstraint.activate([
        hostedView.topAnchor.constraint(equalTo: topAnchor),
        hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
        hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
        hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])

      hostingController.rootView = makeRootView()
    }

    private func makeRootView() -> AnyView {
      rootViewBuilder(keyboardState, { [weak self] action in self?.handle(action) })
    }

    private func handle(_ action: KeyboardAction) {
      playClickForCustomKeyTap()

      switch action {
      case .insertText(let text):
        editingTarget?.insertText(text)
      case .backspace:
        editingTarget?.deleteBackward()
      case .dismiss:
        editingTarget?.resignFirstResponder()
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

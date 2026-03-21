#if os(iOS)

  import MathEditor
  import MathKeyboard
  import SwiftUI
  import UIKit

  @objcMembers
  public final class MTMathKeyboardSwiftUIRootView: UIView, MTMathKeyboard {
    fileprivate static let defaultSize = CGSize(width: 320, height: 225)
    private static let defaultTab: KeyboardTab = .numbers
    private static let shared = MTMathKeyboardSwiftUIRootView(
      frame: CGRect(origin: .zero, size: defaultSize)
    )

    private let controller = KeyboardController()
    private let hostingController: UIHostingController<KeyboardRootContentView>

    public override init(frame: CGRect) {
      hostingController = UIHostingController(
        rootView: KeyboardRootContentView(controller: controller)
      )
      super.init(frame: frame)
      commonInit()
    }

    public required init?(coder: NSCoder) {
      hostingController = UIHostingController(
        rootView: KeyboardRootContentView(controller: controller)
      )
      super.init(coder: coder)
      commonInit()
    }

    public static func sharedInstance() -> MTMathKeyboardSwiftUIRootView {
      shared
    }

    public func switchToDefaultTab() {
      controller.currentTab = Self.defaultTab
    }

    public var equalsAllowed: Bool {
      get { controller.equalsAllowed }
      set { controller.equalsAllowed = newValue }
    }

    public var fractionsAllowed: Bool {
      get { controller.fractionsAllowed }
      set { controller.fractionsAllowed = newValue }
    }

    public var variablesAllowed: Bool {
      get { controller.variablesAllowed }
      set { controller.variablesAllowed = newValue }
    }

    public var numbersAllowed: Bool {
      get { controller.numbersAllowed }
      set { controller.numbersAllowed = newValue }
    }

    public var operatorsAllowed: Bool {
      get { controller.operatorsAllowed }
      set { controller.operatorsAllowed = newValue }
    }

    public var exponentHighlighted: Bool {
      get { controller.exponentHighlighted }
      set { controller.exponentHighlighted = newValue }
    }

    public var squareRootHighlighted: Bool {
      get { controller.squareRootHighlighted }
      set { controller.squareRootHighlighted = newValue }
    }

    public var radicalHighlighted: Bool {
      get { controller.radicalHighlighted }
      set { controller.radicalHighlighted = newValue }
    }

    public func startedEditing(_ label: (any UIView & UIKeyInput)!) {
      controller.startedEditing(label)
    }

    public func finishedEditing(_ label: (any UIView & UIKeyInput)!) {
      controller.finishedEditing()
    }

    private func commonInit() {
      backgroundColor = .white
      autoresizingMask = [.flexibleWidth, .flexibleHeight]

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
    }
  }

  private enum KeyboardTab: Int, CaseIterable {
    case numbers
    case operations
    case functions
    case letters

    var imageNames: (normal: String, selected: String) {
      switch self {
      case .numbers: return ("Numbers Symbol wbg", "Number Symbol")
      case .operations: return ("Operations Symbol wbg", "Operations Symbol")
      case .functions: return ("Functions Symbol wbg", "Functions Symbol")
      case .letters: return ("Letter Symbol wbg", "Letter Symbol")
      }
    }
  }

  private final class KeyboardController: ObservableObject {
    @Published var currentTab: KeyboardTab = .numbers

    var equalsAllowed = false { didSet { forEachKeyboard { $0.setEqualsState(equalsAllowed) } } }
    var fractionsAllowed = false {
      didSet { forEachKeyboard { $0.setFractionState(fractionsAllowed) } }
    }
    var variablesAllowed = false {
      didSet { forEachKeyboard { $0.setVariablesState(variablesAllowed) } }
    }
    var numbersAllowed = false { didSet { forEachKeyboard { $0.setNumbersState(numbersAllowed) } } }
    var operatorsAllowed = false {
      didSet { forEachKeyboard { $0.setOperatorState(operatorsAllowed) } }
    }
    var exponentHighlighted = false {
      didSet { forEachKeyboard { $0.setExponentState(exponentHighlighted) } }
    }
    var squareRootHighlighted = false {
      didSet { forEachKeyboard { $0.setSquareRootState(squareRootHighlighted) } }
    }
    var radicalHighlighted = false {
      didSet { forEachKeyboard { $0.setRadicalState(radicalHighlighted) } }
    }

    private lazy var keyboards: [KeyboardTab: MTKeyboard] = Dictionary(
      uniqueKeysWithValues: KeyboardTab.allCases.map { tab in
        (tab, makeKeyboard(named: tab.nibName))
      }
    )

    func keyboard(for tab: KeyboardTab) -> MTKeyboard {
      keyboards[tab]!
    }

    func startedEditing(_ label: (any UIView & UIKeyInput)?) {
      forEachKeyboard { $0.textView = label }
    }

    func finishedEditing() {
      forEachKeyboard { $0.textView = nil }
    }

    private func makeKeyboard(named nibName: String) -> MTKeyboard {
      let bundle = MTMathKeyboardRootView.getMathKeyboardResourcesBundle()
      let keyboard = UINib(nibName: nibName, bundle: bundle)
        .instantiate(withOwner: nil, options: nil)
        .compactMap { $0 as? MTKeyboard }
        .first!
      keyboard.translatesAutoresizingMaskIntoConstraints = false
      return keyboard
    }

    private func forEachKeyboard(_ body: (MTKeyboard) -> Void) {
      keyboards.values.forEach(body)
    }
  }

  extension KeyboardTab {
    fileprivate var nibName: String {
      switch self {
      case .numbers: return "MTKeyboard"
      case .operations: return "MTKeyboardTab2"
      case .functions: return "MTKeyboardTab3"
      case .letters: return "MTKeyboardTab4"
      }
    }
  }

  private struct KeyboardRootContentView: View {
    @ObservedObject var controller: KeyboardController

    var body: some View {
      GeometryReader { proxy in
        let totalHeight = max(proxy.size.height, MTMathKeyboardSwiftUIRootView.defaultSize.height)
        let tabHeight = totalHeight / 5.0
        let keyboardHeight = totalHeight - tabHeight

        VStack(spacing: 0) {
          HStack(spacing: 0) {
            ForEach(KeyboardTab.allCases, id: \.rawValue) { tab in
              Button {
                controller.currentTab = tab
              } label: {
                Image(uiImage: tabImage(for: tab))
                  .renderingMode(.original)
                  .resizable()
                  .scaledToFit()
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 6)
              }
              .buttonStyle(.plain)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color(white: 0.768627451))
            }
          }
          .frame(height: tabHeight)

          KeyboardContainerRepresentable(keyboard: controller.keyboard(for: controller.currentTab))
            .frame(height: keyboardHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
      }
    }

    private func tabImage(for tab: KeyboardTab) -> UIImage {
      let names = tab.imageNames
      let name = controller.currentTab == tab ? names.selected : names.normal
      return UIImage(
        named: name,
        in: MTMathKeyboardRootView.getMathKeyboardResourcesBundle(),
        compatibleWith: nil
      ) ?? UIImage()
    }
  }

  private struct KeyboardContainerRepresentable: UIViewRepresentable {
    let keyboard: MTKeyboard

    func makeUIView(context: Context) -> KeyboardContainerView {
      let view = KeyboardContainerView()
      view.display(keyboard: keyboard)
      return view
    }

    func updateUIView(_ uiView: KeyboardContainerView, context: Context) {
      uiView.display(keyboard: keyboard)
    }
  }

  private final class KeyboardContainerView: UIView {
    private weak var currentKeyboard: UIView?

    override var intrinsicContentSize: CGSize {
      CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    func display(keyboard: UIView) {
      guard currentKeyboard !== keyboard else { return }

      currentKeyboard?.removeFromSuperview()
      currentKeyboard = keyboard
      addSubview(keyboard)

      NSLayoutConstraint.activate([
        keyboard.topAnchor.constraint(equalTo: topAnchor),
        keyboard.leadingAnchor.constraint(equalTo: leadingAnchor),
        keyboard.trailingAnchor.constraint(equalTo: trailingAnchor),
        keyboard.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
    }
  }
#endif

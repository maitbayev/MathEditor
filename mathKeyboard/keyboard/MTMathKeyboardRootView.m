//
//  MCMathKeyboardRootView.m
//  MathChat
//
//  Created by MARIO ANDHIKA on 7/16/15.
//  Copyright (c) 2015 MathChat, Inc.
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#if TARGET_OS_IPHONE

#import "MTMathKeyboardRootView.h"

static NSInteger const DEFAULT_KEYBOARD = 0;

@interface MTMathKeyboardRootView ()

@property (nonatomic) MTKeyboard *currentKeyboard;
@property (nonatomic) MTKeyboard *tab1Keyboard;
@property (nonatomic) MTKeyboard *tab2Keyboard;
@property (nonatomic) MTKeyboard *tab3Keyboard;
@property (nonatomic) MTKeyboard *tab4Keyboard;
@property (nonatomic) NSInteger currentTab;
@property (nonatomic) NSArray<MTKeyboard*> *keyboards;

@end

@implementation MTMathKeyboardRootView {
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

// Keyboard should be singleton
+(instancetype)sharedInstance {
    static MTMathKeyboardRootView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithFrame:CGRectMake(0, 0, 320, 225)];
    });
    
    return instance;
}

// Gets the math keyboard resources bundle
+(NSBundle *)getMathKeyboardResourcesBundle
{
    return SWIFTPM_MODULE_BUNDLE;
}

- (UIButton *)buildTabButtonWithTag:(NSInteger)tag
                           normalImage:(NSString *)normalImageName
                         selectedImage:(NSString *)selectedImageName
{
    NSBundle *bundle = [MTMathKeyboardRootView getMathKeyboardResourcesBundle];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = tag;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor colorWithWhite:0.7686 alpha:1.0];
    [button setImage:[UIImage imageNamed:normalImageName inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImageName inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(switchTabs:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupStaticLayout
{
    self.backgroundColor = [UIColor whiteColor];
    self.contentMode = UIViewContentModeScaleAspectFill;

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:contentView];
    _contentView = contentView;

    _numbersTab = [self buildTabButtonWithTag:0 normalImage:@"Numbers Symbol wbg" selectedImage:@"Number Symbol"];
    _operationsTab = [self buildTabButtonWithTag:1 normalImage:@"Operations Symbol wbg" selectedImage:@"Operations Symbol"];
    _functionsTab = [self buildTabButtonWithTag:2 normalImage:@"Functions Symbol wbg" selectedImage:@"Functions Symbol"];
    _lettersTab = [self buildTabButtonWithTag:3 normalImage:@"Letter Symbol wbg" selectedImage:@"Letter Symbol"];

    [self addSubview:_numbersTab];
    [self addSubview:_operationsTab];
    [self addSubview:_functionsTab];
    [self addSubview:_lettersTab];

    NSDictionary *views = @{
        @"contentView": contentView,
        @"numbersTab": _numbersTab,
        @"operationsTab": _operationsTab,
        @"functionsTab": _functionsTab,
        @"lettersTab": _lettersTab,
    };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[numbersTab(==operationsTab)][operationsTab(==functionsTab)][functionsTab(==lettersTab)][lettersTab]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[numbersTab(45)][contentView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[operationsTab(==numbersTab)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[functionsTab(==numbersTab)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lettersTab(==numbersTab)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
}

- (void)setupKeyboards
{
    NSBundle* bundle = [MTMathKeyboardRootView getMathKeyboardResourcesBundle];
    _tab1Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboard" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab2Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab2" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab3Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab3" bundle:bundle] instantiateWithOwner:self options:nil][0];
    _tab4Keyboard = (MTKeyboard *)[[UINib nibWithNibName:@"MTKeyboardTab4" bundle:bundle] instantiateWithOwner:self options:nil][0];

    // TODO Use keyboard array for operations involving all tabs
    _keyboards = @[_tab1Keyboard, _tab2Keyboard, _tab3Keyboard, _tab4Keyboard];
    _currentTab = -1;

    for (MTKeyboard *keyboard in _keyboards) {
        [self addFullSizeView:keyboard to:_contentView];
    }
}

- (void)commonInit
{
    [self setupStaticLayout];
    [self setupKeyboards];
    [self switchKeyboard:DEFAULT_KEYBOARD];
}

// To allow resetting of keyboard to the default tab when changing problems
-(void)switchToDefaultTab
{
    [self switchKeyboard:DEFAULT_KEYBOARD];
}

- (IBAction)switchTabs:(UIButton *)sender
{
    [self switchKeyboard:sender.tag];
}

-(void)greyTabButtons
{
    [_numbersTab setSelected:false];
    [_operationsTab setSelected:false];
    [_functionsTab setSelected:false];
    [_lettersTab setSelected:false];
}

-(void)switchKeyboard:(NSInteger)tabNumber
{
    [self greyTabButtons];
    
    switch (tabNumber) {
        case 0:
            [_numbersTab setSelected:true];
            break;
        case 1:
            [_operationsTab setSelected:true];
            break;
        case 2:
            [_functionsTab setSelected:true];
            break;
        case 3:
            [_lettersTab setSelected:true];
            break;
            
        default:
            break;
    }
    
    // check currently active keyboard by tabNumber, skip creation if tabNumber is already the active tab
    if (_currentTab != tabNumber) {
        _currentTab = tabNumber;
        // animate and hold reference to the correct keyboard depending on tabNumber
        [self assignAndAnimateKeyboard:tabNumber];
    }
}

-(void)assignAndAnimateKeyboard:(NSInteger)keyboardNumber
{
    MTKeyboard* newKeyboard = _keyboards[keyboardNumber];

    // animate creation
    // animate destruction
    newKeyboard.alpha = 0.5;
    _currentKeyboard.alpha = 1.0;
    [UIView animateWithDuration:0.1 animations:^{
        newKeyboard.alpha = 1.0;
        _currentKeyboard.alpha = 0.5;
    }];

    [_contentView bringSubviewToFront:newKeyboard];

    // Hold reference to this keyboard so it can be removed from superview
    _currentKeyboard = newKeyboard;
}

- (void)addFullSizeView:(UIView *)view to:(UIView*) parent
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    [parent addSubview:view];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
    [parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views]];
}

#pragma mark - MTMathKeyboardTraits

- (void)setEqualsAllowed:(BOOL)equalsAllowed
{
    _equalsAllowed = equalsAllowed;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setEqualsState:equalsAllowed];
    }
}

- (void)setNumbersAllowed:(BOOL)numbersAllowed
{
    _numbersAllowed = numbersAllowed;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setNumbersState:numbersAllowed];
    }
}

- (void)setOperatorsAllowed:(BOOL)operatorsAllowed
{
    _operatorsAllowed = operatorsAllowed;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setOperatorState:operatorsAllowed];
    }
}

- (void)setVariablesAllowed:(BOOL)variablesAllowed
{
    _variablesAllowed = variablesAllowed;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setVariablesState:variablesAllowed];
    }
}

- (void)setExponentHighlighted:(BOOL)exponentHighlighted
{
    _exponentHighlighted = exponentHighlighted;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setExponentState:exponentHighlighted];
    }
}

- (void)setSquareRootHighlighted:(BOOL)squareRootHighlighted
{
    _squareRootHighlighted = squareRootHighlighted;
        for (MTKeyboard *keyboard in _keyboards) {
    [keyboard setSquareRootState:squareRootHighlighted];
        }
}

- (void)setRadicalHighlighted:(BOOL)radicalHighlighted
{
    _radicalHighlighted = radicalHighlighted;
    for (MTKeyboard *keyboard in _keyboards) {
        [keyboard setRadicalState:radicalHighlighted];
    }
}

- (void)startedEditing:(MTView<MTKeyInput> *)label
{
    for (MTKeyboard *keyboard in _keyboards) {
        keyboard.textView = label;
    }
}

- (void)finishedEditing:(MTView<MTKeyInput> *)label
{
    for (MTKeyboard *keyboard in _keyboards) {
        keyboard.textView = nil;
    }
}

@end

#endif

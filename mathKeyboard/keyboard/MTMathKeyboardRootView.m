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

#import "MTMathKeyboardRootView.h"
#import "MathKeyboard-Swift.h"

static NSInteger const DEFAULT_KEYBOARD = 0;

@interface MTMathKeyboardRootView ()

@property (nonatomic) MTSwiftUIMathKeyboardView *swiftUIView;
@property (nonatomic) NSInteger currentTab;

@end

@implementation MTMathKeyboardRootView

+ (instancetype)sharedInstance {
    static MTMathKeyboardRootView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTMathKeyboardRootView alloc] initWithFrame:CGRectMake(0, 0, 320, 225)];
    });

    return instance;
}

+ (NSBundle *)getMathKeyboardResourcesBundle
{
    return SWIFTPM_MODULE_BUNDLE;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    self.backgroundColor = UIColor.clearColor;
    self.currentTab = -1;
    self.swiftUIView = [[MTSwiftUIMathKeyboardView alloc] initWithFrame:self.bounds];
    [self addFullSizeView:self.swiftUIView to:self];
    [self switchKeyboard:DEFAULT_KEYBOARD];
}

- (void)switchToDefaultTab
{
    [self switchKeyboard:DEFAULT_KEYBOARD];
}

- (IBAction)switchTabs:(UIButton *)sender
{
    [self switchKeyboard:sender.tag];
}

- (void)switchKeyboard:(NSInteger)tabNumber
{
    if (self.currentTab == tabNumber) {
        return;
    }

    self.currentTab = tabNumber;
    [self.swiftUIView setCurrentTab:(int)tabNumber];
}

- (void)addFullSizeView:(UIView *)view to:(UIView *)parent
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
    [self.swiftUIView setEqualsAllowed:equalsAllowed];
}

- (void)setFractionsAllowed:(BOOL)fractionsAllowed
{
    _fractionsAllowed = fractionsAllowed;
    [self.swiftUIView setFractionsAllowed:fractionsAllowed];
}

- (void)setNumbersAllowed:(BOOL)numbersAllowed
{
    _numbersAllowed = numbersAllowed;
    [self.swiftUIView setNumbersAllowed:numbersAllowed];
}

- (void)setOperatorsAllowed:(BOOL)operatorsAllowed
{
    _operatorsAllowed = operatorsAllowed;
    [self.swiftUIView setOperatorsAllowed:operatorsAllowed];
}

- (void)setVariablesAllowed:(BOOL)variablesAllowed
{
    _variablesAllowed = variablesAllowed;
    [self.swiftUIView setVariablesAllowed:variablesAllowed];
}

- (void)setExponentHighlighted:(BOOL)exponentHighlighted
{
    _exponentHighlighted = exponentHighlighted;
    [self.swiftUIView setExponentHighlighted:exponentHighlighted];
}

- (void)setSquareRootHighlighted:(BOOL)squareRootHighlighted
{
    _squareRootHighlighted = squareRootHighlighted;
    [self.swiftUIView setSquareRootHighlighted:squareRootHighlighted];
}

- (void)setRadicalHighlighted:(BOOL)radicalHighlighted
{
    _radicalHighlighted = radicalHighlighted;
    [self.swiftUIView setRadicalHighlighted:radicalHighlighted];
}

- (void)startedEditing:(UIView<UIKeyInput> *)label
{
    self.swiftUIView.textView = label;
}

- (void)finishedEditing:(UIView<UIKeyInput> *)label
{
    self.swiftUIView.textView = nil;
}

@end

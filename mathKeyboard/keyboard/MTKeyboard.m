//
//  MCKeyboard.m
//
//  Created by Kostub Deshmukh on 8/21/13.
//  Copyright (C) 2013 MathChat
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#if TARGET_OS_IPHONE

#import "MTKeyboard.h"
#import "MTFontManager.h"
#import "MTMathAtomFactory.h"

@interface MTKeyboard ()

@property BOOL isLowerCase;
@property (nonatomic) MTKeyboardLayout layout;
@property (nonatomic) NSArray<NSDictionary *> *layoutButtons;
@property (nonatomic) UIImageView *backgroundView;

@end

@implementation MTKeyboard

- (instancetype)initWithLayout:(MTKeyboardLayout)layout
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _layout = layout;
        [self setupProgrammaticKeyboard];
    }
    return self;
}

+ (instancetype)keyboardWithLayout:(MTKeyboardLayout)layout
{
    return [[self alloc] initWithLayout:layout];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _layout = MTKeyboardLayoutNumbers;
        [self setupProgrammaticKeyboard];
    }
    return self;
}

// Get the font Latin Modern Roman - Bold Italic included in
- (NSString*) registerAndGetFontName
{
    static NSString* fontName = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        
        NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
        NSString* fontPath = [bundle pathForResource:@"lmroman10-bolditalic" ofType:@"otf"];
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
        CGFontRef myFont = CGFontCreateWithDataProvider(fontDataProvider);
        CFRelease(fontDataProvider);

        fontName = (__bridge_transfer NSString*) CGFontCopyPostScriptName(myFont);
        CFErrorRef error = NULL;
        CTFontManagerRegisterGraphicsFont(myFont, &error);
        if (error) {
            NSString* errorDescription = (__bridge_transfer NSString*)CFErrorCopyDescription(error);
            NSLog(@"Error registering font: %@", errorDescription);
            CFRelease(error);
        }
        CGFontRelease(myFont);
        NSLog(@"Registered fontName: %@", fontName);
    });
    return fontName;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Keeps compatibility for nib-based initialization.
    if (self.layoutButtons.count == 0) {
        self.layout = MTKeyboardLayoutNumbers;
    }
    NSString* fontName = [self registerAndGetFontName];
    for (UIButton* varButton in self.variables) {
        varButton.titleLabel.font = [UIFont fontWithName:fontName size:varButton.titleLabel.font.pointSize];
    }

    self.isLowerCase = true;
}

- (UIButton *)makeButtonWithTitle:(NSString *)title image:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = YES;
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightRegular];
    [button setTitleColor:[UIColor colorWithRed:0.12 green:0.16 blue:0.22 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.55 green:0.58 blue:0.62 alpha:1.0] forState:UIControlStateDisabled];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    if (title.length > 0) {
        [button setTitle:title forState:UIControlStateNormal];
    }
    if (imageName.length > 0) {
        NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
        UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
        [button setImage:image forState:UIControlStateNormal];
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)applyStyle:(NSString *)style toButton:(UIButton *)button
{
    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
    UIColor *normalTitleColor = [UIColor colorWithRed:0.12 green:0.16 blue:0.22 alpha:1.0];
    NSString *highlightBackground = @"Keyboard-grey-pressed";

    if ([style isEqualToString:@"marine"]) {
        normalTitleColor = [UIColor whiteColor];
        highlightBackground = @"Keyboard-marine-pressed";
    } else if ([style isEqualToString:@"orange"]) {
        highlightBackground = @"Keyboard-orange-pressed";
    } else if ([style isEqualToString:@"green"]) {
        highlightBackground = @"Keyboard-green-pressed";
    } else if ([style isEqualToString:@"azure"]) {
        highlightBackground = @"Keyboard-azure-pressed";
    } else if ([style isEqualToString:@"control"]) {
        normalTitleColor = [UIColor whiteColor];
        highlightBackground = @"Keyboard-grey-pressed";
    }

    [button setTitleColor:normalTitleColor forState:UIControlStateNormal];
    [button setTitleColor:normalTitleColor forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected|UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:highlightBackground inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:highlightBackground inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (void)applyTypographyForToken:(NSString *)token button:(UIButton *)button
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20];
    UIEdgeInsets insets = UIEdgeInsetsZero;

    NSSet *letterLike = [NSSet setWithArray:@[@"x",@"y",@"q",@"w",@"e",@"r",@"t",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"c",@"v",@"b",@"n",@"m",@"α",@"Δ",@"σ",@"μ",@"λ"]];
    if ([letterLike containsObject:token]) {
        font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        insets = UIEdgeInsetsMake(0, 0, 10, 0);
    } else if ([token isEqualToString:@"π"] || [token isEqualToString:@"θ"]) {
        font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20];
    } else if ([token isEqualToString:@"Enter"]) {
        font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    } else if ([token isEqualToString:@"Fraction"]) {
        insets = UIEdgeInsetsMake(5, 0, 5, 0);
    } else if ([token isEqualToString:@"Dismiss"]) {
        insets = UIEdgeInsetsMake(0, 0, 5, 0);
    }

    if (font) {
        button.titleLabel.font = font;
    }
    button.contentEdgeInsets = insets;
}

- (void)addButtonSpec:(NSMutableArray<NSDictionary *> *)specs
               button:(UIButton *)button
                    x:(CGFloat)x
                    y:(CGFloat)y
                width:(CGFloat)width
               height:(CGFloat)height
{
    [specs addObject:@{@"button": button, @"x": @(x), @"y": @(y), @"width": @(width), @"height": @(height)}];
}

- (void)setupProgrammaticKeyboard
{
    self.backgroundColor = [UIColor clearColor];
    NSMutableArray<NSDictionary *> *specs = [NSMutableArray array];
    NSMutableArray<UIButton *> *numbers = [NSMutableArray array];
    NSMutableArray<UIButton *> *operators = [NSMutableArray array];
    NSMutableArray<UIButton *> *variables = [NSMutableArray array];
    NSMutableArray<UIButton *> *relations = [NSMutableArray array];
    NSMutableArray<UIButton *> *letters = [NSMutableArray array];
    NSMutableArray<UIButton *> *greekLetters = [NSMutableArray array];

    NSString *backgroundImageName = @"Numbers Keyboard";
    switch (self.layout) {
        case MTKeyboardLayoutNumbers: {
            NSArray *items = @[
                @[@"x", @0, @0, @50, @45], @[@"7", @50, @0, @49, @45], @[@"8", @99, @0, @50, @45], @[@"9", @149, @0, @50, @45], @[@"÷", @199, @0, @49, @45],
                @[@"y", @0, @45, @50, @45], @[@"4", @50, @45, @49, @45], @[@"5", @99, @45, @50, @45], @[@"6", @149, @45, @50, @45], @[@"×", @199, @45, @49, @45],
                @[@"Fraction", @0, @90, @50, @45], @[@"1", @50, @90, @49, @45], @[@"2", @99, @90, @50, @45], @[@"3", @149, @90, @50, @45], @[@"-", @199, @90, @49, @45],
                @[@"Exponent", @0, @135, @50, @45], @[@"0", @50, @135, @49, @45], @[@".", @99, @135, @50, @45], @[@"=", @149, @135, @50, @45], @[@"+", @199, @135, @49, @45],
            ];
            for (NSArray *item in items) {
                NSString *token = item[0];
                UIButton *button = nil;
                if ([token isEqualToString:@"Fraction"]) {
                    button = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)];
                    self.fractionButton = button;
                    [self applyStyle:@"marine" toButton:button];
                } else if ([token isEqualToString:@"Exponent"]) {
                    button = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)];
                    self.exponentButton = button;
                    [self applyStyle:@"marine" toButton:button];
                    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
                    [button setBackgroundImage:[UIImage imageNamed:@"blue-button-highlighted" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
                } else {
                    button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)];
                    if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"]) {
                        [self applyStyle:@"marine" toButton:button];
                    } else if ([@[@"+",@"-",@"×",@"÷"] containsObject:token]) {
                        [self applyStyle:@"orange" toButton:button];
                    } else {
                        [self applyStyle:@"gray" toButton:button];
                    }
                }
                [self addButtonSpec:specs button:button x:[item[1] floatValue] y:[item[2] floatValue] width:[item[3] floatValue] height:[item[4] floatValue]];
                [self applyTypographyForToken:token button:button];
                if ([@"0123456789." containsString:token]) { [numbers addObject:button]; }
                if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"]) { [variables addObject:button]; }
                if ([@[@"+",@"-",@"×",@"÷"] containsObject:token]) { [operators addObject:button]; }
                if ([token isEqualToString:@"="]) {
                    self.equalsButton = button;
                    [relations addObject:button];
                    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
                    [button setBackgroundImage:[UIImage imageNamed:@"num-button-disabled" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateDisabled];
                }
            }
            UIButton *backspace = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
            UIButton *dismiss = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
            UIButton *enter = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)];
            [self applyStyle:@"control" toButton:backspace];
            [self applyStyle:@"control" toButton:dismiss];
            [self applyStyle:@"control" toButton:enter];
            [self applyTypographyForToken:@"Enter" button:enter];
            [self applyTypographyForToken:@"Dismiss" button:dismiss];
            [self addButtonSpec:specs button:backspace x:248 y:0 width:72 height:45];
            [self addButtonSpec:specs button:enter x:248 y:45 width:72 height:90];
            [self addButtonSpec:specs button:dismiss x:248 y:135 width:72 height:45];
            break;
        }
        case MTKeyboardLayoutOperations: {
            backgroundImageName = @"Operations Keyboard";
            NSArray *items = @[
                @[@"x", @0, @0, @50, @45], @[@"(", @50, @0, @50, @45], @[@")", @100, @0, @50, @45], @[@"<", @150, @0, @49, @45], @[@">", @199, @0, @50, @45],
                @[@"y", @0, @45, @50, @45], @[@"[", @50, @45, @50, @45], @[@"]", @100, @45, @50, @45], @[@"≤", @150, @45, @49, @45], @[@"≥", @199, @45, @50, @45],
                @[@"Fraction", @0, @90, @50, @45], @[@"{", @50, @90, @50, @45], @[@"}", @100, @90, @50, @45], @[@"ABS", @150, @90, @49, @45], @[@"%", @199, @90, @50, @45],
                @[@"Exponent", @0, @135, @50, @45], @[@"!", @50, @135, @50, @45], @[@"∞", @100, @135, @50, @45], @[@":", @150, @135, @49, @45], @[@",", @199, @135, @50, @45],
            ];
            for (NSArray *item in items) {
                NSString *token = item[0];
                UIButton *button = nil;
                if ([token isEqualToString:@"Fraction"]) { button = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)]; self.fractionButton = button; }
                else if ([token isEqualToString:@"Exponent"]) { button = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)]; self.exponentButton = button; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; [button setBackgroundImage:[UIImage imageNamed:@"blue-button-highlighted" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected]; }
                else if ([token isEqualToString:@"ABS"]) { button = [self makeButtonWithTitle:@"|.|" image:nil action:@selector(absValuePressed:)]; }
                else { button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)]; }
                if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"] || [token isEqualToString:@"Fraction"] || [token isEqualToString:@"Exponent"]) { [self applyStyle:@"marine" toButton:button]; }
                else { [self applyStyle:@"orange" toButton:button]; }
                [self addButtonSpec:specs button:button x:[item[1] floatValue] y:[item[2] floatValue] width:[item[3] floatValue] height:[item[4] floatValue]];
                [self applyTypographyForToken:token button:button];
                if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"]) { [variables addObject:button]; }
                if ([@[@"<",@">",@"≤",@"≥"] containsObject:token]) { [relations addObject:button]; }
    [self addTrailingControlsToSpecs:specs
                   backspaceFrame:CGRectMake(248, 0, 72, 45)
                       enterFrame:CGRectMake(248, 45, 72, 90)
                     dismissFrame:CGRectMake(248, 135, 72, 45)];
    [self addTrailingControlsToSpecs:specs
                   backspaceFrame:CGRectMake(249, 0, 71, 45)
                       enterFrame:CGRectMake(249, 45, 71, 90)
                     dismissFrame:CGRectMake(249, 135, 71, 45)];
                @[@"y", @0, @45, @50, @45], @[@"sec", @50, @45, @50, @45], @[@"csc", @100, @45, @50, @45], @[@"cot", @150, @45, @49, @45], @[@"π", @199, @45, @50, @45],
                @[@"Fraction", @0, @90, @50, @45], @[@"log", @50, @90, @50, @45], @[@"ln", @100, @90, @50, @45], @[@"LOGBASE", @150, @90, @49, @45], @[@"∠", @199, @90, @50, @45],
                @[@"Exponent", @0, @135, @50, @45], @[@"Sub", @50, @135, @50, @45], @[@"Sqrt", @100, @135, @50, @45], @[@"Radical", @150, @135, @49, @45], @[@"°", @199, @135, @50, @45],
            ];
            for (NSArray *item in items) {
                NSString *token = item[0];
                UIButton *button = nil;
                if ([token isEqualToString:@"Fraction"]) { button = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)]; self.fractionButton = button; }
                else if ([token isEqualToString:@"Exponent"]) { button = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)]; self.exponentButton = button; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; [button setBackgroundImage:[UIImage imageNamed:@"Keyboard-marine-pressed" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected]; }
                else if ([token isEqualToString:@"Sqrt"]) { button = [self makeButtonWithTitle:nil image:@"Sqrt" action:@selector(squareRootPressed:)]; self.squareRootButton = button; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; UIImage *inv=[UIImage imageNamed:@"Sqrt Inverted" inBundle:bundle compatibleWithTraitCollection:nil]; UIImage *bg=[UIImage imageNamed:@"Keyboard-green-pressed" inBundle:bundle compatibleWithTraitCollection:nil]; [button setImage:inv forState:UIControlStateSelected]; [button setImage:inv forState:UIControlStateHighlighted]; [button setBackgroundImage:bg forState:UIControlStateSelected]; }
                else if ([token isEqualToString:@"Radical"]) { button = [self makeButtonWithTitle:nil image:@"Sqrt with Power" action:@selector(rootWithPowerPressed:)]; self.radicalButton = button; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; UIImage *inv=[UIImage imageNamed:@"Sqrt Power Inverted" inBundle:bundle compatibleWithTraitCollection:nil]; UIImage *bg=[UIImage imageNamed:@"Keyboard-green-pressed" inBundle:bundle compatibleWithTraitCollection:nil]; [button setImage:inv forState:UIControlStateSelected]; [button setImage:inv forState:UIControlStateHighlighted]; [button setBackgroundImage:bg forState:UIControlStateSelected]; [button setBackgroundImage:[UIImage imageNamed:@"num-button-disabled" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateDisabled]; }
                else if ([token isEqualToString:@"LOGBASE"]) { button = [self makeButtonWithTitle:nil image:@"Log with base" action:@selector(logWithBasePressed:)]; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; [button setImage:[UIImage imageNamed:@"Log Inverted" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted]; }
                else if ([token isEqualToString:@"Sub"]) { button = [self makeButtonWithTitle:nil image:@"Subscript" action:@selector(subscriptPressed:)]; NSBundle *bundle = SWIFTPM_MODULE_BUNDLE; [button setImage:[UIImage imageNamed:@"Subscript Inverted" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateHighlighted]; }
                else { button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)]; }
                if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"] || [token isEqualToString:@"Fraction"] || [token isEqualToString:@"Exponent"]) { [self applyStyle:@"marine" toButton:button]; }
                else { [self applyStyle:@"green" toButton:button]; }
                [self addButtonSpec:specs button:button x:[item[1] floatValue] y:[item[2] floatValue] width:[item[3] floatValue] height:[item[4] floatValue]];
                [self applyTypographyForToken:token button:button];
                if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"]) { [variables addObject:button]; }
            }
            UIButton *backspace = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
            UIButton *dismiss = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
            UIButton *enter = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)];
            [self applyStyle:@"control" toButton:backspace];
            [self applyStyle:@"control" toButton:dismiss];
            [self applyStyle:@"control" toButton:enter];
            [self applyTypographyForToken:@"Enter" button:enter];
            [self applyTypographyForToken:@"Dismiss" button:dismiss];
            [self addButtonSpec:specs button:backspace x:249 y:0 width:71 height:45];
            [self addButtonSpec:specs button:enter x:249 y:45 width:71 height:90];
            [self addButtonSpec:specs button:dismiss x:249 y:135 width:71 height:45];
            break;
        }
        case MTKeyboardLayoutLetters: {
            backgroundImageName = @"Letters Keyboard";
            NSArray *items = @[
                @[@"q", @0, @0, @32, @45], @[@"w", @32, @0, @32, @45], @[@"e", @64, @0, @32, @45], @[@"r", @96, @0, @32, @45], @[@"t", @128, @0, @32, @45], @[@"y", @160, @0, @32, @45], @[@"u", @192, @0, @32, @45], @[@"i", @224, @0, @32, @45], @[@"o", @256, @0, @32, @45], @[@"p", @288, @0, @32, @45],
                @[@"a", @16, @45, @32, @45], @[@"s", @48, @45, @32, @45], @[@"d", @80, @45, @32, @45], @[@"f", @112, @45, @32, @45], @[@"g", @144, @45, @31, @45], @[@"h", @175, @45, @32, @45], @[@"j", @207, @45, @32, @45], @[@"k", @239, @45, @32, @45], @[@"l", @271, @45, @32, @45],
                @[@"Shift", @0, @90, @48, @45], @[@"z", @48, @90, @32, @45], @[@"x", @80, @90, @32, @45], @[@"c", @112, @90, @32, @45], @[@"v", @144, @90, @31, @45], @[@"b", @175, @90, @32, @45], @[@"n", @207, @90, @32, @45], @[@"m", @239, @90, @32, @45], @[@"Back", @271, @90, @48, @45],
                @[@"Dismiss", @0, @135, @80, @45], @[@"α", @80, @135, @32, @45], @[@"Δ", @112, @135, @32, @45], @[@"σ", @144, @135, @31, @45], @[@"μ", @175, @135, @32, @45], @[@"λ", @207, @135, @32, @45], @[@"Enter", @239, @135, @81, @45]
            ];
            for (NSArray *item in items) {
                NSString *token = item[0];
                UIButton *button = nil;
                if ([token isEqualToString:@"Shift"]) { button = [self makeButtonWithTitle:nil image:@"Shift" action:@selector(shiftPressed:)]; self.shiftButton = button; }
                else if ([token isEqualToString:@"Back"]) { button = [self makeButtonWithTitle:nil image:@"Backspace Small" action:@selector(backspacePressed:)]; }
                else if ([token isEqualToString:@"Dismiss"]) { button = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)]; }
                else if ([token isEqualToString:@"Enter"]) { button = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)]; }
                else { button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)]; [letters addObject:button]; [variables addObject:button]; }
                if ([token isEqualToString:@"Shift"] || [token isEqualToString:@"Back"] || [token isEqualToString:@"Dismiss"] || [token isEqualToString:@"Enter"]) { [self applyStyle:@"control" toButton:button]; }
                else { [self applyStyle:@"azure" toButton:button]; }
                [self addButtonSpec:specs button:button x:[item[1] floatValue] y:[item[2] floatValue] width:[item[3] floatValue] height:[item[4] floatValue]];
                [self applyTypographyForToken:token button:button];
                if ([token isEqualToString:@"α"]) { self.alphaRho = button; [greekLetters addObject:button]; }
                if ([token isEqualToString:@"Δ"]) { self.deltaOmega = button; [greekLetters addObject:button]; }
                if ([token isEqualToString:@"σ"]) { self.sigmaPhi = button; [greekLetters addObject:button]; }
                if ([token isEqualToString:@"μ"]) { self.muNu = button; [greekLetters addObject:button]; }
                if ([token isEqualToString:@"λ"]) { self.lambdaBeta = button; [greekLetters addObject:button]; }
            }
            break;
        }
    }

    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageName inBundle:bundle compatibleWithTraitCollection:nil]];
    self.backgroundView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundView.frame = self.bounds;
    [self insertSubview:self.backgroundView atIndex:0];

    self.numbers = numbers;
    self.variables = variables;
    self.operators = operators;
    self.relations = relations;
    self.letters = letters;
    self.greekLetters = greekLetters;
    self.layoutButtons = specs;

    NSString* fontName = [self registerAndGetFontName];
    for (UIButton* varButton in self.variables) {
        varButton.titleLabel.font = [UIFont fontWithName:fontName size:varButton.titleLabel.font.pointSize];
    }
    self.isLowerCase = true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.layoutButtons.count == 0) {
        return;
    }
    self.backgroundView.frame = self.bounds;
    CGFloat sx = CGRectGetWidth(self.bounds) / 320.0;
    CGFloat sy = CGRectGetHeight(self.bounds) / 180.0;
    for (NSDictionary *spec in self.layoutButtons) {
        UIButton *button = spec[@"button"];
        CGFloat x = [spec[@"x"] floatValue] * sx;
        CGFloat y = [spec[@"y"] floatValue] * sy;
        CGFloat width = [spec[@"width"] floatValue] * sx;
        CGFloat height = [spec[@"height"] floatValue] * sy;
        button.frame = CGRectMake(x, y, width, height);
    }
    [self addTrailingControlsToSpecs:specs
                   backspaceFrame:CGRectMake(249, 0, 71, 45)
                       enterFrame:CGRectMake(249, 45, 71, 90)
                     dismissFrame:CGRectMake(249, 135, 71, 45)];

- (void)addTrailingControlsToSpecs:(NSMutableArray<NSDictionary *> *)specs
                     backspaceFrame:(CGRect)backspaceFrame
                         enterFrame:(CGRect)enterFrame
                       dismissFrame:(CGRect)dismissFrame
{
    UIButton *backspace = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
    UIButton *dismiss = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
    UIButton *enter = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)];

    [self applyStyle:MTKeyboardStyleControl toButton:backspace];
    [self applyStyle:MTKeyboardStyleControl toButton:dismiss];
    [self applyStyle:MTKeyboardStyleControl toButton:enter];
    [self applyTypographyForToken:@"Enter" button:enter];
    [self applyTypographyForToken:@"Dismiss" button:dismiss];

    [self addButtonSpec:specs button:backspace x:backspaceFrame.origin.x y:backspaceFrame.origin.y width:backspaceFrame.size.width height:backspaceFrame.size.height];
    [self addButtonSpec:specs button:enter x:enterFrame.origin.x y:enterFrame.origin.y width:enterFrame.size.width height:enterFrame.size.height];
    [self addButtonSpec:specs button:dismiss x:dismissFrame.origin.x y:dismissFrame.origin.y width:dismissFrame.size.width height:dismissFrame.size.height];
}

- (void)enterPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"\n"];
}

- (void)backspacePressed:(id)sender
{
    [self playClickForCustomKeyTap];

    [self.textView deleteBackward];
}

- (void)dismissPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView resignFirstResponder];
}

- (IBAction)absValuePressed:(id)sender
{
    [self.textView insertText:@"||"];
}

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

- (void) playClickForCustomKeyTap
{
    [[UIDevice currentDevice] playInputClick];
}

- (void)fractionPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:MTSymbolFractionSlash];
}

- (IBAction)exponentPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"^"];
}

- (IBAction)subscriptPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"_"];
}

- (IBAction)parensPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"()"];
}

- (IBAction)squareRootPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    [self.textView insertText:MTSymbolSquareRoot];
}

- (IBAction)rootWithPowerPressed:(id)sender {
    [self playClickForCustomKeyTap];
    [self.textView insertText:MTSymbolCubeRoot];
}

- (IBAction)logWithBasePressed:(id)sender {
    [self playClickForCustomKeyTap];
    [self.textView insertText:@"log"];
    [self.textView insertText:@"_"];
}

- (IBAction)shiftPressed:(id)sender
{
    // If currently uppercase, shift down
    // else, shift up
    if (_isLowerCase) {
        [self shiftUpKeyboard];
    } else {
        [self shiftDownKeyboard];
    }
}

#pragma mark - Keyboard Context


- (void) shiftDownKeyboard
{
    // Replace button titles to lowercase
    for (UIButton* button in self.letters) {
        NSString* newTitle = [button.titleLabel.text lowercaseString]; // get lowercase version of button title
        [button setTitle:newTitle forState:UIControlStateNormal];
    }
    
    // Replace greek letters
    [_alphaRho setTitle:@"α" forState:UIControlStateNormal];
    [_deltaOmega setTitle:@"Δ" forState:UIControlStateNormal];
    [_sigmaPhi setTitle:@"σ" forState:UIControlStateNormal];
    [_muNu setTitle:@"μ" forState:UIControlStateNormal];
    [_lambdaBeta setTitle:@"λ" forState:UIControlStateNormal];
    
    _isLowerCase = true;
}

- (void) shiftUpKeyboard
{
    // Replace button titles to uppercase
    for (UIButton* button in self.letters) {
        NSString* newTitle = [button.titleLabel.text uppercaseString]; // get uppercase version of button title
        [button setTitle:newTitle forState:UIControlStateNormal];
    }
    
    // Replace greek letters
    [_alphaRho setTitle:@"ρ" forState:UIControlStateNormal];
    [_deltaOmega setTitle:@"ω" forState:UIControlStateNormal];
    [_sigmaPhi setTitle:@"Φ" forState:UIControlStateNormal];
    [_muNu setTitle:@"ν" forState:UIControlStateNormal];
    [_lambdaBeta setTitle:@"β" forState:UIControlStateNormal];
    
    _isLowerCase = false;
}

- (void)setNumbersState:(BOOL)enabled
{
    for (UIButton* button in self.numbers) {
        button.enabled = enabled;
    }
}

- (void) setOperatorState:(BOOL)enabled
{
    for (UIButton* button in self.operators) {
        button.enabled = enabled;
    }
}

- (void)setVariablesState:(BOOL)enabled
{
    for (UIButton* button in self.variables) {
        button.enabled = enabled;
    }
}

- (void)setFractionState:(BOOL)enabled
{
    self.fractionButton.enabled = enabled;
}

- (void) setEqualsState:(BOOL)enabled
{
    self.equalsButton.enabled = enabled;
}

- (void) setExponentState:(BOOL) highlighted
{
    self.exponentButton.selected = highlighted;
}

- (void) setSquareRootState:(BOOL) highlighted
{
    self.squareRootButton.selected = highlighted;
}

- (void) setRadicalState:(BOOL) highlighted
{
    self.radicalButton.selected = highlighted;
}

#pragma mark -

// Prevent touches from being propagated to super view.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
@end

#endif

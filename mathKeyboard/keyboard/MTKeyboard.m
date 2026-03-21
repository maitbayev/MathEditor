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
@property (nonatomic) NSUInteger rowCount;
@property (nonatomic) NSUInteger columnCount;

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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = YES;
    button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    button.layer.cornerRadius = 4.0;
    button.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightRegular];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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

- (void)addButtonSpec:(NSMutableArray<NSDictionary *> *)specs
               button:(UIButton *)button
                  row:(NSUInteger)row
               column:(NSUInteger)column
              colSpan:(NSUInteger)colSpan
{
    [specs addObject:@{@"button": button, @"row": @(row), @"column": @(column), @"colSpan": @(MAX((NSUInteger)1, colSpan))}];
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

    self.rowCount = 4;
    self.columnCount = 6;
    switch (self.layout) {
        case MTKeyboardLayoutNumbers: {
            NSArray *rows = @[
                @[@"1",@"2",@"3",@"4",@"5",@"6"],
                @[@"7",@"8",@"9",@".",@"0",@"="],
                @[@"+",@"-",@"×",@"÷",@"x",@"y"],
            ];
            for (NSUInteger r = 0; r < rows.count; r++) {
                NSArray *row = rows[r];
                for (NSUInteger c = 0; c < row.count; c++) {
                    NSString *title = row[c];
                    UIButton *button = [self makeButtonWithTitle:title image:nil action:@selector(keyPressed:)];
                    [self addButtonSpec:specs button:button row:r column:c colSpan:1];
                    if ([@"0123456789." containsString:title]) { [numbers addObject:button]; }
                    if ([title isEqualToString:@"x"] || [title isEqualToString:@"y"]) { [variables addObject:button]; }
                    if ([@[@"+",@"-",@"×",@"÷"] containsObject:title]) { [operators addObject:button]; }
                    if ([@[@"="] containsObject:title]) { [relations addObject:button]; self.equalsButton = button; }
                }
            }
            self.fractionButton = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)];
            self.exponentButton = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)];
            UIButton *backspace = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
            UIButton *dismiss = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
            UIButton *enter = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)];
            [self addButtonSpec:specs button:self.fractionButton row:3 column:0 colSpan:1];
            [self addButtonSpec:specs button:self.exponentButton row:3 column:1 colSpan:1];
            [self addButtonSpec:specs button:backspace row:3 column:2 colSpan:1];
            [self addButtonSpec:specs button:dismiss row:3 column:3 colSpan:1];
            [self addButtonSpec:specs button:enter row:3 column:4 colSpan:2];
            break;
        }
        case MTKeyboardLayoutOperations: {
            NSArray *rows = @[
                @[@"{",@"}",@"[",@"]",@"(",@")"],
                @[@"<",@">",@"≤",@"≥",@"!",@"%"],
                @[@",",@":",@"∞",@"x",@"y",@"Enter"],
            ];
            for (NSUInteger r = 0; r < rows.count; r++) {
                NSArray *row = rows[r];
                for (NSUInteger c = 0; c < row.count; c++) {
                    NSString *title = row[c];
                    SEL action = [title isEqualToString:@"Enter"] ? @selector(enterPressed:) : @selector(keyPressed:);
                    UIButton *button = [self makeButtonWithTitle:title image:nil action:action];
                    [self addButtonSpec:specs button:button row:r column:c colSpan:1];
                    if ([title isEqualToString:@"x"] || [title isEqualToString:@"y"]) { [variables addObject:button]; }
                    if ([@[@"<",@">",@"≤",@"≥"] containsObject:title]) { [relations addObject:button]; }
                }
            }
            self.fractionButton = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)];
            self.exponentButton = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)];
            UIButton *abs = [self makeButtonWithTitle:@"|.|" image:nil action:@selector(absValuePressed:)];
            UIButton *backspace = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
            UIButton *dismiss = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
            [self addButtonSpec:specs button:abs row:3 column:0 colSpan:1];
            [self addButtonSpec:specs button:self.fractionButton row:3 column:1 colSpan:1];
            [self addButtonSpec:specs button:self.exponentButton row:3 column:2 colSpan:1];
            [self addButtonSpec:specs button:backspace row:3 column:3 colSpan:1];
            [self addButtonSpec:specs button:dismiss row:3 column:4 colSpan:2];
            break;
        }
        case MTKeyboardLayoutFunctions: {
            NSArray *rows = @[
                @[@"log",@"ln",@"sin",@"cos",@"tan",@"π"],
                @[@"sec",@"csc",@"cot",@"θ",@"∠",@"°"],
                @[@"(",@")",@"x",@"y",@"Fraction",@"Exponent"],
                @[@"Sqrt",@"Radical",@"log_",@"Sub",@"Back",@"Dismiss"],
            ];
            for (NSUInteger r = 0; r < rows.count; r++) {
                NSArray *row = rows[r];
                for (NSUInteger c = 0; c < row.count; c++) {
                    NSString *token = row[c];
                    UIButton *button = nil;
                    if ([token isEqualToString:@"Fraction"]) {
                        button = [self makeButtonWithTitle:nil image:@"Fraction" action:@selector(fractionPressed:)];
                        self.fractionButton = button;
                    } else if ([token isEqualToString:@"Exponent"]) {
                        button = [self makeButtonWithTitle:nil image:@"Exponent" action:@selector(exponentPressed:)];
                        self.exponentButton = button;
                    } else if ([token isEqualToString:@"Sqrt"]) {
                        button = [self makeButtonWithTitle:nil image:@"Sqrt" action:@selector(squareRootPressed:)];
                        self.squareRootButton = button;
                    } else if ([token isEqualToString:@"Radical"]) {
                        button = [self makeButtonWithTitle:nil image:@"Sqrt with Power" action:@selector(rootWithPowerPressed:)];
                        self.radicalButton = button;
                    } else if ([token isEqualToString:@"log_"]) {
                        button = [self makeButtonWithTitle:nil image:@"Log with base" action:@selector(logWithBasePressed:)];
                    } else if ([token isEqualToString:@"Sub"]) {
                        button = [self makeButtonWithTitle:nil image:@"Subscript" action:@selector(subscriptPressed:)];
                    } else if ([token isEqualToString:@"Back"]) {
                        button = [self makeButtonWithTitle:nil image:@"Backspace" action:@selector(backspacePressed:)];
                    } else if ([token isEqualToString:@"Dismiss"]) {
                        button = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
                    } else {
                        button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)];
                        if ([token isEqualToString:@"x"] || [token isEqualToString:@"y"]) { [variables addObject:button]; }
                    }
                    [self addButtonSpec:specs button:button row:r column:c colSpan:1];
                }
            }
            break;
        }
        case MTKeyboardLayoutLetters: {
            self.rowCount = 6;
            NSArray *rows = @[
                @[@"q",@"w",@"e",@"r",@"t",@"y"],
                @[@"u",@"i",@"o",@"p",@"a",@"s"],
                @[@"d",@"f",@"g",@"h",@"j",@"k"],
                @[@"l",@"z",@"x",@"c",@"v",@"b"],
                @[@"Shift",@"n",@"m",@"α",@"Δ",@"Back"],
                @[@"σ",@"μ",@"λ",@"Dismiss",@"Enter",@" "],
            ];
            for (NSUInteger r = 0; r < rows.count; r++) {
                NSArray *row = rows[r];
                for (NSUInteger c = 0; c < row.count; c++) {
                    NSString *token = row[c];
                    if ([token isEqualToString:@" "]) { continue; }
                    UIButton *button = nil;
                    if ([token isEqualToString:@"Shift"]) {
                        button = [self makeButtonWithTitle:nil image:@"Shift" action:@selector(shiftPressed:)];
                        self.shiftButton = button;
                    } else if ([token isEqualToString:@"Back"]) {
                        button = [self makeButtonWithTitle:nil image:@"Backspace Small" action:@selector(backspacePressed:)];
                    } else if ([token isEqualToString:@"Dismiss"]) {
                        button = [self makeButtonWithTitle:nil image:@"Keyboard Down" action:@selector(dismissPressed:)];
                    } else if ([token isEqualToString:@"Enter"]) {
                        button = [self makeButtonWithTitle:@"Enter" image:nil action:@selector(enterPressed:)];
                    } else {
                        button = [self makeButtonWithTitle:token image:nil action:@selector(keyPressed:)];
                        [letters addObject:button];
                        [variables addObject:button];
                    }
                    [self addButtonSpec:specs button:button row:r column:c colSpan:1];
                    if ([token isEqualToString:@"α"]) { self.alphaRho = button; [greekLetters addObject:button]; }
                    if ([token isEqualToString:@"Δ"]) { self.deltaOmega = button; [greekLetters addObject:button]; }
                    if ([token isEqualToString:@"σ"]) { self.sigmaPhi = button; [greekLetters addObject:button]; }
                    if ([token isEqualToString:@"μ"]) { self.muNu = button; [greekLetters addObject:button]; }
                    if ([token isEqualToString:@"λ"]) { self.lambdaBeta = button; [greekLetters addObject:button]; }
                }
            }
            break;
        }
    }

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
    if (self.layoutButtons.count == 0 || self.rowCount == 0 || self.columnCount == 0) {
        return;
    }

    CGFloat spacing = 4.0;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat cellWidth = (width - ((self.columnCount + 1) * spacing)) / self.columnCount;
    CGFloat cellHeight = (height - ((self.rowCount + 1) * spacing)) / self.rowCount;
    for (NSDictionary *spec in self.layoutButtons) {
        UIButton *button = spec[@"button"];
        NSUInteger row = [spec[@"row"] unsignedIntegerValue];
        NSUInteger col = [spec[@"column"] unsignedIntegerValue];
        NSUInteger colSpan = [spec[@"colSpan"] unsignedIntegerValue];
        CGFloat x = spacing + (col * (cellWidth + spacing));
        CGFloat y = spacing + (row * (cellHeight + spacing));
        CGFloat buttonWidth = (cellWidth * colSpan) + (spacing * (colSpan - 1));
        button.frame = CGRectMake(x, y, buttonWidth, cellHeight);
    }
}


- (void)keyPressed:(id)sender
{
    [self playClickForCustomKeyTap];
    
    UIButton *button = sender;
    NSString* str = button.currentTitle;
    [self.textView insertText:str];
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

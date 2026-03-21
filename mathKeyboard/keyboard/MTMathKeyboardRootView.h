//
//  MCMathKeyboardRootView.h
//  MathChat
//
//  Created by MARIO ANDHIKA on 7/16/15.
//  Copyright (c) 2015 MathChat, Inc.
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#import "MTKeyboard.h"
#import "MTEditableMathLabel.h"

@interface MTMathKeyboardRootView : UIView<MTMathKeyboard>

- (IBAction)switchTabs:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *numbersTab;
@property (strong, nonatomic) IBOutlet UIButton *lettersTab;
@property (strong, nonatomic) IBOutlet UIButton *functionsTab;
@property (strong, nonatomic) IBOutlet UIButton *operationsTab;

- (void) switchToDefaultTab;

+ (MTMathKeyboardRootView *)sharedInstance;

/// The keyboard resources bundle.
+ (NSBundle *)getMathKeyboardResourcesBundle;

#pragma mark - MTMathKeyboardTraits

@property (nonatomic) BOOL equalsAllowed;
@property (nonatomic) BOOL fractionsAllowed;
@property (nonatomic) BOOL variablesAllowed;
@property (nonatomic) BOOL numbersAllowed;
@property (nonatomic) BOOL operatorsAllowed;
@property (nonatomic) BOOL exponentHighlighted;
@property (nonatomic) BOOL squareRootHighlighted;
@property (nonatomic) BOOL radicalHighlighted;

@end

#endif

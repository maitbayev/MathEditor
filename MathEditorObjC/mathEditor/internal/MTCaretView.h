//
//  CaretView.h
//
//  Created by Kostub Deshmukh on 9/2/13.
//  Copyright (C) 2013 MathChat
//   
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#import "MTConfig.h"

@class MTEditableMathLabel;

@interface MTCaretView : MTView

@property (nonatomic) MTColor* caretColor;

- (id) initWithEditor:(MTEditableMathLabel*)label;

- (void)delayBlink;

- (void) setPosition:(CGPoint) position;

- (void) showHandle:(BOOL) show;

- (void) setFontSize:(CGFloat) fontSize;

@end


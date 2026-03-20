//
//  MTView+FirstResponder.m
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import "MTConfig.h"
#import "MTView+FirstResponder.h"

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_OSX

@implementation NSView (FirstResponder)

- (BOOL)isFirstResponder
{
    return self.window.firstResponder == self;
}

@end

#endif

NS_ASSUME_NONNULL_END

//
//  MTView+HitTest.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 21/03/2026.
//

#if TARGET_OS_OSX

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (HitTest)

- (NSView *)hitTestOutsideBounds:(NSPoint)point;

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_OSX

//
//  MTView+FirstResponder.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import "MTConfig.h"

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_OSX

@interface NSView (FirstResponder)

@property (nonatomic, readonly) BOOL isFirstResponder;

@end

#endif // TARGET_OS_OSX

NS_ASSUME_NONNULL_END

//
//  MTKeyInput.h
//
//  Created for cross-platform key input abstraction.
//

#import "MTConfig.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#define MTKeyInput UIKeyInput

#else

@protocol MTKeyInput <NSObject>

- (void)insertText:(NSString *)text;
- (void)deleteBackward;
- (BOOL)hasText;

@end

#endif

//
//  MTCancelView.m
//
//  Created for the editable label clear affordance.
//

#import "MTCancelView.h"
#import "MTTapGestureRecognizer.h"
#import "MTView/MTView+AutoLayout.h"

@interface MTCancelView ()

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImageView *imageView;
#else
@property (nonatomic, strong) NSImageView *imageView;
#endif

@end

@implementation MTCancelView

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
#if TARGET_OS_IPHONE
        UIImage *image = [UIImage systemImageNamed:@"xmark.circle"];
        if (image != nil) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = [MTColor secondaryLabelColor];
#else
        NSImage *image = [NSImage imageWithSystemSymbolName:@"xmark.circle" accessibilityDescription:nil];
        _imageView = [[NSImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = image;
        _imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        _imageView.contentTintColor = [MTColor secondaryLabelColor];
#endif
        [self addSubview:_imageView];
        [_imageView pinToSuperview];

#if TARGET_OS_IPHONE
        self.userInteractionEnabled = YES;
#endif
        MTTapGestureRecognizer *tapRecognizer = [[MTTapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:tapRecognizer];
        self.hidden = YES;
    }
    return self;
}

@end

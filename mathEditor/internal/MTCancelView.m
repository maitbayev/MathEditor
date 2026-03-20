//
//  MTCancelView.m
//
//  Created for the editable label clear affordance.
//

#import "MTCancelView.h"
#import "MTTapGestureRecognizer.h"

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
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = [MTColor secondaryLabelColor];
#else
        NSImage *image = [NSImage imageWithSystemSymbolName:@"xmark.circle" accessibilityDescription:nil];
        _imageView = [[NSImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = image;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        _imageView.contentTintColor = [MTColor secondaryLabelColor];
#endif
        [self addSubview:_imageView];

        [NSLayoutConstraint activateConstraints:@[
            [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];

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

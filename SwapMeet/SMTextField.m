//
//  SMTextField.m
//  SwapMeet
//
//  Created by Kevin Pham on 11/21/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMTextField.h"

@implementation SMTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        [self applyStyle];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self applyStyle];
}

- (void)applyStyle
{
    [self setBorderStyle:UITextBorderStyleNone];
    
    [self setFont: [UIFont systemFontOfSize:17]];
    
    if ([self respondsToSelector:@selector(setTintColor:)])
        [self setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)setNeedsAppearance:(id)sender
{
    MHTextField *textField = (MHTextField*)sender;
    
    if (![textField isEnabled]) {
        [self setBackgroundColor:[UIColor lightGrayColor]];
    }
    else if (![textField isValid]) {
        [self setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.5]];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 10, 5);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 10, 5);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
    
    [layer setBorderWidth: 0.8];
    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
    
    [layer setCornerRadius:3.0];
    [layer setShadowOpacity:1.0];
    [layer setShadowColor:[UIColor redColor].CGColor];
    [layer setShadowOffset:CGSizeMake(1.0, 1.0)];
}

//- (void) drawPlaceholderInRect:(CGRect)rect {
//#if __IPHONE_OS_VERSION_MIN_REQUIRED == __IPHONE_7_0
//    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : [UIColor lightGrayColor]};
//    [self.placeholder drawInRect:CGRectInset(rect, 5, 5) withAttributes:attributes];
//#endif
//}

@end

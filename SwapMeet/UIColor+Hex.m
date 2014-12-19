//
//  UIColor+Hex.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/19/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

// Format: 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

// Format: @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    UInt32 xx = (UInt32)x;
    return [UIColor colorWithHex:xx];
}

@end
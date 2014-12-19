//
//  SMSearchDelegate.h
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMSearchDelegate <NSObject>

- (void)searchFilterConfirmed:(NSString *)consoleFilter;

@end
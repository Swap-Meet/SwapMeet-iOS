//
//  SMNetworking.h
//  SwapMeet
//
//  Created by Alex G on 17.11.14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMNetworkController.h"

extern NSString * const kSMDefaultsKeyToken;

@interface SMNetworking : SMNetworkController

+ (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                              andPassword:(NSString *)password
                                zipNumber:(NSNumber *)zip
                               completion:(void(^)(BOOL successful, NSString *errorString))completion;

+ (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                             andPassword:(NSString *)password
                              completion:(void(^)(BOOL successful, NSString *errorString))completion;

+ (NSURLSessionDataTask *)gamesContaining:(NSString *)query
                              forPlatform:(NSString *)platform
                                 atOffset:(NSInteger)offset
                               completion:(void(^)(NSArray *objects, NSInteger itemsLeft, NSString *errorString))completion;

+ (void)invalidateToken;

@end
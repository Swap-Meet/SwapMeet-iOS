//
//  SMSearchFilterViewController.h
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSearchDelegate.h"

@interface SMSearchFilterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (assign, nonatomic) id<SMSearchDelegate> delegate;

@end
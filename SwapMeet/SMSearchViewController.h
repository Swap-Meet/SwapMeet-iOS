//
//  SMSearchViewController.h
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSearchDelegate.h"

@interface SMSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SMSearchDelegate>

@property (strong, nonatomic) NSMutableArray *gamesArray;
@property (nonatomic) NSInteger targetTab;

@end
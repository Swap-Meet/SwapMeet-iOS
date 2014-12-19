//
//  SwapTableViewCell.h
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwapTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformLabel;
@property (weak, nonatomic) IBOutlet UILabel *tradeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
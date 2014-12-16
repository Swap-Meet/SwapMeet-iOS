//
//  SMGameDetailsViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/12/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMGameDetailsViewController.h"

@interface SMGameDetailsViewController ()

@property (strong, nonatomic) NSString *gameTitle;
@property (strong, nonatomic) NSString *gamePlatform;
@property (strong, nonatomic) NSString *gameCondition;
@property (strong, nonatomic) NSString *gameImageURL;
@property (strong, nonatomic) NSString *userName;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *conditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation SMGameDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gameTitle = [self.selectedGame objectForKey:@"title"];
    self.gamePlatform = [self.selectedGame objectForKey:@"platform"];
    self.gameImageURL = [self.selectedGame objectForKey:@"image_urls"];
    
    self.titleLabel.text = self.gameTitle;
    self.userNameLabel.text = self.userName;
    
    //NSLog(@"%@", self.selectedGame);
    //NSLog(@"%@", self.gameTitle);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
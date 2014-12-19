//
//  SMSwapBoxViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSwapBoxViewController.h"

@interface SMSwapBoxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SMSwapBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TABLE VIEW DATA SOURCE

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (IBAction)segmentChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSLog(@"Swap Ins");
    } if (self.segmentedControl.selectedSegmentIndex == 1) {
        NSLog(@"Swap Outs");
    }
}


#pragma mark - TABLE VIEW DELEGATE

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    
}

//- (IBAction)changeSegment:(id)sender {
//    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        NSLog(@"My Games");
//        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
//        self.navigationItem.rightBarButtonItem = self.addGameButton;
//    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
//        NSLog(@"Favorites");
//        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
//        self.navigationItem.rightBarButtonItem = nil;
//    }
//    
//    self.fetchController.delegate = self;
//    [self.tableView reloadData];
//}

#pragma mark - NAVIGATION

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
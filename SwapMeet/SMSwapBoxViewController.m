//
//  SMSwapBoxViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSwapBoxViewController.h"
#import "SMNetworking.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SMSwapBoxViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSMutableArray *swapIns;
@property (strong, nonatomic) NSMutableArray *swapOuts;
@property (nonatomic) NSURLSessionDataTask *requestTask;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SMSwapBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    
    [self fetchIncomingRequests];
    
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
    NSInteger rowCount;
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        rowCount = self.swapIns.count;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        rowCount = self.swapOuts.count;
    }
    
    return rowCount;
}

- (IBAction)segmentChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self fetchIncomingRequests];
    } if (self.segmentedControl.selectedSegmentIndex == 1) {
        NSLog(@"Swap Outs");
        [_requestTask cancel];
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _requestTask = [SMNetworking outgoingRequestsWithCompletion:^(NSArray *objects, NSString *errorString) {
            [hud hide:YES];
            if (errorString) {
                NSLog(@"%@", errorString);
                return;
            }
            
            [_swapOuts addObjectsFromArray:objects];
            NSLog(@"%@", objects);
            [_tableView reloadData];
        }];
    }
}

- (void)fetchIncomingRequests {
    NSLog(@"Swap Ins");
    [_requestTask cancel];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _requestTask = [SMNetworking incomingRequestsWithCompletion:^(NSArray *objects, NSString *errorString) {
        [hud hide:YES];
        if (errorString) {
            NSLog(@"%@", errorString);
            return;
        }
        
        [_swapIns addObjectsFromArray:objects];
        NSLog(@"%@", objects);
        [_tableView reloadData];
    }];
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
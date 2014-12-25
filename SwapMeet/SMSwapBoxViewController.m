//
//  SMSwapBoxViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSwapBoxViewController.h"
#import "SMNetworking.h"
#import "SwapTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+Hex.h"

@interface SMSwapBoxViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSMutableArray *swapIns;
@property (strong, nonatomic) NSMutableArray *swapOuts;
@property (nonatomic) NSURLSessionDataTask *requestTask;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@end

@implementation SMSwapBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupTableView];
    
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
    SwapTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SWAP_CELL"];
    
    NSDictionary *tradeDict;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        tradeDict = _swapIns[indexPath.row];
        cell.tradeLabel.text = @"Trade FROM:";
    } else if (self.segmentedControl.selectedSegmentIndex ==1) {
        tradeDict = _swapOuts[indexPath.row];
        cell.tradeLabel.text = @"Trade TO:";
    }
    
    NSDictionary *gameInfo = [tradeDict objectForKey:@"gameInfo"];
    
    cell.titleLabel.text = gameInfo[@"title"];
    cell.platformLabel.text = gameInfo[@"platform"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount;
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        rowCount = [self.swapIns count];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        rowCount = [self.swapOuts count];
    }
    
    return rowCount;
}

- (IBAction)segmentChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self fetchIncomingRequests];
    } if (self.segmentedControl.selectedSegmentIndex == 1) {
        NSLog(@"Swap Outs");
        [_requestTask cancel];
        _swapOuts = [NSMutableArray array];
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
    _swapIns = [NSMutableArray array];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _requestTask = [SMNetworking incomingRequestsWithCompletion:^(NSArray *objects, NSString *errorString) {
        [hud hide:YES];
        if (errorString) {
            NSLog(@"%@", errorString);
            return;
        }
        
        [_swapIns addObjectsFromArray:objects];
        NSLog(@"%@", objects);
        NSLog(@"%lu", (unsigned long)self.swapIns.count);
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

#pragma mark - SETUP

- (void)setupNavigationBar {
    self.navigationBar.barTintColor = [UIColor colorWithHexString:@"1B465A"];
    self.statusBarView.backgroundColor = [UIColor colorWithHexString:@"1B465A"];
    self.segmentedControl.tintColor = [UIColor colorWithHexString:@"009999"];
    //self.segmentedControl.tintColor = [UIColor whiteColor];
    //self.segmentedControl.backgroundColor = [UIColor whiteColor];
    
    UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    UISegmentedControl *segmentedControlCode = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    navTitleView = segmentedControlCode;
    self.navigationItem.titleView = navTitleView;

//    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//    [navView addSubview:self.segmentedControl];
//    self.navigationItem.titleView = navView;
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//    imageView.image = image;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.navigationItem.titleView = imageView;
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"SwapTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SWAP_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}

@end
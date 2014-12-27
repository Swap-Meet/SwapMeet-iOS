//
//  SMSearchFilterViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSearchFilterViewController.h"
#import "UIColor+Hex.h"

@interface SMSearchFilterViewController ()

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSString *selectedConsoleSearch;

@property (weak, nonatomic) IBOutlet UINavigationBar *searchFilterNavigationBar;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UIPickerView *consolePickerView;

@end

@implementation SMSearchFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    self.consoles = [[NSArray alloc] initWithObjects:@"", @"Atari", @"Board/Card Games", @"Dreamcast", @"GameCube", @"Game Boy", @"Game Boy Advance", @"Genesis", @"Other", @"Nintendo", @"Nintendo DS", @"Nintendo 3DS", @"PC", @"PlayStation", @"PlayStation 2", @"PlayStation 3", @"PlayStation 4", @"PlayStation Vita", @"PSP", @"Saturn", @"Super Nintendo", @"Wii U", @"Xbox", @"Xbox 360", @"Xbox One", nil];
    
    self.consolePickerView.dataSource = self;
    self.consolePickerView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PICKER VIEW DATA SOURCE

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.consoles.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.consoles objectAtIndex:row];
}

#pragma mark - PICKER VIEW DELEGATE

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedConsoleSearch = [self.consoles objectAtIndex:row];
}

#pragma mark - NAVIGATION

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    if (!self.selectedConsoleSearch) {
        self.selectedConsoleSearch = [self.consoles objectAtIndex:0];
    }
    
    [self.delegate searchFilterConfirmed:self.selectedConsoleSearch];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SETUP

- (void)setupNavigationBar {
    self.searchFilterNavigationBar.barTintColor = [UIColor colorWithHexString:@"1B465A"];
    self.statusBarView.backgroundColor = [UIColor colorWithHexString:@"1B465A"];
    
    //    // this will appear as the title in the navigation bar
    //    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    //    label.backgroundColor = [UIColor clearColor];
    //    label.font = [UIFont boldSystemFontOfSize:20.0];
    //    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    //    label.textAlignment = NSTextAlignmentCenter;
    //    // ^-Use UITextAlignmentCenter for older SDKs.
    //    label.textColor = [UIColor yellowColor]; // change this color
    //    self.navigationItem.titleView = label;
    //    label.text = NSLocalizedString(@"PageThreeTitle", @"");
    //    [label sizeToFit];
}

@end
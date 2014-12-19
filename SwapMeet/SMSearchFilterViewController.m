//
//  SMSearchFilterViewController.m
//  SwapMeet
//
//  Created by Kevin Pham on 12/18/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMSearchFilterViewController.h"

@interface SMSearchFilterViewController ()

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSString *selectedConsoleSearch;

@property (weak, nonatomic) IBOutlet UIPickerView *consolePickerView;

@end

@implementation SMSearchFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    NSLog(@"%@", self.selectedConsoleSearch);
    [self.delegate searchFilterConfirmed:self.selectedConsoleSearch];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
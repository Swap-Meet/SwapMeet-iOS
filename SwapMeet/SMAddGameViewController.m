//
//  SMAddGameViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMAddGameViewController.h"
#import "Game.h"
#import "SMNetworking.h"
#import "CLUploader+SwapMeet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+SwapMeet.h"
#import <MBProgressHUD/MBProgressHUD.h>

#pragma mark - Properties

@interface SMAddGameViewController () <UITextFieldDelegate> {
    MBProgressHUD *hud;
    NSMutableArray *fileURLs;
}

@property (strong, nonatomic) NSArray *consoles;
@property (strong, nonatomic) NSArray *conditions;
@property (strong, nonatomic) NSString *console;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSMutableArray *photos;

@property (nonatomic) NSURLSessionDataTask *dataTask;
@property NSUInteger imageUploadsLeft;
@property NSMutableArray *remoteURLsArray;

@end

@implementation SMAddGameViewController

#pragma mark - Private Methods

- (void)uploadNewGame {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Adding game";
    __block NSMutableDictionary *gameDict = [NSMutableDictionary dictionaryWithDictionary:@{@"title": self.titleTextView.text, @"platform": self.console, @"condition": self.condition, @"image_urls": _remoteURLsArray}];
    _dataTask = [SMNetworking addNewGame:gameDict completion:^(NSString *gameID, NSString *errorString) {
        [hud hide:YES];
        self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
        if (errorString) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        gameDict[@"id"] = gameID;
        NSString *imagePath = [[fileURLs firstObject] lastPathComponent];
        if (imagePath) {
            gameDict[@"imagePath"] = imagePath;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ADDED" object:self userInfo:gameDict];
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.consolePickerView.delegate = self;
    self.consolePickerView.dataSource = self;
    self.consoles = [[NSArray alloc] initWithObjects:@"Xbox One", @"PS4", @"Xbox 360", @"PS3", @"Wii", nil];
    self.conditions = [[NSArray alloc] initWithObjects:@"Mint", @"Newish", @"Used", @"Still Works...", nil];
    self.photos = [NSMutableArray array];
    self.imageView1.userInteractionEnabled = YES;
    
    _remoteURLsArray = [NSMutableArray array];
    
    [self addTouchGestures];
    
    _titleTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.consoles objectAtIndex:row];
    } else if (component == 1) {
        return [self.conditions objectAtIndex:row];
    } else {
        return @"ERROR";
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.consoles count];
    } else if (component == 1) {
        return [self.conditions count];
    } else {
        return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.console = [self.consoles objectAtIndex:row];
    } else if (component == 1) {
        self.condition = [self.conditions objectAtIndex:row];
    }
}

#pragma mark - UIButton IBActions

- (IBAction)submitButtonClicked:(id)sender {
    if (![self.titleTextView.text isEqual: @""]) {
        if (!self.console) {
            self.console = [self.consoles firstObject];
        }
        if (!self.condition) {
            self.condition = [self.conditions firstObject];
        }
        
        if (self.imageView1.image) {
            [self generateThumbnail:self.imageView1.image];
        }
        
        self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
        
        // Save images to disc
        fileURLs = [NSMutableArray array];
        NSURL *tmp = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] isDirectory:YES];
        for (UIImage *image in self.photos) {
            NSString *tempFileName = [[NSUUID UUID] UUIDString];
            NSURL *tempFileURL = [tmp URLByAppendingPathComponent:tempFileName];
            if ([UIImageJPEGRepresentation([image thumbnailImage], 0.8) writeToURL:tempFileURL atomically:YES]) {
                [fileURLs addObject:[tempFileURL path]];
            }
        }
        
        // Upload images
        self.imageUploadsLeft = [fileURLs count];
        if (self.imageUploadsLeft > 0) {
            for (NSString *pathString in fileURLs) {
                CLUploader *uploader = [CLUploader uploaderWithDelegate:nil];
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                hud.labelText = @"Uploading image";
                hud.progress = 0.01;
                
                [uploader upload:pathString options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
                    NSString *remoteURL = successResult[@"secure_url"];
                    if (remoteURL) {
                        [_remoteURLsArray addObject:remoteURL];
                    }
                    
                    self.imageUploadsLeft--;
                    if (_imageUploadsLeft == 0) {
                        // Upload the actual game object
                        [hud hide:YES];
                        [self uploadNewGame];
                    }
                } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
                    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
                    NSLog(@"PROGRESS: %@", @(progress));
                    hud.progress = progress;
                }];
            }
        } else {
            [self uploadNewGame];
        }
        
    } else {
        [self noTitleAlertController];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [_dataTask cancel];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)addPhotosButtonClicked:(id)sender {
    if (self.imageView1.image) {
        [self maxImagesReached];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:true completion:nil];
    }
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self.photos addObject:image];
    self.imageView1.image = image;
    [picker dismissViewControllerAnimated:true completion:^{
        //[self addTouchGestures];
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (newImage.imageOrientation == UIImageOrientationUp) {
        [self.photos insertObject:newImage atIndex:[self.photos count]];
        [picker dismissViewControllerAnimated:true completion:nil];
        self.imageView1.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        UIImage *fixedImage = [newImage fixRotation];
        [self.photos insertObject:fixedImage atIndex:[self.photos count]];
        [picker dismissViewControllerAnimated:true completion:nil];
        self.imageView1.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - ImageView and Tap Gesture Methods

- (void)addTouchGestures {
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(image1Tapped:)];
    [self.imageView1 addGestureRecognizer:touch];
}

- (void) image1Tapped:(UITapGestureRecognizer *) recognizer {
    if (self.imageView1.image) {
        NSLog(@"Image Tapped");
        [self addSelectedImageAlert:self.imageView1];
    }
}

#pragma mark - Alert Controller Methods

- (void)addSelectedImageAlert: (UIImageView *) imageView {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Delete This Photo?" message: nil preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSUInteger index = [self.photos indexOfObject:imageView.image];
        if (index != NSNotFound) {
            [self.photos removeObjectAtIndex:index];
            self.imageView1.image = nil;
        }
        
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)maxImagesReached {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"Too Many Photos" message:@"Sorry, You Can Only Add 1 Photo" preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *alertAction = [[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }] init];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)noTitleAlertController {
    UIAlertController *alertController = [[UIAlertController alertControllerWithTitle:@"No Title!" message:@"You need at least a game title to continue" preferredStyle:UIAlertControllerStyleAlert] init];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction: action];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Generate Thumbnail Method

- (UIImage *) generateThumbnail:(UIImage *) image {
    UIGraphicsBeginImageContext(CGSizeMake(75, 75));
    [image drawInRect:CGRectMake(0, 0, 75, 75)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    return thumbnail;
}

@end
//
//  SMProfileViewController.m
//  SwapMeet
//
//  Created by Reid Weber on 11/17/14.
//  Copyright (c) 2014 SwapMeet. All rights reserved.
//

#import "SMProfileViewController.h"
#import "SMAddGameViewController.h"
#import "CoreDataController.h"
#import "SearchTableViewCell.h"
#import "SMNetworking.h"
#import "AppDelegate.h"
#import "CLUploader+SwapMeet.h"
#import "UIImage+SwapMeet.h"
#import <MBProgressHUD/MBProgressHUD.h>

NSString * const kSMDefaultsKeyEmail = @"email";
NSString * const kSMDefaultsKeyScreenName = @"screename";
NSString * const kSMDefaultsKeyZipCode = @"zipcode";
NSString * const kSMDefaultsKeyAvatarURL = @"avatar";

@interface SMProfileViewController () {
    MBProgressHUD *hud;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) UIBarButtonItem *addGameButton;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) UIImage *avatarImage;

@end

@implementation SMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:@"ADDED_FAVORITE" object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GAME_CELL"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:touch];
    self.imageView.userInteractionEnabled = true;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    
    NSString *zipCheck = self.zipCode;
    //NSLog(@"%@", zip);
    
    if (!zipCheck) {
        NSLog(@"Local variables not stored");
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyEmail];
        self.screenName = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyScreenName];
        self.zipCode = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyZipCode];
        self.avatarURL = [[NSUserDefaults standardUserDefaults] objectForKey:kSMDefaultsKeyAvatarURL];
        self.emailTextField.text = self.email;
        self.screenNameTextField.text = self.screenName;
        self.zipCodeTextField.text = self.zipCode;
    } else {
        NSLog(@"Zip Check works");
        self.emailTextField.text = self.email;
        self.screenNameTextField.text = self.screenName;
        self.zipCodeTextField.text = self.zipCode;
    }

    [self checkForAvatarImage];
    
    self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
    self.fetchController.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TABLE VIEW DATA SOURCE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchController.fetchedObjects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GAME_CELL" forIndexPath:indexPath];
    Game *selectedGame = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = selectedGame.title;
    cell.platformName.text = selectedGame.platform;
    cell.conditionLabel.text = selectedGame.condition;
    cell.conditionContainerView.backgroundColor = [cell getConditionColor:selectedGame.condition];
    
    NSString *imagePath = selectedGame.imagePath;
    if (imagePath) {
        NSString *imageFullPath = [[[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] isDirectory:YES] URLByAppendingPathComponent:imagePath] path];
        UIImage *image = [UIImage imageWithContentsOfFile:imageFullPath];
        cell.thumbnailImageView.image = image;
    } else {
        cell.thumbnailImageView.image = nil;
    }
    
    return cell;
}

#pragma mark - TABLE VIEW DELEGATE

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.fetchController != nil) {
            __block Game *game = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
            if (!game)
                return;
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if (_segmentedControl.selectedSegmentIndex == 0) {
                [SMNetworking deleteUserGameWithID:game.gameID completion:^(BOOL success, NSString *errorString) {
                    [hud hide:YES];
                    if (success) {
                        [[CoreDataController controller] deleteGame:game];
                        [[CoreDataController controller] saveContext];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Deletion failed" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }];
            } else {
                [SMNetworking removeGameFromFavoritesWithID:game.gameID completion:^(BOOL success, NSString *errorString) {
                    [hud hide:YES];
                    if (success || [errorString isEqualToString:@"Game not found in user's list"]) {
                        [[CoreDataController controller] deleteGame:game];
                        [[CoreDataController controller] saveContext];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Deletion failed" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }];
            }
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - FETCHED RESULTS CONTROLLER DELEGATE

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case 1:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 2:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 3:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 4:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}


- (IBAction)changeSegment:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        NSLog(@"My Games");
        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        NSLog(@"Favorites");
        self.fetchController = [[CoreDataController controller] fetchUserGames:self.segmentedControl.selectedSegmentIndex];
    }
    
    self.fetchController.delegate = self;
    [self.tableView reloadData];
}

- (IBAction)logoutButton:(id)sender {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SMNetworking invalidateToken];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyScreenName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyZipCode];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSMDefaultsKeyAvatarURL];
        self.email = nil;
        self.screenName = nil;
        self.zipCode = nil;
        self.avatarURL = nil;
        self.avatarImage = nil;
        self.imageView.image = nil;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
        [tabBarController setSelectedIndex:0];
    }];
    
    [logoutAlert addAction:cancelButton];
    [logoutAlert addAction:logoutAction];
    [self presentViewController:logoutAlert animated:true completion:nil];
}

- (void) imageTapped:(UITapGestureRecognizer *) gesture {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.avatarImage = [image fixRotation];
    self.imageView.image = self.avatarImage;
    NSLog(@"imagepicker set");
    
    [self generateThumbnail:self.imageView.image];
    
    // Save avatar image to disk
    NSString *fileURL;
    NSURL *temp = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject] isDirectory:true];
    NSString *tempFileName = [[NSUUID UUID] UUIDString];
    NSURL *tempFileURL = [temp URLByAppendingPathComponent:tempFileName];
    if ([UIImageJPEGRepresentation([image thumbnailImage], 0.8) writeToURL:tempFileURL atomically:true]) {
        fileURL = [tempFileURL path];
    }
    
    // Upload images
    CLUploader *uploader = [CLUploader uploaderWithDelegate:nil];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Uploading image";
    hud.progress = 0.01;
            
    [uploader upload:fileURL options:@{} withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context) {
        NSString *remoteURL = successResult[@"secure_url"];
        [[NSUserDefaults standardUserDefaults] setObject:remoteURL forKey:kSMDefaultsKeyAvatarURL];
        [SMNetworking setAvatarURLString:remoteURL completion:^(BOOL successful, NSString *errorString) {
            if (successful == YES) {
                NSLog(@"Avatar URL stored on server.");
            } else {
                NSLog(@"Avatar URL not stored.");
            }
        }];
        
    } andProgress:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite, id context) {
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        NSLog(@"PROGRESS: %@", @(progress));
        hud.progress = progress;
        [hud hide:true];
    }];
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (UIImage *) generateThumbnail:(UIImage *) image {
    UIGraphicsBeginImageContext(CGSizeMake(75, 75));
    [image drawInRect:CGRectMake(0, 0, 75, 75)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    return thumbnail;
}

- (void)checkForAvatarImage {
    if (!self.avatarImage) {
        NSLog(@"Avatar image does not exist.");
        if (!self.avatarURL) {
            NSLog(@"No avatar URL saved.");
        } else {
            NSLog(@"Downloading image from saved URL in user defaults.");
            NSString *url = self.avatarURL;
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            self.avatarImage = image;
            self.imageView.image = self.avatarImage;
        }
    } else {
        NSLog(@"Avatar image does exist, setting image view.");
        //self.imageView.image = self.avatarImage;
    }
}

- (void)favoriteAdded:(NSNotification *)notification {
    NSLog(@"Favorite Added");
}

- (IBAction)addButtonPressed:(id)sender {
    SMAddGameViewController *addGameVC = [[SMAddGameViewController alloc] initWithNibName:@"SMAddGameViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:addGameVC animated:true completion:nil];
}



@end

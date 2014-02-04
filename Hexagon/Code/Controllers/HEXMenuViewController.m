//
//  HEXMenuViewController.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXMenuViewController.h"
#import "HEXPlaylistViewController.h"
#import "HEXProfileViewController.h"
#import "HEXSettingsViewController.h"
#import "HEXSearchViewController.h"
#import "HEXRoomsViewController.h"

@interface HEXMenuViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@end

static NSString *MenuCellIdentifier = @"MenuCellIdentifier";

static const int kSearchIndex = 0;
static const int kRoomsIndex = 1;
static const int kPlaylistIndex = 2;
static const int kProfileIndex = 3;
static const int kSettingsIndex = 4;

@implementation HEXMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.searchNavController = [[UINavigationController alloc] initWithRootViewController: [[HEXSearchViewController alloc] initWithNibName:NSStringFromClass([HEXSearchViewController class]) bundle:nil]];
        self.roomsNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXRoomsViewController alloc] initWithNibName:NSStringFromClass([HEXRoomsViewController class]) bundle:nil]];
        self.playlistNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXPlaylistViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistViewController class]) bundle:nil]];
        self.profileNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXProfileViewController alloc] initWithNibName:NSStringFromClass([HEXProfileViewController class]) bundle:nil]];
        self.settingsNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXSettingsViewController alloc] initWithNibName:NSStringFromClass([HEXSettingsViewController class]) bundle:nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blurrystars"]];
    CGSize imageSize = [UIImage imageNamed:@"blurrystars2"].size;
    [self.backgroundImageView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    self.gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(closeSideMenu)];
    self.gestureRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MenuCellIdentifier];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    switch (indexPath.row) {
        case kSearchIndex: {
            cell.textLabel.text = NSLocalizedString(@"Search", @"Search");
            break;
        }
        case kRoomsIndex: {
            cell.textLabel.text = NSLocalizedString(@"Rooms", @"Rooms");
            break;
        }
        case kPlaylistIndex: {
            cell.textLabel.text = NSLocalizedString(@"Playlists", @"Playlists");
            break;
        }
        case kProfileIndex: {
            cell.textLabel.text = NSLocalizedString(@"Profile", @"Profile");
            break;
        }
        case kSettingsIndex: {
            cell.textLabel.text = NSLocalizedString(@"Settings", @"Settings");
            break;
        }
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    switch (indexPath.row) {
        case kSearchIndex: {
            [self searchTapped];
            break;
        }
        case kRoomsIndex: {
            [self roomsTapped];
            break;
        }
        case kPlaylistIndex: {
            [self playlistTapped];
            break;
        }
        case kProfileIndex: {
            [self profileTapped];
            break;
        }
        case kSettingsIndex: {
            [self settingsTapped];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Menu Options
- (void)searchTapped {
    if (self.sideMenuViewController.mainViewController == self.searchNavController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.searchNavController animated:YES closeMenu:YES];
    }
}

- (void)roomsTapped {
    if (self.sideMenuViewController.mainViewController == self.roomsNavController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.roomsNavController animated:YES closeMenu:YES];
    }
}

- (void)playlistTapped {
    if (self.sideMenuViewController.mainViewController == self.playlistNavController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.playlistNavController animated:YES closeMenu:YES];
    }
}

- (void)profileTapped {
    if (self.sideMenuViewController.mainViewController == self.profileNavController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.profileNavController animated:YES closeMenu:YES];
    }
}

- (void)settingsTapped {
    if (self.sideMenuViewController.mainViewController == self.settingsNavController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.settingsNavController animated:YES closeMenu:YES];
    }
}

#pragma mark - Menu Actions
- (void)closeSideMenu {
    [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

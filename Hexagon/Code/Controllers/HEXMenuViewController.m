//
//  HEXMenuViewController.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXMenuViewController.h"

@interface HEXMenuViewController ()

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@end

static NSString *MenuCellIdentifier = @"MenuCellIdentifier";

static const int kPlaylistIndex = 0;
static const int kProfileIndex = 1;

@implementation HEXMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.playlistViewController = [[HEXPlaylistViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistViewController class]) bundle:nil];
        self.profileViewController = [[HEXProfileViewController alloc] initWithNibName:NSStringFromClass([HEXProfileViewController class]) bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(closeSideMenu)];
    self.gestureRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MenuCellIdentifier];
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
        case kPlaylistIndex: {
            cell.textLabel.text = NSLocalizedString(@"Playlists", @"Playlists");
            break;
        }
        case kProfileIndex: {
            cell.textLabel.text = NSLocalizedString(@"Profile", @"Profile");
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    switch (indexPath.row) {
        case kPlaylistIndex: {
            [self playlistTapped];
            break;
        }
        case kProfileIndex: {
            [self profileTapped];
            break;
        }
        default:
            break;
    }
}

- (void)playlistTapped {
    if (self.sideMenuViewController.mainViewController == self.playlistViewController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.playlistViewController animated:YES closeMenu:YES];
    }
}

- (void)profileTapped {
    if (self.sideMenuViewController.mainViewController == self.profileViewController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.profileViewController animated:YES closeMenu:YES];
    }
}

- (void)closeSideMenu {
    [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

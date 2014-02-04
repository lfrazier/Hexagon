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
#import "HEXInboxViewController.h"

@interface HEXMenuViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) NSArray *menuOptionNavControllers;

@end

static NSString *MenuCellIdentifier = @"MenuCellIdentifier";

@implementation HEXMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.searchNavController = [[UINavigationController alloc] initWithRootViewController: [[HEXSearchViewController alloc] initWithNibName:NSStringFromClass([HEXSearchViewController class]) bundle:nil]];
        self.roomsNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXRoomsViewController alloc] initWithNibName:NSStringFromClass([HEXRoomsViewController class]) bundle:nil]];
        self.playlistNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXPlaylistViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistViewController class]) bundle:nil]];
        self.inboxNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXInboxViewController alloc] initWithNibName:NSStringFromClass([HEXInboxViewController class]) bundle:nil]];
        self.profileNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXProfileViewController alloc] initWithNibName:NSStringFromClass([HEXProfileViewController class]) bundle:nil]];
        self.settingsNavController = [[UINavigationController alloc] initWithRootViewController:[[HEXSettingsViewController alloc] initWithNibName:NSStringFromClass([HEXSettingsViewController class]) bundle:nil]];
        
        self.menuOptionNavControllers = @[self.searchNavController, self.roomsNavController, self.playlistNavController, self.inboxNavController, self.profileNavController, self.settingsNavController];
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
    return self.menuOptionNavControllers.count;
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
    UINavigationController *navController = self.menuOptionNavControllers[indexPath.row];
    cell.textLabel.text = ((UIViewController *)navController.viewControllers[0]).title;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return;
    }
    UINavigationController *navController = self.menuOptionNavControllers[indexPath.row];
    [self menuItemTappedWithNavController:navController];
}

#pragma mark - Menu Options
- (void)menuItemTappedWithNavController:(UINavigationController *)navController {
    if (self.sideMenuViewController.mainViewController == navController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:navController animated:YES closeMenu:YES];
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

//
//  HEXMenuViewController.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXMenuViewController.h"

@interface HEXMenuViewController ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@end

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
}

- (IBAction)playlistButtonPressed:(id)sender {
    if (self.sideMenuViewController.mainViewController == self.playlistViewController) {
        [self closeSideMenu];
    } else {
        [self.sideMenuViewController setMainViewController:self.playlistViewController animated:YES closeMenu:YES];
    }
}

- (IBAction)profileButtonPressed:(id)sender {
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

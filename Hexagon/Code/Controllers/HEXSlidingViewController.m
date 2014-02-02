//
//  HEXSlidingViewController.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXSlidingViewController.h"

@interface HEXSlidingViewController ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *gestureRecognizer;

@end

@implementation HEXSlidingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(openSideMenu)];
    self.gestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)openSideMenu {
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

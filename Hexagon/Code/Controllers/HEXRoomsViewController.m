//
//  HEXRoomsViewController.m
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXRoomsViewController.h"

@interface HEXRoomsViewController ()

@end

@implementation HEXRoomsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Rooms", @"Rooms");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

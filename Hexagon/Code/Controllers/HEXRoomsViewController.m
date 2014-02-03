//
//  HEXRoomsViewController.m
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXRoomsViewController.h"

@interface HEXRoomsViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation HEXRoomsViewController

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
    // Do any additional setup after loading the view from its nib.
    
}

- (IBAction)searchTapped:(id)sender {
    NSLog(self.textField.text);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

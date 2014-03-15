//
//  HEXAppDelegate.h
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TWTSideMenuViewController/TWTSideMenuViewController.h>


@interface HEXAppDelegate : UIResponder <UIApplicationDelegate, TWTSideMenuViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UIViewController *mainViewController;

- (NSURL *)applicationDocumentsDirectory;

@end

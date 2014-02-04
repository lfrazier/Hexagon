//
//  HEXMenuViewController.h
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEXMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UINavigationController *searchNavController;
@property (nonatomic, strong) UINavigationController *roomsNavController;
@property (nonatomic, strong) UINavigationController *playlistNavController;
@property (nonatomic, strong) UINavigationController *inboxNavController;
@property (nonatomic, strong) UINavigationController *profileNavController;
@property (nonatomic, strong) UINavigationController *settingsNavController;

@end

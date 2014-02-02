//
//  HEXMenuViewController.h
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEXPlaylistViewController.h"
#import "HEXProfileViewController.h"

@interface HEXMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) HEXPlaylistViewController *playlistViewController;
@property (nonatomic, strong) HEXProfileViewController *profileViewController;

@end

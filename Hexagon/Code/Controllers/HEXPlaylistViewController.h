//
//  HEXPlaylistViewController.h
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEXSlidingViewController.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface HEXPlaylistViewController : HEXSlidingViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

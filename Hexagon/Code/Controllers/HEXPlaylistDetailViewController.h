//
//  HEXPlaylistDetailViewController.h
//  Hexagon
//
//  Created by Lauren on 2/3/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"

@interface HEXPlaylistDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Playlist *playlist;

@end

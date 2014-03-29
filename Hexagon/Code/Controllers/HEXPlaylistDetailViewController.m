//
//  HEXPlaylistDetailViewController.m
//  Hexagon
//
//  Created by Lauren on 2/3/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXPlaylistDetailViewController.h"

#import "HEXAppDelegate.h"
#import "HEXPlaybackManager.h"
#import "HEXPlaylistViewController.h"
#import "HEXSpotifyManager.h"
#import "HEXSongPlaybackViewController.h"
#import "HEXSwipeableTableViewCell.h"
#import "NSMutableArray+HEXUtilityButtons.h"

@interface HEXPlaylistDetailViewController () <SWTableViewCellDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tracks;

@end

typedef NS_ENUM(NSInteger, HEXPlaylistDetailUtilityButton) {
  HEXPlaylistDetailUtilityButtonStar,
  HEXPlaylistDetailUtilityButtonAddToPlaylist,
  HEXPlaylistDetailUtilityButtonRemoveFromPlaylist,
  HEXPlaylistDetailUtilityButtonShare
};

@implementation HEXPlaylistDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView)
                                                 name:kPlaylistTracksLoadedNotification
                                               object:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.title = self.playlist.name;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self refreshTableView];
}

- (void)refreshTableView {
  self.tracks = [self tracksFromPlaylist:self.playlist];
  [self.tableView reloadData];
}

- (NSArray *)tracksFromPlaylist:(SPPlaylist *)playlist {
  NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:playlist.items.count];
	for (SPPlaylistItem *anItem in playlist.items) {
		if (anItem.itemClass == [SPTrack class]) {
			[tracks addObject:anItem.item];
		}
	}
	return [NSArray arrayWithArray:tracks];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"PlaylistDetailCell";
  HEXSwipeableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (!cell) {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    [rightUtilityButtons hexInsertUtilityButtonWithColor:[UIColor yellowColor]
                                                   title:@"Star"
                                                 atIndex:HEXPlaylistDetailUtilityButtonStar];
    [rightUtilityButtons hexInsertUtilityButtonWithColor:[UIColor greenColor]
                                                   title:@"Add"
                                                 atIndex:HEXPlaylistDetailUtilityButtonAddToPlaylist];
    [rightUtilityButtons hexInsertUtilityButtonWithColor:[UIColor redColor]
                                                   title:@"Remove"
                                                 atIndex:HEXPlaylistDetailUtilityButtonRemoveFromPlaylist];
    [rightUtilityButtons hexInsertUtilityButtonWithColor:[UIColor blueColor]
                                                   title:@"Share"
                                                 atIndex:HEXPlaylistDetailUtilityButtonShare];

    cell = [[HEXSwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:CellIdentifier
                                        containingTableView:_tableView
                                         leftUtilityButtons:nil
                                        rightUtilityButtons:rightUtilityButtons];
    cell.delegate = self;
  }

  // Set up the cell...
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)configureCell:(HEXSwipeableTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  SPTrack *track = self.tracks[indexPath.row];
  cell.textLabel.text = (track.name.length) ? track.name : track.spotifyURL.absoluteString;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SPTrack *track = self.tracks[indexPath.row];
  HEXSongPlaybackViewController *playbackController = [[HEXSongPlaybackViewController alloc] initWithNibName:NSStringFromClass([HEXSongPlaybackViewController class]) bundle:nil];
  playbackController.track = track;
  [[HEXPlaybackManager sharedInstance] playTrackAtIndex:indexPath.row fromPlaylist:self.playlist shuffle:NO repeat:NO callback:nil];
  [self.navigationController pushViewController:playbackController animated:YES];
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {

}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
  NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
  SPTrack *track = self.tracks[cellIndexPath.row];

  switch (index) {
    case HEXPlaylistDetailUtilityButtonStar: {
      [self starTrack:track];
      [cell hideUtilityButtonsAnimated:YES];
      break;
    }
    case HEXPlaylistDetailUtilityButtonAddToPlaylist: {
      [self addTrackToPlaylist:track];
      [cell hideUtilityButtonsAnimated:YES];
      break;
    }
    case HEXPlaylistDetailUtilityButtonRemoveFromPlaylist: {
      [self removeTrackFromPlaylist:track];
      break;
    }
    case HEXPlaylistDetailUtilityButtonShare: {
      [self shareTrack:track];
      break;
    }
    default: {
      [cell hideUtilityButtonsAnimated:YES];
      break;
    }
  }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
  return YES;
}

#pragma mark - Song Actions

- (void)starTrack:(SPTrack *)track {
  track.starred = !track.starred;
}

- (void)addTrackToPlaylist:(SPTrack *)track {
  HEXPlaylistViewController *addToPlaylistViewController = [[HEXPlaylistViewController alloc] initWithAddToPlaylistMode:YES
                                                                                                              withTrack:track];
  [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:addToPlaylistViewController]
                                          animated:YES
                                        completion:nil];
}

- (void)removeTrackFromPlaylist:(SPTrack *)track {
  [self.playlist removeItemAtIndex:[self.tracks indexOfObject:track] callback:^(NSError *error) {
    if (error) {
      // TODO: Replace with real error handling
      [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                  message:error.localizedDescription
                                 delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil] show];
    }
    [self refreshTableView];
  }];
}

- (void)shareTrack:(SPTrack *)track {
  NSString *shareText = [NSString stringWithFormat:@"%@ — %@", track.name, track.consolidatedArtists];
  NSURL *trackURL = [[HEXSpotifyManager sharedInstance] httpURLFromSpotifyURL:track.spotifyURL];
  NSArray *itemsToShare = @[shareText, trackURL];
  UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
                                                                           applicationActivities:nil];
  // TODO: Sharing to AirDrop??
  activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo,
                                       UIActivityTypePrint,
                                       UIActivityTypeSaveToCameraRoll];
  [self presentViewController:activityVC animated:YES completion:nil];
}

@end

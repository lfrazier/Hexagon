//
//  HEXPlaylistViewController.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXPlaylistViewController.h"
#import "HEXPlaylistDetailViewController.h"
#import "HEXSpotifyManager.h"
#import "HEXPlaybackManager.h"

@interface HEXPlaylistViewController () <UIAlertViewDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL addToPlaylistMode;
@property (nonatomic) SPTrack *trackToAdd;

@end

@implementation HEXPlaylistViewController

- (id)initWithAddToPlaylistMode:(BOOL)addToPlaylistMode withTrack:(SPTrack *)trackToAdd {
  self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
  if (self) {
    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView)
                                                 name:kPlaylistsLoadedNotification
                                               object:nil];
    _addToPlaylistMode = addToPlaylistMode;
    _trackToAdd = trackToAdd;
  }
  return self;
}

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  NSAssert(nil, @"HEXPlaylistViewController should only be initialized with initWithAddToPlaylistMode!");
  return nil;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = self.addToPlaylistMode ? NSLocalizedString(@"Add to Playlist", @"Add to Playlist") :NSLocalizedString(@"Playlists", @"Playlists");
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (self.addToPlaylistMode) {
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:@"CANCEL"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(cancelPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *plusButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewPlaylistAndAddSong)];
    self.navigationItem.rightBarButtonItem = plusButton;
  }
  [self refreshTableView];
}

- (void)refreshTableView {
  [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [SPSession sharedSession].userPlaylists.flattenedPlaylists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";

  UITableViewCell *cell =
  [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (!cell) {
    cell = [[UITableViewCell alloc] init];
  }

  // Set up the cell...
  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  SPPlaylist *playlist = [SPSession sharedSession].userPlaylists.flattenedPlaylists[indexPath.row];
  cell.textLabel.text = (playlist.name.length) ? playlist.name : playlist.spotifyURL.absoluteString;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SPPlaylist *playlist = [SPSession sharedSession].userPlaylists.flattenedPlaylists[indexPath.row];
  if (self.addToPlaylistMode) {
    [self addTrackToExistingPlaylist:playlist];
  } else {
    [self openTrackListForPlaylist:playlist];
  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    return;
  }

  NSString *playlistName = [alertView textFieldAtIndex:0].text;
  // TODO: Validate playlist name
  if (playlistName && self.trackToAdd) {
    [[[SPSession sharedSession] userPlaylists]
        createPlaylistWithName:playlistName
                      callback:^(SPPlaylist *createdPlaylist) {
                        [SPAsyncLoading waitUntilLoaded:createdPlaylist
                                                timeout:kSPAsyncLoadingDefaultTimeout
                                                   then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                                     [createdPlaylist addItem:self.trackToAdd
                                                                      atIndex:0
                                                                     callback:^(NSError *error) {
                                                                       if (error) {
                                                                         [[HEXAlertView defaultAlertWithError:error] show];
                                                                       } else {
                                                                         [[HEXSpotifyManager sharedInstance] fetchPlaylists:nil];
                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                                       }
                                                                     }];
                                                    }];
     }];

  }
}

#pragma mark - Private

- (void)cancelPressed {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNewPlaylistAndAddSong {
  UIAlertView *createPlaylistAlertView =
      [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Playlist", @"New Playlist")
                                 message:NSLocalizedString(@"Enter the new name", @"Enter the new name")
                                delegate:self
                       cancelButtonTitle:[HEXCommonStrings cancel]
                       otherButtonTitles:NSLocalizedString(@"Create", @"Create"), nil];
  createPlaylistAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [createPlaylistAlertView show];
}

- (void)addTrackToExistingPlaylist:(SPPlaylist *)playlist {
  if (self.trackToAdd) {
    [playlist addItem:self.trackToAdd
              atIndex:playlist.items.count
             callback:^(NSError *error) {
               if (error) {
                 [[HEXAlertView defaultAlertWithError:error] show];
               } else {
                 [[HEXSpotifyManager sharedInstance] fetchPlaylists:nil];
                 [self dismissViewControllerAnimated:YES completion:nil];
               }
             }];
  }
}

- (void)openTrackListForPlaylist:(SPPlaylist *)playlist {
  HEXPlaylistDetailViewController *detailVC = [[HEXPlaylistDetailViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistDetailViewController class]) bundle:nil];
  detailVC.playlist = playlist;
  [self.navigationController pushViewController:detailVC animated:YES];
}

@end

//
//  HEXPlaylistDetailViewController.m
//  Hexagon
//
//  Created by Lauren on 2/3/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXPlaylistDetailViewController.h"
#import "HEXAppDelegate.h"
#import "HEXSpotifyManager.h"

@interface HEXPlaylistDetailViewController ()

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tracks;

@end

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
                             
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SPTrack *track = self.tracks[indexPath.row];
    cell.textLabel.text = (track.name.length) ? track.name : track.spotifyURL.absoluteString;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPTrack *track = self.tracks[indexPath.row];
    [[HEXSpotifyManager sharedInstance] playTrack:track];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

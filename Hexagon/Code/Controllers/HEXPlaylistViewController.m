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

@interface HEXPlaylistViewController ()

@property (nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HEXPlaylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshTableView)
                                                     name:kPlaylistsLoadedNotification
                                                   object:nil];
        self.title = NSLocalizedString(@"Playlists", @"Playlists");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    HEXPlaylistDetailViewController *detailVC = [[HEXPlaylistDetailViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistDetailViewController class]) bundle:nil];
    detailVC.playlist = [SPSession sharedSession].userPlaylists.flattenedPlaylists[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

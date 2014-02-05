//
//  HEXInboxViewController.m
//  Hexagon
//
//  Created by Lauren on 2/4/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXInboxViewController.h"
#import "HEXPlaylistDetailViewController.h"
#import "HEXSongPlaybackViewController.h"

@interface HEXInboxViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *inboxItems;

@end

@implementation HEXInboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Inbox", @"Inbox");
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
  self.inboxItems = [[SPSession sharedSession].inboxPlaylist.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO]]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inboxItems.count;
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
    SPPlaylistItem *playlistItem = self.inboxItems[indexPath.row];
    if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
        cell.textLabel.text = ((SPTrack *)playlistItem.item).name;
    } else if ([playlistItem.item isKindOfClass:[SPPlaylist class]]) {
        cell.textLabel.text = [@"PLAYLIST: " stringByAppendingString:((SPPlaylist *)playlistItem.item).name];
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SPPlaylistItem *playlistItem = self.inboxItems[indexPath.row];
  if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
    HEXSongPlaybackViewController *playbackController = [[HEXSongPlaybackViewController alloc] initWithNibName:NSStringFromClass([HEXSongPlaybackViewController class]) bundle:nil];
    playbackController.track = (SPTrack *)playlistItem.item;
    [self.navigationController pushViewController:playbackController animated:YES];
  } else if ([playlistItem.item isKindOfClass:[SPPlaylist class]]) {
    HEXPlaylistDetailViewController *detailVC = [[HEXPlaylistDetailViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistDetailViewController class]) bundle:nil];
    detailVC.playlist = (SPPlaylist *)playlistItem.item;
    [self.navigationController pushViewController:detailVC animated:YES];
  }
}

#pragma mark - Cleanup
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

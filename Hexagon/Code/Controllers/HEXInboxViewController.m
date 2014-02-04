//
//  HEXInboxViewController.m
//  Hexagon
//
//  Created by Lauren on 2/4/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXInboxViewController.h"

@interface HEXInboxViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
// TODO: Sort playlist items by date added

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

- (void)refreshTableView {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SPSession sharedSession].inboxPlaylist.items.count;
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
    SPPlaylistItem *playlistItem = [SPSession sharedSession].inboxPlaylist.items[indexPath.row];
    if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
        cell.textLabel.text = ((SPTrack *)playlistItem.item).name;
    } else if ([playlistItem.item isKindOfClass:[SPPlaylist class]]) {
        cell.textLabel.text = ((SPPlaylist *)playlistItem.item).name;
    }
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    HEXPlaylistDetailViewController *detailVC = [[HEXPlaylistDetailViewController alloc] initWithNibName:NSStringFromClass([HEXPlaylistDetailViewController class]) bundle:nil];
//    detailVC.playlist = [SPSession sharedSession].userPlaylists.flattenedPlaylists[indexPath.row];
//    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Cleanup
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

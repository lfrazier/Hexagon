//
//  HEXSpotifyManager.m
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXSpotifyManager.h"
#import "HEXAppDelegate.h"
#import "Playlist.h"
#import "appkey.c"

@interface HEXSpotifyManager ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation HEXSpotifyManager

@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    static id sharedInstance;
    dispatch_once(&predicate, ^() {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = ((HEXAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - Spotify Login
- (void)setUpSession {
    NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"com.spotify.SimplePlayer-iOS"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    [[SPSession sharedSession] setDelegate:self];
}

- (void)logIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"MostRecentUser"] != nil) {
        NSString *name = [defaults objectForKey:@"MostRecentUser"];
        NSString *credential = [[defaults objectForKey:@"SpotifyUsers"] objectForKey:name];
        [self attemptLoginWithName:name andCredential:credential];
    } else {
        [self performSelector:@selector(showLoginUI) withObject:nil afterDelay:0.0];
    }
}

- (void)attemptLoginWithName:(NSString *)name andCredential:(NSString *)credential {
    [[SPSession sharedSession] attemptLoginWithUserName:name existingCredential:credential];
}

- (void)showLoginUI {
    
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
	
	[((HEXAppDelegate *)[UIApplication sharedApplication].delegate).mainViewController presentViewController:controller animated:NO completion:nil];
    
}

#pragma mark Spotify Data
- (void)fetchPlaylists {
	
	[SPAsyncLoading waitUntilLoaded:[SPSession sharedSession] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedession, NSArray *notLoadedSession) {
		
		// The session is logged in and loaded — now wait for the userPlaylists to load.
		NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Session loaded.");
		
		[SPAsyncLoading waitUntilLoaded:[SPSession sharedSession].userPlaylists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedContainers, NSArray *notLoadedContainers) {
			
			// User playlists are loaded — wait for playlists to load their metadata.
			NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Container loaded.");
			
			NSMutableArray *playlists = [NSMutableArray array];
			[playlists addObject:[SPSession sharedSession].starredPlaylist];
			[playlists addObject:[SPSession sharedSession].inboxPlaylist];
			[playlists addObjectsFromArray:[SPSession sharedSession].userPlaylists.flattenedPlaylists];
			
			[SPAsyncLoading waitUntilLoaded:playlists timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedPlaylists, NSArray *notLoadedPlaylists) {
				
				// All of our playlists have loaded their metadata — wait for all tracks to load their metadata.
				NSLog(@"[%@ %@]: %@ of %@ playlists loaded.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
					  [NSNumber numberWithInteger:loadedPlaylists.count], [NSNumber numberWithInteger:loadedPlaylists.count + notLoadedPlaylists.count]);
                
                // Insert into CoreData
                [self createPlaylistsFromSPPlaylists:loadedPlaylists];
				
				NSArray *playlistItems = [loadedPlaylists valueForKeyPath:@"@unionOfArrays.items"];
				NSArray *tracks = [self tracksFromPlaylistItems:playlistItems];
				
				[SPAsyncLoading waitUntilLoaded:tracks timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedTracks, NSArray *notLoadedTracks) {
					
					// All of our tracks have loaded their metadata. Hooray!
					NSLog(@"[%@ %@]: %@ of %@ tracks loaded.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
						  [NSNumber numberWithInteger:loadedTracks.count], [NSNumber numberWithInteger:loadedTracks.count + notLoadedTracks.count]);
					
					/*
                     NSMutableArray *theTrackPool = [NSMutableArray arrayWithCapacity:loadedTracks.count];
                     
                     for (SPTrack *aTrack in loadedTracks) {
                     if (aTrack.availability == SP_TRACK_AVAILABILITY_AVAILABLE && [aTrack.name length] > 0)
                     [theTrackPool addObject:aTrack];
                     }
                     
                     self.trackPool = [NSMutableArray arrayWithArray:[[NSSet setWithArray:theTrackPool] allObjects]];
                     // ^ Thin out duplicates.
                     */
					
				}];
			}];
		}];
	}];
}

- (NSArray *)tracksFromPlaylistItems:(NSArray *)items {
	
	NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:items.count];
	
	for (SPPlaylistItem *anItem in items) {
		if (anItem.itemClass == [SPTrack class]) {
			[tracks addObject:anItem.item];
		}
	}
	
	return [NSArray arrayWithArray:tracks];
}

- (void)createPlaylistsFromSPPlaylists:(NSArray *)spplaylists {
    for (SPPlaylist *spplaylist in spplaylists) {
        // TODO: Check for duplicates before inserting into Core Data
        Playlist *playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlist.spotifyURL = spplaylist.spotifyURL.absoluteString;
        playlist.name = spplaylist.name;
        playlist.playlistDescription = spplaylist.playlistDescription;
    }
    [self.managedObjectContext save:nil];
}

#pragma mark SPSessionDelegate Methods
- (void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *storedCredentials = [[defaults objectForKey:@"SpotifyUsers"] mutableCopy];
    
    if (storedCredentials == nil)
        storedCredentials = [NSMutableDictionary dictionary];
    
    [storedCredentials setValue:credential forKey:userName];
    [defaults setObject:storedCredentials forKey:@"SpotifyUsers"];
    
    [defaults setObject:userName forKey:@"MostRecentUser"];
}

- (UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return ((HEXAppDelegate *)[UIApplication sharedApplication].delegate).mainViewController;
}

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
    [self fetchPlaylists];
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	// Invoked by SPSession after a failed login.
    [self showLoginUI];
}

- (void)sessionDidLogOut:(SPSession *)aSession {
	
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (((HEXAppDelegate *)[UIApplication sharedApplication].delegate).mainViewController.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[((HEXAppDelegate *)[UIApplication sharedApplication].delegate).mainViewController presentViewController:controller
                                          animated:YES
                                        completion:nil];
}

- (void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
- (void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
- (void)sessionDidChangeMetadata:(SPSession *)aSession; {}

- (void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (void)logOut {
    [[SPSession sharedSession] logout:^{
        [self showLoginUI];
    }];
}

@end

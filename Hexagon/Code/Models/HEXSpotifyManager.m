//
//  HEXSpotifyManager.m
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXSpotifyManager.h"
#import "HEXAppDelegate.h"
#import "appkey.c"

@interface HEXSpotifyManager ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;

@end

@implementation HEXSpotifyManager

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

- (SPPlaybackManager *)playbackManager {
    if (!_playbackManager) {
        _playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    }
    return _playbackManager;
}

#pragma mark - Spotify Login/Logout
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

- (void)logOut {
    [[SPSession sharedSession] logout:^{
        [self showLoginUI];
    }];
}

#pragma mark - Spotify Data
#pragma mark Fetch from server
- (void)fetchPlaylists:(void (^)(BOOL success))completion {
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
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistsLoadedNotification object:self];
                
				NSArray *playlistItems = [loadedPlaylists valueForKeyPath:@"@unionOfArrays.items"];
				NSArray *tracks = [self tracksFromPlaylistItems:playlistItems];
				
				[SPAsyncLoading waitUntilLoaded:tracks timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedTracks, NSArray *notLoadedTracks) {
					
					// All of our tracks have loaded their metadata. Hooray!
					NSLog(@"[%@ %@]: %@ of %@ tracks loaded.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
						  [NSNumber numberWithInteger:loadedTracks.count], [NSNumber numberWithInteger:loadedTracks.count + notLoadedTracks.count]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistTracksLoadedNotification object:self];

                    if (completion) {
                        completion(YES);
                    }
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

#pragma mark - SPSessionDelegate Methods
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
    [self fetchPlaylists:nil];
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

#pragma mark - Playback
- (void)playTrackWithURL:(NSURL *)trackURL {
    [SPTrack trackForTrackURL:trackURL inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
        [self.playbackManager playTrack:track callback:nil];
    }];
}

- (void)playTrack:(SPTrack *)track {
    [self.playbackManager playTrack:track callback:nil];
}

- (void)pauseCurrentTrack {
    self.playbackManager.isPlaying = NO;
}

- (void)resumeCurrentTrack {
    self.playbackManager.isPlaying = YES;
}

- (void)seekCurrentTrackToPosition:(NSTimeInterval)position {
    [self.playbackManager seekToTrackPosition:position];
}

- (void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager {
    
}

@end

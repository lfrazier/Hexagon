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
#import "Track.h"
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
                
                
                completion(YES);
                // Insert into CoreData
                //[self createPlaylistsFromSPPlaylists:loadedPlaylists];
//				
//				for (SPPlaylist *spplaylist in loadedPlaylists) {
//                    [self fetchTracksFromSPPlaylist:spplaylist];
//                }
			}];
		}];
	}];
}

- (void)fetchTracksFromSPPlaylist:(SPPlaylist *)spplaylist {
    NSArray *tracks = [self extractSPTracksFromSPPlaylist:spplaylist];
    
    [SPAsyncLoading waitUntilLoaded:tracks timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedTracks, NSArray *notLoadedTracks) {
        
        // All of our tracks have loaded their metadata. Hooray!
        NSLog(@"[%@ %@]: %@ of %@ tracks loaded.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),
              [NSNumber numberWithInteger:loadedTracks.count], [NSNumber numberWithInteger:loadedTracks.count + notLoadedTracks.count]);
            //[self createTracksFromSPTracks:loadedTracks addToPlaylist:[self playlistFromSPPlaylist:spplaylist]];
    }];
}

- (NSArray *)extractSPTracksFromSPPlaylist:(SPPlaylist *)spplaylist {
	NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:spplaylist.items.count];
	for (SPPlaylistItem *anItem in spplaylist.items) {
		if (anItem.itemClass == [SPTrack class]) {
			[tracks addObject:anItem.item];
		}
	}
	return [NSArray arrayWithArray:tracks];
}


#pragma mark Adapt to Core Data
- (void)createPlaylistsFromSPPlaylists:(NSArray *)spplaylists {
    for (SPPlaylist *spplaylist in spplaylists) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spotifyURL == %@", spplaylist.spotifyURL];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"Core Data: error fetching playlists");
        }

        Playlist *playlist;
        if (fetchedObjects.count == 1) {
            // There is one object, just update the fields.
            playlist = [fetchedObjects firstObject];
        } else if (fetchedObjects.count > 1) {
            // There were multiple objects. Delete them all and make a new one.
            for (Playlist *duplicate in fetchedObjects) {
                [self.managedObjectContext deleteObject:duplicate];
            }
            playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        } else {
            // There were no objects, make a new one.
            playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        }
        playlist.spotifyURL = spplaylist.spotifyURL.absoluteString;
        playlist.name = spplaylist.name;
        playlist.playlistDescription = spplaylist.playlistDescription;
        playlist.userOrder = @([spplaylists indexOfObject:spplaylist]);
    }
    [self.managedObjectContext save:nil];
}

- (void)createTracksFromSPTracks:(NSArray *)sptracks addToPlaylist:(Playlist *)playlist {
    for (SPTrack *sptrack in sptracks) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Track class]) inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spotifyURL == %@", sptrack.spotifyURL];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            NSLog(@"Core Data: error fetching playlists");
        }
        
        Track *track;
        if (fetchedObjects.count == 1) {
            // There is one object, just update the fields.
            track = [fetchedObjects firstObject];
        } else if (fetchedObjects.count > 1) {
            // There were multiple objects. Delete them all and make a new one.
            for (Track *duplicate in fetchedObjects) {
                [self.managedObjectContext deleteObject:duplicate];
            }
            track = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Track class]) inManagedObjectContext:self.managedObjectContext];
        } else {
            // There were no objects, make a new one.
            track = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Track class]) inManagedObjectContext:self.managedObjectContext];
        }
        track.spotifyURL = sptrack.spotifyURL.absoluteString;
        track.name = sptrack.name;
        track.duration = @(sptrack.duration);
        track.userOrder = @([sptracks indexOfObject:sptrack]);
        [track addPlaylistsObject:playlist];
    }
    [self.managedObjectContext save:nil];
}

- (Playlist *)playlistFromSPPlaylist:(SPPlaylist *)spplaylist {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spotifyURL == %@", spplaylist.spotifyURL];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Core Data: error fetching playlists");
    }
    return [fetchedObjects firstObject];
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

@end

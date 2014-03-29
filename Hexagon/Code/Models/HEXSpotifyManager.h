//
//  HEXSpotifyManager.h
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface HEXSpotifyManager : NSObject <SPSessionDelegate, SPPlaybackManagerDelegate>

@property (nonatomic, strong) NSArray *userPlaylists;


+ (instancetype)sharedInstance;

/**
 Set up the Spotify session. Note, this is not the same as logging in.
 This method only creates the shared session.
 */
- (void)setUpSession;
/**
 Log the user in. If the credentials exist in NSUserDefaults, an "automatic" login is attempted.
 If it fails, or no credentials are found, the login UI is displayed.
 */
- (void)logIn;
/**
 Attempts to log the user in with the saved username and credentials.
 */
- (void)attemptLoginWithName:(NSString *)name andCredential:(NSString *)credential;
/**
 Displays the standard login UI.
 */
- (void)showLoginUI;
/**
 Fetches playlists and tracks (for easy preloading).
 */
- (void)fetchPlaylists:(void (^)(BOOL success))completion;
/**
 Log the user out.
 */
- (void)logOut;

/**
 Return an http:// url with the components of the spotify URL.
 */
- (NSURL *)httpURLFromSpotifyURL:(NSURL *)spotifyURL;

@end

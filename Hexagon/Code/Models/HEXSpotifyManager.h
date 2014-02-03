//
//  HEXSpotifyManager.h
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface HEXSpotifyManager : NSObject <SPSessionDelegate>

+ (instancetype)sharedInstance;

- (void)setUpSession;
- (void)logIn;
- (void)attemptLoginWithName:(NSString *)name andCredential:(NSString *)credential;
- (void)showLoginUI;
- (void)fetchPlaylists;
- (void)logOut;

@end

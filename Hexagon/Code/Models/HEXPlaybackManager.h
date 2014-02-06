//
//  HEXPlaybackManager.h
//  Hexagon
//
//  Created by Lauren on 2/5/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "SPPlaybackManager.h"

@interface HEXPlaybackManager : SPPlaybackManager

@property (nonatomic, strong) SPPlaylist *currentPlaylist;
@property (nonatomic, assign) NSInteger currentSongIndex;
@property (nonatomic, assign) BOOL shufflePlaylist;
@property (nonatomic, assign) BOOL repeatPlaylist;

+ (instancetype)sharedInstance;

- (void)playNextTrackWithCallback:(SPErrorableOperationCallback)block;
- (void)playPreviousTrackWithCallback:(SPErrorableOperationCallback)block;
- (void)playTrackAtIndex:(int)index fromPlaylist:(SPPlaylist *)playlist shuffle:(BOOL)shuffle repeat:(BOOL)repeat callback:(SPErrorableOperationCallback)block;

@end
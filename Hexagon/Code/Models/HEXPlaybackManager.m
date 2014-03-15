//
//  HEXPlaybackManager.m
//  Hexagon
//
//  Created by Lauren on 2/5/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXPlaybackManager.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface HEXPlaybackManager ()

@property (nonatomic, strong) NSMutableArray *playlistTracks;

@end

@implementation HEXPlaybackManager

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[HEXPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
  });

  return _sharedInstance;
}

#pragma mark - Setters and Getters
- (void)setCurrentPlaylist:(SPPlaylist *)currentPlaylist {
  _currentPlaylist = currentPlaylist;
  self.currentSongIndex = 0;
  self.playlistTracks = [@[] mutableCopy];
  if (self.shufflePlaylist) {
    self.playlistTracks = [[self shuffleArray:currentPlaylist.items] mutableCopy];
  } else {
    self.playlistTracks = [currentPlaylist.items mutableCopy];
  }
}

- (NSMutableArray *)createRandomIndicesWithLength:(int)length {
  NSMutableArray *uniqueNumbers = [@[] mutableCopy];
  int r;
  while ([uniqueNumbers count] < length) {
    r = arc4random() % length;
    if (![uniqueNumbers containsObject:[NSNumber numberWithInt:r]]) {
      [uniqueNumbers addObject:[NSNumber numberWithInt:r]];
    }
  }
  return uniqueNumbers;
}

- (NSArray *)shuffleArray:(NSArray *)array {
  NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
  NSUInteger count = [mutableArray count];
  for (NSUInteger i = 0; i < count; ++i) {
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = arc4random_uniform(nElements) + i;
    [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:n];
  }
  return [NSArray arrayWithArray:mutableArray];
}

- (void)playNextTrackWithCallback:(SPErrorableOperationCallback)block {
  self.currentSongIndex++;
  if (self.currentSongIndex >= self.playlistTracks.count) {
    if (self.repeatPlaylist) {
      self.currentSongIndex = 0;
    } else {
      // TODO: Set currentPlaylist to nil?
      // Put the index back where it was and return.
      self.currentSongIndex--;
      return;
    }
  }
  SPPlaylistItem *playlistItem = self.playlistTracks[self.currentSongIndex];
  if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
    [self playTrack:((SPTrack *)playlistItem.item) callback:^(NSError *error) {
      if (block) {
        block(error);
      }
    }];
  } else {
    [self playNextTrackWithCallback:^(NSError *error) {
      if (block) {
        block(error);
      }
    }];
  }
}

- (void)playPreviousTrackWithCallback:(SPErrorableOperationCallback)block {
  self.currentSongIndex--;
  if (self.currentSongIndex < 0) {
    if (self.repeatPlaylist) {
      self.currentSongIndex = self.playlistTracks.count - 1;
    } else {
      // Put the index back to where it was and return.
      self.currentSongIndex++;
      return;
    }
  }
  SPPlaylistItem *playlistItem = self.playlistTracks[self.currentSongIndex];
  if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
    [self playTrack:((SPTrack *)playlistItem.item) callback:^(NSError *error) {
      if (block) {
        block(error);
      }
    }];
  } else {
    [self playNextTrackWithCallback:^(NSError *error) {
      if (block) {
        block(error);
      }
    }];
  }
}

- (void)playTrackAtIndex:(int)index fromPlaylist:(SPPlaylist *)playlist shuffle:(BOOL)shuffle repeat:(BOOL)repeat callback:(SPErrorableOperationCallback)block {
  SPPlaylistItem *originalItem = playlist.items[index];
  self.shufflePlaylist = shuffle;
  self.repeatPlaylist = repeat;
  self.currentPlaylist = playlist;
  if (shuffle) {
    [self.playlistTracks exchangeObjectAtIndex:[self.playlistTracks indexOfObject:originalItem] withObjectAtIndex:0];
    self.currentSongIndex = 0;
  } else {
    self.currentSongIndex = index;
  }
  SPPlaylistItem *playlistItem = self.playlistTracks[self.currentSongIndex];
  if ([playlistItem.item isKindOfClass:[SPTrack class]]) {
    [self playTrack:((SPTrack *)playlistItem.item) callback:^(NSError *error) {
      if (block) {
        block(error);
      }
    }];
  }
}

- (void)sessionDidEndPlayback:(id<SPSessionPlaybackProvider>)aSession {
  [super sessionDidEndPlayback:aSession];
  if (self.currentPlaylist) {
    [self playNextTrackWithCallback:nil];
  }
}

@end

//
//  Track.h
//  Hexagon
//
//  Created by Lauren on 2/3/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSString * spotifyURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * userOrder;
@property (nonatomic, retain) NSSet *playlists;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(Playlist *)value;
- (void)removePlaylistsObject:(Playlist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;

@end

//
//  Playlist.h
//  Hexagon
//
//  Created by Lauren on 2/2/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSString * spotifyURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * playlistDescription;
@property (nonatomic, retain) NSManagedObject *user;
@property (nonatomic, retain) NSSet *tracks;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;

@end

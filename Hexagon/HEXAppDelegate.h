//
//  HEXAppDelegate.h
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

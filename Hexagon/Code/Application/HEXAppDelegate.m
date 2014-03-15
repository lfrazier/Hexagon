//
//  HEXAppDelegate.m
//  Hexagon
//
//  Created by Lauren on 2/1/14.
//  Copyright (c) 2014 Lauren Frazier. All rights reserved.
//

#import "HEXAppDelegate.h"
#import "HEXMenuViewController.h"
#import "HEXPlaylistViewController.h"
#import "HEXSpotifyManager.h"

@interface HEXAppDelegate ()

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) HEXMenuViewController *menuViewController;

@end

@implementation HEXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // TWTSideMenuViewController Code
  self.menuViewController = [[HEXMenuViewController alloc] initWithNibName:NSStringFromClass([HEXMenuViewController class]) bundle:nil];
  self.mainViewController = self.menuViewController.playlistNavController;
  // create a new side menu
  self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:self.mainViewController];
  // specify the shadow color to use behind the main view controller when it is scaled down.
  self.sideMenuViewController.shadowColor = [UIColor blackColor];
  // zoom scale
  self.sideMenuViewController.zoomScale = kMenuZoom;
  // zoom speed
  self.sideMenuViewController.animationDuration = 0.2;
  // fade the new view in, rather than sliding it
  self.sideMenuViewController.animationType = TWTSideMenuAnimationTypeFadeIn;
  // set the side menu controller as the root view controller
  self.window.rootViewController = self.sideMenuViewController;

  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];

  [[HEXSpotifyManager sharedInstance] setUpSession];
  [[HEXSpotifyManager sharedInstance] logIn];

  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

//
//  AppDelegate.m
//  FawaedTV
//
//  Created by Homam on 2014-12-12.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "AppDelegate.h"
#import "databaseManager.h"
#import "downloadManager.h"
#import "episodsManager.h"
#import "AFSoundManager.h"
#import <FlightRecorder/FlightRecorder.h>

@interface AppDelegate ()
@property (nonatomic,strong) databaseManager *dbObj;
@property (nonatomic,strong) downloadManager *downloadManager;
@property (nonatomic,strong) episodsManager  *epManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.dbObj              = [databaseManager sharedDatabaseObj];
    self.downloadManager    = [downloadManager sharedDownloadObj];
    self.epManager          = [episodsManager new];


    [[FlightRecorder sharedInstance] setAccessKey:@"773f41eb-c13b-4c0d-b42e-7aa6250e7845"
                                        secretKey:@"e5e0b566-ce14-4ae9-b18d-2e9fbba6e403"];
    [[FlightRecorder sharedInstance] startFlight];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

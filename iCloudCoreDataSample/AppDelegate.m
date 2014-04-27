//
//  AppDelegate.m
//  iCloudCoreDataSample
//
//  Created by Oda Naoyuki on 2014/04/23.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //iCloudを使用する為の設定を行う
    [self setupManagedObjectContext];

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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//モデルファイルのURLを返す
- (NSURL*)modelURL {
    NSURL *retURL = [[NSBundle mainBundle] URLForResource:@"BookDataModel" withExtension:@"momd"];
    return retURL;
}

//永続化ストアファイルのURLを返す
- (NSURL*)storeURL {
    NSURL *retURL = nil;
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    retURL = [NSURL fileURLWithPath:[[dirs lastObject]
                                   stringByAppendingPathComponent:@"iCloudCoreDataSample.sqlite"]];
    return retURL;
}

- (void)setupManagedObjectContext {
    //管理オブジェクト生成
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    
    //永続ストアコーディネイター生成
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //永続ストアの変更通知受信時処理設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(icloudDidImportContentChanges:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:coordinator];
    
    //管理オブジェクトコンテキスト初期化
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //永続ストアコーディネイター生成オプションを格納する辞書
        NSMutableDictionary *options = @{
                                         NSMigratePersistentStoresAutomaticallyOption: @YES,
                                         NSInferMappingModelAutomaticallyOption: @YES
                                         }.mutableCopy;
        
        //コンテナのURL取得
        NSURL *url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
        //コンテナのURLがとれてたら(iCloudが有効だったら)永続ストアコーディネイタ生成オプションを実際に設定する
        if (url)
        {
            options[NSPersistentStoreUbiquitousContentNameKey] = @"Books";
            options[NSPersistentStoreUbiquitousContentURLKey] = @"data";
        }
    
        //永続ストアコーディネイターに永続ストアを設定する
        NSError *err = nil;
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                  configuration:nil
                                            URL:[self storeURL]
                                        options:options
                                          error:&err];
    
        //管理オブジェクトコンテキストに永続ストアコーディネイターを設定する
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    });
}

- (void)icloudDidImportContentChanges:(NSNotification*)noti {
    NSLog(@"did import content");

    [_managedObjectContext performBlock:^{
        //通知に従って、管理オブジェクトに変更を適用する
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:noti];
        
        //管理オブジェクトの変更を永続化ストアへ保存
        NSError *error = nil;
        if (![_managedObjectContext save:&error])
            NSLog(@"error in icloudDidImportContentChanges %@", error);
    }];
}

@end

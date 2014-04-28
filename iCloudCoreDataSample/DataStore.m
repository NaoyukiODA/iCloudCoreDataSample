//
//  DataStore.m
//  iCloudCoreDataSample
//
//  Created by ODA NAOYUKI on 2014/04/28.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import "DataStore.h"
#import <CoreData/CoreData.h>

@interface DataStore()
    
@end

@implementation DataStore

static DataStore *shdInstance = nil;

+ (DataStore *) sharedInstance
{
    @synchronized(self)
    {
        if (shdInstance == nil) {
            [[DataStore alloc] init];
        }
    }
    
    return shdInstance;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (shdInstance == nil) {
            shdInstance = [super allocWithZone:zone];
            return shdInstance;
        }
    }
    
    return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) init
{
    self = [super init];
    if( self != nil){
        [self setupManagedObjectContext];
    }
    
    return self;
    
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

//
//  DataStore.h
//  iCloudCoreDataSample
//
//  Created by ODA NAOYUKI on 2014/04/28.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataStoreDelegate <NSObject>

- (void)upDateView;

@end

@interface DataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (retain, nonatomic) id<DataStoreDelegate> delegate;

+(DataStore *)sharedInstance;

@end

//
//  Books.h
//  iCloudCoreDataSample
//
//  Created by Oda Naoyuki on 2014/04/26.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Books : NSManagedObject

@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * bookName;

@end

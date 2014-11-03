//
//  NPUser.h
//  NotePad
//
//  Created by chenxiaolong on 14-7-12.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NPInfo;

@interface NPUser : NSManagedObject

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSSet *notes;

@end

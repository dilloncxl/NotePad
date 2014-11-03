//
//  NPNote.h
//  NotePad
//
//  Created by chenxiaolong on 14-7-14.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NPInfo : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSData *content;
@property (nonatomic, retain) NSString *photoUrl;
@property (nonatomic, retain) NSString *noteId;
@property (nonatomic, retain) NSString *recordUrl;
@property (nonatomic, retain) NSDate *createTime;
@property (nonatomic, retain) NSString *userName;

@property (nonatomic, retain) NSDate *sectionIdentifier;
@property (nonatomic, retain) NSNumber *yearAndWeeks;


@end

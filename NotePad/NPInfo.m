//
//  NPNote.m
//  NotePad
//
//  Created by chenxiaolong on 14-7-14.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "NPInfo.h"

@interface NPInfo()

//@property (nonatomic) NSDate *primitiveTimeStamp;
//@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation NPInfo

@dynamic title;
@dynamic content;
@dynamic photoUrl;
@dynamic recordUrl;
@dynamic createTime;
@dynamic userName;
@dynamic noteId;

@dynamic sectionIdentifier;
@dynamic yearAndWeeks;
//@dynamic primitiveTimeStamp;
//@dynamic primitiveSectionIdentifier;

//#pragma mark - Transient properties
//
//- (NSString *)sectionIdentifier {
//    // Create and cache the section identifier on demand.
//    
//    [self willAccessValueForKey:@"sectionIdentifier"];
//    NSString *tmp = [self primitiveSectionIdentifier];
//    [self didAccessValueForKey:@"sectionIdentifier"];
//    
//    if (!tmp) {
//        /*
//         Sections are organized by month and year. Create the section identifier as a string representing the number (year * 1000) + month; this way they will be correctly ordered chronologically regardless of the actual name of the month.
//         */
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        
//        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[self createTime]];
//        
////        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
////        // 时区为北京时间
////        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
////        [dateFormatter setTimeZone:gmt];
////        NSString *timeStamp = [dateFormatter stringFromDate:[self createTime]];
//        
//        tmp = [NSString stringWithFormat:@"%d", ([components year] * 1000) + [components month]];
//        [self setPrimitiveSectionIdentifier:tmp];
//    }
//    
//    return tmp;
//}
//
//
//#pragma mark - Time stamp setter
//
//- (void)setCreateTime:(NSDate *)createTime {
//    // If the time stamp changes, the section identifier become invalid.
//    [self willChangeValueForKey:@"createTime"];
//    [self setPrimitiveTimeStamp:createTime];
//    [self didChangeValueForKey:@"createTime"];
//    
//    [self setPrimitiveSectionIdentifier:nil];
//}
//
//
//#pragma mark - Key path dependencies
//
//+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
//    // If the value of timeStamp changes, the section identifier may change as well.
//    return [NSSet setWithObject:@"createTime"];
//}

@end

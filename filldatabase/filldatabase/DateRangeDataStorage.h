//
//  CalendarDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DateRangeDataStorage : NSObject

- (id) initWithDate: (NSDate *)dateStart
          withNotes: (BOOL) displayNotes
          countDays: (NSNumber *)count;
- (NSString *) buildSqlQuery;
- (void) getNotesInRangeFromDatabase;
- (void) sendErrorNotification:(NSString *)message;
- (void) getNotesForDateRangeFromSinglePList;
- (void) getNotesForDateRangeFromSingleBinaryPList;
- (void) getNotesForDateRangeFromMultiplePList;
- (void) getNotesForDateRangeFromMultipleBinaryPlist;

@property NSDate *dateStart;
@property BOOL displayNotes;
@property NSNumber *daysCount;
@property NSString *columns;

@end

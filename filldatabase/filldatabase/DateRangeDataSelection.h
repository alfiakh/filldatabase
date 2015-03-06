//
//  CalendarDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DateRangeDataSelection : NSObject

- (id) initWithDate: (NSDate *)dateStart
          withNotes: (BOOL) displayNotes
          countDays: (NSNumber *)count;
- (NSString *) buildSqlQuery;
- (void) getNotesForDateRangeFromDataBase: (NSTimer *) timer;
- (void) sendErrorNotification:(NSString *)message;
- (void) getNotesForDateRangeFromSinglePList: (NSTimer *) timer;
- (void) getNotesForDateRangeFromSingleBinaryPList: (NSTimer *) timer;
- (void) getNotesForDateRangeFromMultiplePList: (NSTimer *) timer;
- (void) getNotesForDateRangeFromMultipleBinaryPList: (NSTimer *) timer;

@property NSDate *dateStart;
@property BOOL displayNotes;
@property NSNumber *daysCount;
@property NSString *columns;

@end

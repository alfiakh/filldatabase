//
//  CalendarDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface CalendarDataStorage : NSObject

- (id) initWithDate: (NSDate *)dateStart
          withNotes: (BOOL) displayNotes;
- (NSString *) buildQuery;
- (void) executeNotesForCalendar;
- (void) sendErrorNotification:(NSString *)message;

@property NSDate *dateStart;
@property BOOL displayNotes;

@end

//
//  CalendarDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarDataStorage : NSObject

- (id) initWithDate: (NSDate *)dateStart;
- (NSString *) buildQuery;
- (void) executeNotesForCalendar;

@property NSDate *dateStart;

@end

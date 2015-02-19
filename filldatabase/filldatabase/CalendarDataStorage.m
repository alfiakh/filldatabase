//
//  CalendarDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "CalendarDataStorage.h"

@implementation CalendarDataStorage

- (id) initWithDate:(NSDate *)dateStart {
    self = [super init];
    if (self) {
        self.dateStart = dateStart;
    }
    return self;
}

- (NSString *) buildQuery {
    return @"";
}

- (void) executeNotesForCalendar {
    
}
@end

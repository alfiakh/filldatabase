//
//  FirstTestCase.m
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "FirstTestCase.h"
#import "DateRangeDataStorage.h"
#import "NotepadDataStorage.h"
#import "AllDefines.h"

#define CR @"create_TS"
#define MO @"modify_TS"

@implementation FirstTestCase

- (id) init {
    self = [super init];
    if (self) {
        [self run];
    }
    return self;
}

- (void) sendDoneNotification: (NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TastCaseFinishedNotification"
         object:nil
         userInfo:@{@"message": message}];
    });
}

- (void) run {
    NotepadDataStorage *notepadStorage = [[NotepadDataStorage alloc]
                                          initWithOrder:CR
                                          withNotes:YES
                                          withFutureEvents:YES
                                          withPastEvents:YES];
    DateRangeDataStorage *calendarStorage = [[DateRangeDataStorage alloc]
                                             initWithDate:[NSDate date]
                                             withNotes:YES
                                             countDays:@7];
    DateRangeDataStorage *monthCalendarStorage = [[DateRangeDataStorage alloc]
                                                  initWithDate:[NSDate date]
                                                  withNotes:NO
                                                  countDays:@42];
    DateRangeDataStorage *diaryStorage = [[DateRangeDataStorage alloc]
                                          initWithDate:[NSDate date]
                                          withNotes:YES
                                          countDays:@1];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //это sqlite
        TICK;
        [notepadStorage getNotesForNotepadFromDatabase];
        [calendarStorage getNotesInRangeFromDatabase];
        [monthCalendarStorage getNotesInRangeFromDatabase];
        [calendarStorage getNotesInRangeFromDatabase];
        [diaryStorage getNotesInRangeFromDatabase];
        [calendarStorage getNotesInRangeFromDatabase];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished SQLite %@", tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //это single
        TICK;
        [notepadStorage getNotesForNotepadFromSinglePList];
        [calendarStorage getNotesForDateRangeFromSinglePList];
        [monthCalendarStorage getNotesForDateRangeFromSinglePList];
        [calendarStorage getNotesForDateRangeFromSinglePList];
        [diaryStorage getNotesForDateRangeFromSinglePList];
        [calendarStorage getNotesForDateRangeFromSinglePList];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished S PL %@", tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //это single binary
        TICK;
        [notepadStorage getNotesForNotepadFromSingleBinaryPList];
        [calendarStorage getNotesForDateRangeFromSingleBinaryPList];
        [monthCalendarStorage getNotesForDateRangeFromSingleBinaryPList];
        [calendarStorage getNotesForDateRangeFromSingleBinaryPList];
        [diaryStorage getNotesForDateRangeFromSingleBinaryPList];
        [calendarStorage getNotesForDateRangeFromSingleBinaryPList];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished SB PL %@", tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //это multiple
        TICK;
        [notepadStorage getNotesForNotepadFromMultiplePList];
        [calendarStorage getNotesForDateRangeFromMultiplePList];
        [monthCalendarStorage getNotesForDateRangeFromMultiplePList];
        [calendarStorage getNotesForDateRangeFromMultiplePList];
        [diaryStorage getNotesForDateRangeFromMultiplePList];
        [calendarStorage getNotesForDateRangeFromMultiplePList];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished M PL %@", tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //это miltiple binary
        TICK;
        [notepadStorage getNotesForNotepadFromSingleBinaryPList];
        [calendarStorage getNotesForDateRangeFromMultipleBinaryPlist];
        [monthCalendarStorage getNotesForDateRangeFromMultipleBinaryPlist];
        [calendarStorage getNotesForDateRangeFromMultipleBinaryPlist];
        [diaryStorage getNotesForDateRangeFromMultipleBinaryPlist];
        [calendarStorage getNotesForDateRangeFromMultipleBinaryPlist];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished MB PL %@", tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
}

@end

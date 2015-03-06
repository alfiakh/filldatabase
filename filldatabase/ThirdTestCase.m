//
//  ThirdTestCase.m
//  filldatabase
//
//  Created by Alfiya on 27.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ThirdTestCase.h"
#import "AllDefines.h"

#define CR @"create_TS"
#define MO @"modify_TS"

@implementation ThirdTestCase {
    dispatch_queue_t _testCaseQUeue;
    BOOL _timerFired;
}

- (void) callTestCaseWithStoraType: (NSTimer *) timer {
    __block NSString *storageType = timer.userInfo[@"storageType"];
    dispatch_async(_testCaseQUeue, ^(void) {
        self.stepOvered = YES;
        SEL getNotesForNotepadSelector = [super getNotepadSelectorWithStorageType:storageType];
        SEL getNotesForDateRangeSelector = [super getDateRangeSelectorWithStorageType:storageType];
        TICK;
        [super runStepStorageWithSelector:getNotesForNotepadSelector
                               withTarget:@"notepadStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"calendarStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"diaryStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"diaryStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"diaryStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"monthCalendarStorage"];
        [super runStepStorageWithSelector:getNotesForDateRangeSelector
                               withTarget:@"calendarStorage"];
        TACK;
        NSString *message = [NSString stringWithFormat:@"3rd TC finished %@ %@", storageType, tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
}

- (void) run {
    self.notepadStorage = [[NotepadDataSelection alloc]
                           initWithOrder:CR
                           withNotes:YES
                           withFutureEvents:NO
                           withPastEvents:YES];
    self.calendarStorage = [[DateRangeDataSelection alloc]
                            initWithDate:[NSDate date]
                            withNotes:YES
                            countDays:@7];
    self.monthCalendarStorage = [[DateRangeDataSelection alloc]
                                 initWithDate:[NSDate date]
                                 withNotes:NO
                                 countDays:@42];
    self.diaryStorage = [[DateRangeDataSelection alloc]
                         initWithDate:[NSDate date]
                         withNotes:YES
                         countDays:@1];
    NSTimer *timer;
    _timerFired = YES;
    for (NSString *dataStorage in DATA_STORAGES) {
        if (!_timerFired) {
            NSLog(@"sleep");
            sleep(0.1);
        }
        _timerFired = NO;
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self selector:@selector(callTestCaseWithStoraType:)
                                      userInfo:@{@"storageType": dataStorage}
                                       repeats:NO];
        [timer fire];
    }
}

@end

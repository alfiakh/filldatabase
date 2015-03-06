//
//  FirstTestCase.m
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "FirstTestCase.h"
#import "AllDefines.h"

// оказывается я ленивая задница
#define CR @"create_TS"
#define MO @"modify_TS"

@implementation FirstTestCase {
    dispatch_queue_t _testCaseQUeue;
    BOOL _timerFired;
    NSMutableArray *_casesDone;
}

- (id) init {
    self = [super init];
    if (self) {
        _testCaseQUeue = dispatch_queue_create("com.testcases.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) callTestCaseWithStoraType: (NSTimer *) timer {
    NSString *storageType = timer.userInfo[@"storageType"];
    self.stepOvered = YES;
    SEL getNotesForNotepadSelector = [super getNotepadSelectorWithStorageType:storageType];
    SEL getNotesForDateRangeSelector = [super getDateRangeSelectorWithStorageType:storageType];
    TICK;
    [super runStepStorageWithSelector:getNotesForNotepadSelector withTarget:@"notepadStorage"];
    [super runStepStorageWithSelector:getNotesForDateRangeSelector withTarget:@"calendarStorage"];
    [super runStepStorageWithSelector:getNotesForDateRangeSelector withTarget:@"monthCalendarStorage"];
    [super runStepStorageWithSelector:getNotesForDateRangeSelector withTarget:@"calendarStorage"];
    [super runStepStorageWithSelector:getNotesForDateRangeSelector withTarget:@"diaryStorage"];
    [super runStepStorageWithSelector:getNotesForDateRangeSelector withTarget:@"calendarStorage"];
    TACK;
    NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
    [self sendDoneNotification:message];
    _timerFired = YES;
    [_casesDone addObject:storageType];
}

- (void) run {
    self.notepadStorage = [[NotepadDataSelection alloc]
                           initWithOrder:CR
                           withNotes:YES
                           withFutureEvents:YES
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
    
    _timerFired = YES;
    dispatch_async(_testCaseQUeue, ^(void) {
        NSTimer *timer;
        for (NSString *dataStorage in DATA_STORAGES) {
            while (!_timerFired) {
                NSLog(@"sleep");
                sleep(0.1);
            }
            _timerFired = NO;
            timer = [NSTimer timerWithTimeInterval:0
                                            target:self
                                          selector:@selector(callTestCaseWithStoraType:)
                                          userInfo:@{@"storageType": dataStorage}
                                           repeats:NO];
            [timer fire];
        }
        while (!_timerFired) {
            sleep(0.1);
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

@end

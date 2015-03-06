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
}

- (id) init {
    self = [super init];
    if (self) {
        _testCaseQUeue = dispatch_queue_create("com.testcases.queue", DISPATCH_QUEUE_SERIAL);
        [self run];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(updateStepOvered)
         name:@"TestCaseStepOveredNotification"
         object:nil];
    }
    return self;
}

- (void) updateStepOvered {
    self.stepOvered = YES;
}

- (void) sendDoneNotification: (NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TastCaseFinishedNotification"
         object:nil
         userInfo:@{@"message": message}];
    });
}

- (void) runStepStorageWithSelector: (SEL) selector
                                withTarger: (NSString *) targer {
    while (!self.stepOvered) {
        NSLog(@"sleep");
        sleep(0.1);
    }
    self.stepOvered = NO;
    NSTimer *timer;
    if ([targer isEqualToString:@"notepadStorage"]) {
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:selector
                                      userInfo:nil
                                       repeats:NO];
    }
    else if ([targer isEqualToString:@"calendarStorage"]) {
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.calendarStorage
                                      selector:selector
                                      userInfo:nil
                                       repeats:NO];
    }
    else if ([targer isEqualToString:@"monthCalendarStorage"]) {
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.monthCalendarStorage
                                      selector:selector
                                      userInfo:nil
                                       repeats:NO];
    }
    else if ([targer isEqualToString:@"diaryStorage"]) {
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.diaryStorage
                                      selector:selector
                                      userInfo:nil
                                       repeats:NO];
    }
    else {
        [self sendDoneNotification:@"Выслан некорректный таргет для таймера"];
        self.stepOvered = YES;
        return;
    }
    [timer fire];
}

- (void) callTestCaseWithStoraType: (NSTimer *) timer {
    __block NSString *storageType = timer.userInfo[@"storageType"];
    dispatch_async(_testCaseQUeue, ^(void) {
        NSString *getNotesForNotepadSelectorNsame = [NSString stringWithFormat:@"getNotesForNotepadFrom%@:", storageType];
        SEL getNotesForNotepadSelector = NSSelectorFromString(getNotesForNotepadSelectorNsame);
        NSString *getNotesForDateRangeSelectorNsame = [NSString stringWithFormat:@"getNotesForDateRangeFrom%@:", storageType];
        SEL getNotesForDateRangeSelector = NSSelectorFromString(getNotesForDateRangeSelectorNsame);
        if (![self.notepadStorage respondsToSelector:getNotesForNotepadSelector]) {
            NSLog(@"Notepad storage doesn't respond to selector %@", getNotesForNotepadSelectorNsame);
            return;
        }
        if (![self.monthCalendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
            NSLog(@"Month calendar storage doesn't respond to selector %@", getNotesForDateRangeSelectorNsame);
            return;
        }
        if (![self.calendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
            NSLog(@"Calendar storage doesn't respond to selector%@", getNotesForDateRangeSelectorNsame);
            return;
        }
        if (![self.monthCalendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
            NSLog(@"Diary storage doesn't respond to selector %@", getNotesForDateRangeSelectorNsame);
            return;
        }
        self.stepOvered = YES;
        TICK;
        [self runStepStorageWithSelector:getNotesForNotepadSelector withTarger:@"notepadStorage"];
        [self runStepStorageWithSelector:getNotesForDateRangeSelector withTarger:@"calendarStorage"];
        [self runStepStorageWithSelector:getNotesForDateRangeSelector withTarger:@"monthCalendarStorage"];
        [self runStepStorageWithSelector:getNotesForDateRangeSelector withTarger:@"calendarStorage"];
        [self runStepStorageWithSelector:getNotesForDateRangeSelector withTarger:@"diaryStorage"];
        [self runStepStorageWithSelector:getNotesForDateRangeSelector withTarger:@"calendarStorage"];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
        [self sendDoneNotification:message];
        _timerFired = YES;
    });
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

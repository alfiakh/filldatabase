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

- (void) callTestCaseWithStoraType: (NSTimer *) timer {
//    NSString *storageType = timer.userInfo[@"storageType"];
//    dispatch_async(_testCaseQUeue, ^(void) {
//        if ([storageType isEqualToString:@"DataBase"]) {
//            TICK;
//            [self.notepadStorage getNotesForNotepadFromDataBase];
//            [self.calendarStorage getNotesForDateRangeFromDataBase];
//            [self.monthCalendarStorage getNotesForDateRangeFromDataBase];
//            [self.calendarStorage getNotesForDateRangeFromDataBase];
//            [self.diaryStorage getNotesForDateRangeFromDataBase];
//            [self.calendarStorage getNotesForDateRangeFromDataBase];
//            TACK;
//            NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
//            [self sendDoneNotification:message];
//        }
//        else if ([storageType isEqualToString:@"SinglePList"]) {
//            TICK;
//            [self.notepadStorage getNotesForNotepadFromSinglePList];
//            [self.calendarStorage getNotesForDateRangeFromSinglePList];
//            [self.monthCalendarStorage getNotesForDateRangeFromSinglePList];
//            [self.calendarStorage getNotesForDateRangeFromSinglePList];
//            [self.diaryStorage getNotesForDateRangeFromSinglePList];
//            [self.calendarStorage getNotesForDateRangeFromSinglePList];
//            TACK;
//            NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
//            [self sendDoneNotification:message];
//        }
//        else if ([storageType isEqualToString:@"SingleBinaryPList"]) {
//            TICK;
//            [self.notepadStorage getNotesForNotepadFromSingleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromSingleBinaryPList];
//            [self.monthCalendarStorage getNotesForDateRangeFromSingleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromSingleBinaryPList];
//            [self.diaryStorage getNotesForDateRangeFromSingleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromSingleBinaryPList];
//            TACK;
//            NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
//            [self sendDoneNotification:message];
//        }
//        else if ([storageType isEqualToString:@"MultiplePList"]) {
//            TICK;
//            [self.notepadStorage getNotesForNotepadFromMultiplePList];
//            [self.calendarStorage getNotesForDateRangeFromMultiplePList];
//            [self.monthCalendarStorage getNotesForDateRangeFromMultiplePList];
//            [self.calendarStorage getNotesForDateRangeFromMultiplePList];
//            [self.diaryStorage getNotesForDateRangeFromMultiplePList];
//            [self.calendarStorage getNotesForDateRangeFromMultiplePList];
//            TACK;
//            NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
//            [self sendDoneNotification:message];
//        }
//        else if ([storageType isEqualToString:@"MultipleBinaryPList"]) {
//            TICK;
//            [self.notepadStorage getNotesForNotepadFromMultipleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromMultipleBinaryPList];
//            [self.monthCalendarStorage getNotesForDateRangeFromMultipleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromMultipleBinaryPList];
//            [self.diaryStorage getNotesForDateRangeFromMultipleBinaryPList];
//            [self.calendarStorage getNotesForDateRangeFromMultipleBinaryPList];
//            TACK;
//            NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
//            [self sendDoneNotification:message];
//        }
//        else {
//            [self sendDoneNotification:@"Прислан некорректный тип стореджа"];
//        }
//        _timerFired = YES;
//    });
//    dispatch_async(_testCaseQUeue, ^(void) {
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    [self.notepadStorage getNotesForNotepadFromSinglePList];
//    });
    dispatch_async(_testCaseQUeue, ^(void) {
        NSTimer *timer;
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
        timer = [NSTimer timerWithTimeInterval:0
                                        target:self.notepadStorage
                                      selector:@selector(getNotesForNotepadFromSinglePList)
                                      userInfo:nil
                                       repeats:NO];
        [timer fire];
        sleep(2);
    });
}

- (void) run {
    self.notepadStorage = [[NotepadDataStorage alloc]
                           initWithOrder:CR
                           withNotes:YES
                           withFutureEvents:YES
                           withPastEvents:YES];
    self.calendarStorage = [[DateRangeDataStorage alloc]
                            initWithDate:[NSDate date]
                            withNotes:YES
                            countDays:@7];
    self.monthCalendarStorage = [[DateRangeDataStorage alloc]
                                 initWithDate:[NSDate date]
                                 withNotes:NO
                                 countDays:@42];
    self.diaryStorage = [[DateRangeDataStorage alloc]
                         initWithDate:[NSDate date]
                         withNotes:YES
                         countDays:@1];
    NSTimer *timer;
    _timerFired = YES;
    for (NSString *dataStorage in @[@"SinglePList"]) {
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

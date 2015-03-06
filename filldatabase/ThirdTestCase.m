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

- (void) callTestCaseWithStoraType: (NSString *) storageType {
    dispatch_async(_testCaseQUeue, ^(void) {
        NSString *notepadStorageSelectorName = [NSString stringWithFormat:@"getNotesForNotepadFrom%@", storageType];
        SEL notepadStorageSelector = NSSelectorFromString(notepadStorageSelectorName);
        NSString *dateRangeStorageSelectorName = [NSString stringWithFormat:@"getNotesForDateRangeFrom%@", storageType];
        SEL dateRangeStorageSelector = NSSelectorFromString(dateRangeStorageSelectorName);
        TICK;
        [self.notepadStorage performSelector:notepadStorageSelector];
        [self.calendarStorage performSelector:dateRangeStorageSelector];
        [self.diaryStorage performSelector:dateRangeStorageSelector];
        [self.diaryStorage performSelector:dateRangeStorageSelector];
        [self.diaryStorage performSelector:dateRangeStorageSelector];
        [self.monthCalendarStorage performSelector:dateRangeStorageSelector];
        [self.calendarStorage performSelector:dateRangeStorageSelector];
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
    for (NSString *dataStorage in DATA_STORAGES) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end

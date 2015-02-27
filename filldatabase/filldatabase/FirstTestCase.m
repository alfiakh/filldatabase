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

- (void) callTestCaseWithStoraType: (NSString *) storageType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *notepadStorageSelectorName = [NSString stringWithFormat:@"getNotesForNotepadFrom%@", storageType];
        SEL notepadStorageSelector = NSSelectorFromString(notepadStorageSelectorName);
        NSString *dateRangeStorageSelectorName = [NSString stringWithFormat:@"getNotesForDateRangeFrom%@", storageType];
        SEL dateRangeStorageSelector = NSSelectorFromString(dateRangeStorageSelectorName);
        TICK;
        [self.notepadStorage performSelector:notepadStorageSelector];
        [self.calendarStorage performSelector:dateRangeStorageSelector];
        [self.monthCalendarStorage performSelector:dateRangeStorageSelector];
        [self.calendarStorage performSelector:dateRangeStorageSelector];
        [self.diaryStorage performSelector:dateRangeStorageSelector];
        [self.calendarStorage performSelector:dateRangeStorageSelector];
        TACK;
        NSString *message = [NSString stringWithFormat:@"1st TC finished %@ %@", storageType, tackInfo[@"time"]];
        [self sendDoneNotification:message];
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
    for (NSString *dataStorage in DATA_STORAGES) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end
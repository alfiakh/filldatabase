//
//  BaseTestCase.m
//  filldatabase
//
//  Created by Alfiya on 06.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "BaseSelectionTestCase.h"

@implementation BaseSelectionTestCase

- (id) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(updateStepOvered)
         name:@"TestCaseStepOveredNotification"
         object:nil];
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

- (void) updateStepOvered {
    self.stepOvered = YES;
}

- (void) runStepStorageWithSelector: (SEL) selector
                         withTarget: (NSString *) targer {
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

- (SEL) getDateRangeSelectorWithStorageType: (NSString *) storageType{
    NSString *getNotesForDateRangeSelectorNsame = [NSString stringWithFormat:@"getNotesForDateRangeFrom%@:", storageType];
    SEL getNotesForDateRangeSelector = NSSelectorFromString(getNotesForDateRangeSelectorNsame);
    if (![self.monthCalendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
        NSLog(@"Month calendar storage doesn't respond to selector %@", getNotesForDateRangeSelectorNsame);
        self.stepOvered = YES;
        return nil;
    }
    if (![self.calendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
        NSLog(@"Calendar storage doesn't respond to selector%@", getNotesForDateRangeSelectorNsame);
        self.stepOvered = YES;
        return nil;
    }
    if (![self.monthCalendarStorage respondsToSelector:getNotesForDateRangeSelector]) {
        NSLog(@"Diary storage doesn't respond to selector %@", getNotesForDateRangeSelectorNsame);
        self.stepOvered = YES;
        return nil;
    }
    return  getNotesForDateRangeSelector;
}

- (SEL) getNotepadSelectorWithStorageType: (NSString *) storageType{
    NSString *getNotesForNotepadSelectorNsame = [NSString stringWithFormat:@"getNotesForNotepadFrom%@:", storageType];
    SEL getNotesForNotepadSelector = NSSelectorFromString(getNotesForNotepadSelectorNsame);
    if (![self.notepadStorage respondsToSelector:getNotesForNotepadSelector]) {
        NSLog(@"Notepad storage doesn't respond to selector %@", getNotesForNotepadSelectorNsame);
        self.stepOvered = YES;
        return nil;
    }
    return getNotesForNotepadSelector;
}
    
@end

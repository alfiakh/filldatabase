//
//  BaseTestCase.h
//  filldatabase
//
//  Created by Alfiya on 06.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotepadDataSelection.h"
#import "DateRangeDataSelection.h"

@interface BaseSelectionTestCase : NSObject

- (void) sendDoneNotification: (NSString *) message;
- (void) runStepStorageWithSelector: (SEL) selector
                         withTarget: (NSString *) target;
- (SEL) getDateRangeSelectorWithStorageType: (NSString *) storageType;
- (SEL) getNotepadSelectorWithStorageType: (NSString *) storageType;

@property NotepadDataSelection *notepadStorage;
@property DateRangeDataSelection *calendarStorage;
@property DateRangeDataSelection *monthCalendarStorage;
@property DateRangeDataSelection *diaryStorage;
@property BOOL stepOvered;

@end

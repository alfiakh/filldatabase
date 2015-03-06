//
//  FirstTestCase.h
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateRangeDataSelection.h"
#import "NotepadDataSelection.h"

@interface FirstTestCase : NSObject

@property NotepadDataSelection *notepadStorage;
@property DateRangeDataSelection *calendarStorage;
@property DateRangeDataSelection *monthCalendarStorage;
@property DateRangeDataSelection *diaryStorage;
@property BOOL stepOvered;
@end

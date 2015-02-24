//
//  FirstTestCase.h
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateRangeDataStorage.h"
#import "NotepadDataStorage.h"

@interface FirstTestCase : NSObject

@property NotepadDataStorage *notepadStorage;
@property DateRangeDataStorage *calendarStorage;
@property DateRangeDataStorage *monthCalendarStorage;
@property DateRangeDataStorage *diaryStorage;

@end

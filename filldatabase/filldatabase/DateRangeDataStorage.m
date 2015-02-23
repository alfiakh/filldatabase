//
//  CalendarDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DateRangeDataStorage.h"
#import "AllDefines.h"
#define CALENDAR_COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS"
#define INDICATOR_COLUMNS @"event_start_TS, event_end_TS"
#define DIARY_COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS, event_alarms, create_TS, modify_TS, modify_devID, create_devID"

@implementation DateRangeDataStorage

- (id) initWithDate: (NSDate *)dateStart
          withNotes: (BOOL) displayNotes
          countDays: (NSNumber *)count {
    self = [super init];
    if (self) {
        self.dateStart = dateStart;
        self.displayNotes = displayNotes;
        self.daysCount = count;
        if ([count isEqualToNumber: @7]){
            // для календаря
            // назначаем колонки
            self.columns = CALENDAR_COLUMNS;
        }
        else if ([count isEqualToNumber: @1]) {
            // для ежедневника
            // назначаем колонки
            self.columns = DIARY_COLUMNS;
        }
        else if ([count isEqualToNumber:@42]) {
            // для месячного календаря
            // назначаем колонки
            self.columns = INDICATOR_COLUMNS;
        }
        else {
            return nil;
        }
    }
    return self;
}

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"CalendarDataStorageErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (NSString *) buildQuery {
    NSMutableString *query = [NSMutableString
                              stringWithFormat:@"SELECT %@ FROM note",
                              self.columns];
    NSMutableArray *conditions = [NSMutableArray arrayWithArray:@[]];
    int tsStart = [self.dateStart timeIntervalSince1970];
    long tsEnd = tsStart + 60 * 60 * 24 * (long)[self.daysCount integerValue];
    [query appendString:@" WHERE"];
    if (!self.displayNotes) {
        NSString *notesDisplayCondition = [NSString stringWithFormat: @" event_enable <> \"0\" AND modify_TS BETWEEN %i AND %ld", tsStart, tsEnd];
        [conditions addObject:notesDisplayCondition];
    }
    NSString *eventDisplayCondition = [NSString stringWithFormat: @" event_enable <> \"1\" AND event_start_TS BETWEEN %i AND %ld OR event_enable <> \"1\" AND event_end_TS BETWEEN %i AND %ld", tsStart, tsEnd, tsStart, tsEnd];
    [conditions addObject:eventDisplayCondition];
    [query appendString:[conditions componentsJoinedByString:@" OR "]];
    [query appendString:@";"];
    NSLog(@"%@", query);
    return query;
}

- (void) getNotesInRangeFromDatabase {
    NSString *query = [self buildQuery];
    NSString *databasePath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        FMDatabase *database = [FMDatabase databaseWithPath:databasePath];
        BOOL databaseOpened = [database open];
        if (databaseOpened) {
            database.traceExecution = YES;
            FMResultSet *resultNotes = [database executeQuery:query];
            NSLog(@"%@", resultNotes);
        }
        else {
            [self sendErrorNotification:@"Сорь, не удалось открыть базу"];
        }
    }
    else {
        [self sendErrorNotification:@"Сорь, базы нет"];
    }
}

@end

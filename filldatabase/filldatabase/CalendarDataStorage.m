//
//  CalendarDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "CalendarDataStorage.h"
#import "AllDefines.h"
#define COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS, event_alarms, create_TS, modify_TS, modify_devID, create_devID"

@implementation CalendarDataStorage

- (id) initWithDate:(NSDate *)dateStart
          withNotes:(BOOL)displayNotes {
    self = [super init];
    if (self) {
        self.dateStart = dateStart;
        self.displayNotes = displayNotes;
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
                              COLUMNS];
    NSMutableArray *conditions = [NSMutableArray arrayWithArray:@[]];
    int tsStart = [self.dateStart timeIntervalSince1970];
    int tsEnd = tsStart + 60 * 60 * 24 * 7;
    [query appendString:@" WHERE"];
    if (!self.displayNotes) {
        NSString *notesDisplayCondition = [NSString stringWithFormat: @" event_enable <> \"0\" AND modify_TS BETWEEN %i AND %i", tsStart, tsEnd];
        [conditions addObject:notesDisplayCondition];
    }
    NSString *eventDisplayCondition = [NSString stringWithFormat: @" event_enable <> \"1\" AND event_start_TS BETWEEN %i AND %i OR event_enable <> \"1\" AND event_end_TS BETWEEN %i AND %i", tsStart, tsEnd, tsStart, tsEnd];
    [conditions addObject:eventDisplayCondition];
    [query appendString:[conditions componentsJoinedByString:@" OR "]];
    [query appendString:@";"];
    NSLog(@"%@", query);
    return query;
}

- (void) executeNotesForCalendar {
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

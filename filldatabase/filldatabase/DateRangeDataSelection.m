//
//  CalendarDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DateRangeDataSelection.h"
#import "AllDefines.h"
#define CALENDAR_COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS"
#define INDICATOR_COLUMNS @"event_start_TS, event_end_TS"
#define DIARY_COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS, event_alarms, create_TS, modify_TS, modify_devID, create_devID"

@implementation DateRangeDataSelection

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
     postNotificationName: @"StorageErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (NSString *) collectBetweenConditionWIthType: (NSString *) type
                                   withKeyName: (NSString *) keyName
                                withLowerBound: (int) low
                               withHigherBound: (long) high{
    if ([type isEqualToString:@"sql"]) {
        return [NSString stringWithFormat: @"%@ BETWEEN %i AND %ld", keyName, low, high];
    }
    else if ([type isEqualToString:@"predicate"]){
        return [NSString stringWithFormat: @"(%i <= %@) && (%@ <= %ld)", low, keyName, keyName, high];
    }
    else {
        [self sendErrorNotification:@"Задан непривильный тип для билда кондишнов"];
        return [NSString string];
    }
}

- (NSMutableString *) addDateRangeConditionsToQuery: (NSMutableString *) query
                                           withType: (NSString *) type {
    NSMutableArray *conditions = [NSMutableArray arrayWithArray:@[]];
    int tsStart = [self.dateStart timeIntervalSince1970];
    long tsEnd = tsStart + 60 * 60 * 24 * (long)[self.daysCount integerValue];
    if (!self.displayNotes) {
        NSMutableString *notesDisplayCondition = [NSMutableString stringWithFormat: @"event_enable <> \"0\" AND "];
        [notesDisplayCondition
         appendString:[self collectBetweenConditionWIthType:type
                                                withKeyName:@"modify_TS"
                                             withLowerBound:tsStart
                                            withHigherBound:tsEnd]];
        [conditions addObject:notesDisplayCondition];
    }
    NSMutableString *eventDisplayCondition = [NSMutableString stringWithFormat: @"event_enable <> \"1\" AND "];
    [eventDisplayCondition
     appendString:[self collectBetweenConditionWIthType:type
                                            withKeyName:@"event_start_TS"
                                         withLowerBound:tsStart
                                        withHigherBound:tsEnd]];
    [eventDisplayCondition appendString:@" OR event_enable <> \"1\" AND "];
    [eventDisplayCondition
     appendString:[self collectBetweenConditionWIthType:type
                                            withKeyName:@"event_start_TS"
                                         withLowerBound:tsStart
                                        withHigherBound:tsEnd]];
    [conditions addObject:eventDisplayCondition];
    [query appendString:[conditions componentsJoinedByString:@" OR "]];
    return query;
}

- (NSString *) buildSqlQuery {
    NSMutableString *query = [NSMutableString
                              stringWithFormat:@"SELECT %@ FROM note",
                              self.columns];
    [query appendString:@" WHERE "];
    [self addDateRangeConditionsToQuery:query withType:@"sql"];
    [query appendString:@";"];
    return query;
}

- (void) getNotesForDateRangeFromDataBase: (NSTimer *) timer {
    NSString *query = [self buildSqlQuery];
    if([[NSFileManager defaultManager] fileExistsAtPath:DATABASE_PATH]) {
        FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
        BOOL databaseOpened = [database open];
        if (databaseOpened) {
            database.traceExecution = YES;
            [database executeQuery:query];
        }
        else {
            [self sendErrorNotification:@"Сорь, не удалось открыть базу"];
        }
    }
    else {
        [self sendErrorNotification:@"Сорь, базы нет"];
    }
}

- (NSPredicate *) buildPredicate {
    NSMutableString *predicateBaseString = [self addDateRangeConditionsToQuery:[NSMutableString string] withType:@"predicate"];
    NSPredicate *notepadPredicate = [NSPredicate predicateWithFormat:predicateBaseString];
    return notepadPredicate;
}

- (NSArray *) applyPredicateToContentOfFile: (NSString *)pathPath {
    NSArray *plistNotes = [NSArray arrayWithContentsOfFile:pathPath];
    NSPredicate *notepadFilterPredicate = [self buildPredicate];
    NSArray *filteredNotes = [plistNotes filteredArrayUsingPredicate:notepadFilterPredicate];
    return filteredNotes;
}

- (void) getNotesForDateRangeFromSinglePList: (NSTimer *) timer {
    TICK;
    [self applyPredicateToContentOfFile:SINGLE_PLIST_PATH];
    TACK;
    NSLog(@"%@", tackInfo);
}

- (void) getNotesForDateRangeFromSingleBinaryPList: (NSTimer *) timer {
    TICK;
    [self applyPredicateToContentOfFile:SINGLE_PLIST_BINARY_PATH];
    TACK;
    NSLog(@"%@", tackInfo);
}

-(NSArray *) collectMultipleNotesWithPath: (NSString *) notesFolder
                                  withIDs: (NSArray *) IDs {
    NSMutableArray *notes = [NSMutableArray array];
    for (NSString *ID in IDs) {
        NSString *plistPath = [notesFolder stringByAppendingPathComponent:ID];
        NSDictionary *note = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        [notes addObject:note];
    }
    return notes;
}

- (void) getNotesForDateRangeFromMultiplePList: (NSTimer *) timer {
    TICK;
    NSString *singlePlistPath = HELPER_PLIST_PATH;
    NSArray *helperfilteredNotes = [self applyPredicateToContentOfFile:singlePlistPath];
    [self collectMultipleNotesWithPath:MULTIPLE_PLIST_FOLDER withIDs:helperfilteredNotes];
    TACK;
    NSLog(@"%@", tackInfo);
}

- (void) getNotesForDateRangeFromMultipleBinaryPList: (NSTimer *) timer {
    TICK;
    NSString *singlePlistPath = HELPER_BINARY_PLIST_PATH;
    NSArray *helperfilteredNotes = [self applyPredicateToContentOfFile:singlePlistPath];
    [self collectMultipleNotesWithPath:MULTIPLE_BINARY_PLIST_FOLDER withIDs:helperfilteredNotes];
    TACK;
    NSLog(@"%@", tackInfo);
}

@end

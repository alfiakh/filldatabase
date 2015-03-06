//
//  NotesDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "NotepadDataSelection.h"
#import "AllDefines.h"

#define COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS, event_alarms, create_TS, modify_TS, modify_devID, create_devID"

@implementation NotepadDataSelection

- (id) initWithOrder: (NSString *)order
           withNotes: (BOOL)displayNotes
    withFutureEvents: (BOOL)displayFutureEvents
      withPastEvents: (BOOL)displayPastEvents {
    if (self = [super init]) {
        self.order = order;
        self.displayNotes = displayNotes;
        self.displayFutureEvents = displayFutureEvents;
        self.displayPastEvents = displayPastEvents;
    }
    return self;
}

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"StorageErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (void) sendStepOveredNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"TestCaseStepOveredNotification"
     object: nil
     userInfo: nil];
}

- (NSMutableString *) addNotepadConditionsToQuery: (NSMutableString *) query {
    NSMutableArray *conditions = [NSMutableArray arrayWithArray:@[]];
    if (!self.displayNotes) {
        [conditions addObject:@"event_enable <> \"0\""];
    }
    int ts = [[NSDate date] timeIntervalSince1970];
    if (!self.displayFutureEvents && !self.displayPastEvents) {
        [conditions addObject:@"event_enable <> \"1\""];
    }
    else if (!self.displayPastEvents) {
        [conditions addObject:[NSString stringWithFormat:@"event_end_TS < %i", ts ]];
    }
    else if (!self.displayFutureEvents) {
        [conditions addObject:[NSString stringWithFormat:@"event_start_TS > %i", ts ]];
    }
    NSString *finalCondition = [conditions componentsJoinedByString:@" AND "];
    [query appendString:finalCondition];
    return query;
}

- (NSString *) buildSqlQuery {
    NSMutableString *query = [NSMutableString
                       stringWithFormat:@"SELECT %@ FROM note ",
                       COLUMNS];
    if (!self.displayNotes || !self.displayFutureEvents || !self.displayPastEvents) {
        [query appendString: @" WHERE "];
    }
    query = [self addNotepadConditionsToQuery:query];
    [query appendString:[NSString stringWithFormat:@" ORDER BY %@", self.order]];
    [query appendString:@";"];
    return query;
}

- (void) getNotesForNotepadFromDataBase: (NSTimer *) timer {
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
    [self sendStepOveredNotification];
}

- (NSPredicate *) buildPredicate {
    NSMutableString *predicateBaseString = [self addNotepadConditionsToQuery:[NSMutableString string]];
    if (![predicateBaseString isEqualToString:@""]) {
        NSPredicate *notepadPredicate = [NSPredicate predicateWithFormat:predicateBaseString];
        return notepadPredicate;
    }
    return nil;
}

- (NSArray *) applyPredicateToContentOfFile: (NSString *)pathPath {
    NSArray *plistNotes = [NSArray arrayWithContentsOfFile:pathPath];
    NSPredicate *notepadFilterPredicate = [self buildPredicate];
    if (!notepadFilterPredicate) {
        return plistNotes;
    }
    NSArray *filteredNotes = [plistNotes filteredArrayUsingPredicate:notepadFilterPredicate];
    return filteredNotes;
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

- (void) getNotesForNotepadFromSinglePList: (NSTimer *) timer {
    [self applyPredicateToContentOfFile:SINGLE_PLIST_PATH];
    [self sendStepOveredNotification];
}

- (void) getNotesForNotepadFromSingleBinaryPList: (NSTimer *) timer {
    [self applyPredicateToContentOfFile:SINGLE_PLIST_BINARY_PATH];
    [self sendStepOveredNotification];
}

- (void) getNotesForNotepadFromMultiplePList: (NSTimer *) timer {
    NSArray *helperfilteredNotes = [self applyPredicateToContentOfFile:HELPER_PLIST_PATH];
    [self collectMultipleNotesWithPath:MULTIPLE_PLIST_FOLDER withIDs:helperfilteredNotes];
    [self sendStepOveredNotification];
}

- (void) getNotesForNotepadFromMultipleBinaryPList: (NSTimer *) timer {
    NSArray *helperfilteredNotes = [self applyPredicateToContentOfFile:HELPER_BINARY_PLIST_PATH];
    [self collectMultipleNotesWithPath:MULTIPLE_BINARY_PLIST_FOLDER withIDs:helperfilteredNotes];
    [self sendStepOveredNotification];
}

@end

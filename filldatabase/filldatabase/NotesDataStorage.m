//
//  NotesDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "NotesDataStorage.h"
#import "AllDefines.h"
#import "FMDatabase.h"

#define COLUMNS @"ID, message, event_enable, event_start_TS, event_end_TS, event_alarms, create_TS, modify_TS, modify_devID, create_devID"

@implementation NotesDataStorage

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

- (NSString *) buildQuery {
    NSMutableString *query = [NSMutableString
                       stringWithFormat:@"SELECT %@ FROM note ",
                       COLUMNS];
    if (!self.displayNotes || !self.displayFutureEvents || !self.displayPastEvents) {
        [query appendString: @" WHERE "];
    }
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
    [query appendString:@" "];
    [query appendString:finalCondition];
    [query appendString:[NSString stringWithFormat:@" ORDER BY %@", self.order]];
    [query appendString:@";"];
    NSString *path = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
    database.traceExecution = YES;
    [database executeQuery:query];
    return query;
}

@end

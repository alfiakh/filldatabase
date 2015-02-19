//
//  NotesDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "NotesDataStorage.h"

@implementation NotesDataStorage

- (id) initWithOrder:(NSString *)order
            withNotes:(BOOL)displayNotes
     withFutureEvents:(BOOL)displayFutureEvents
       withPastEvents:(BOOL)displayPastEvents {
    if (self = [super init]) {
        self.displayNotes = displayNotes;
        self.displayFutureEvents = displayFutureEvents;
        self.displayPastEvents = displayPastEvents;
    }
    return self;
}

- (NSString *) buildQuery {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM note"];
    return query;
}

@end

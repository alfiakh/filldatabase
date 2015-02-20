//
//  NotesDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotepadDataStorage : NSObject

- (id) initWithOrder: (NSString *) order
            withNotes: (BOOL) displayNotes
     withFutureEvents: (BOOL) displayFutureEvents
       withPastEvents: (BOOL) displayPastEvents;
- (NSString *) buildQuery;
- (void) executeNotesForNotepad;
- (void) sendErrorNotification:(NSString *)message;

@property NSString *order;
@property BOOL displayNotes;
@property BOOL displayFutureEvents;
@property BOOL displayPastEvents;

@end

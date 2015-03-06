//
//  NotesDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotepadDataSelection : NSObject

- (id) initWithOrder: (NSString *) order
            withNotes: (BOOL) displayNotes
     withFutureEvents: (BOOL) displayFutureEvents
       withPastEvents: (BOOL) displayPastEvents;
- (NSMutableString *) addNotepadConditionsToQuery: (NSMutableString *) query;
- (NSString *) buildSqlQuery;
- (void) getNotesForNotepadFromDataBase: (NSTimer *) timer;
- (void) sendErrorNotification:(NSString *)message;
- (NSPredicate *) buildPredicate;
- (void) getNotesForNotepadFromSinglePList: (NSTimer *) timer;
- (void) getNotesForNotepadFromSingleBinaryPList: (NSTimer *) timer;
- (void) getNotesForNotepadFromMultiplePList: (NSTimer *) timer;
- (void) getNotesForNotepadFromMultipleBinaryPList: (NSTimer *) timer;

@property NSString *order;
@property BOOL displayNotes;
@property BOOL displayFutureEvents;
@property BOOL displayPastEvents;

@end

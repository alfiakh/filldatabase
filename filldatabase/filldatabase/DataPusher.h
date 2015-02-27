//
//  DataPusher.h
//  filldatabase
//
//  Created by Alfiya on 12.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DataPusher : NSObject

- (void) createDataBase;
- (void) createNoteTable;
- (void) deleteAllOldNotes;
- (void) pushNotesFromResponse: (NSArray *) notes;
- (void) sendErrorNotification: (NSString *) message;

@property FMDatabase *database;
@property NSMutableArray *notesToPush;
@property BOOL rollbacked;

@end

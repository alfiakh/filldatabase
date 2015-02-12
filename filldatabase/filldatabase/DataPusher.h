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
- (BOOL) createNoteTable;
- (BOOL) deleteAllOldNotes;
- (BOOL) pushNote: (NSDictionary *) note;
- (void) pushNotesFromResponse: (NSDictionary *) notes;

@property FMDatabase *database;
@property BOOL databaseExisted;
@property BOOL databaseOpened;
@property BOOL commitFailPanic;
@property BOOL rollbackFailPanic;
@property BOOL beginTransactionFailPanic;

@end

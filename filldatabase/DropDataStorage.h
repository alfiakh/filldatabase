//
//  DropDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDataStorage : NSObject

- (NSArray *) getIDsToDropFromDataBase;
- (NSArray *) getIDsToDropFromSinglePList;
- (NSArray *) getIDsToDropFromSingleBinaryPList;
- (NSArray *) getIDsToDropFromMultiplePList;
- (NSArray *) getIDsToDropFromMultipleBinaryPList;

- (void) dropNotesFromDataBasetWithNoteIDs: (NSArray *) noteIDs;
- (void) dropNotesFromSinglePListWithNoteIDs: (NSArray *) noteIDs;
- (void) dropNotesFromSingleBinaryPListWithNoteIDs: (NSArray *) noteIDs;
- (void) dropNotesFromMultiplePListWithNoteIDs: (NSArray *) noteIDs;
- (void) dropNotesFromMultipleBinaryPListWIthNoteIDs: (NSArray *) noteIDs;

@property BOOL rollbacked;
@property NSMutableArray *notesToWrite;
@property NSMutableArray *notesToWriteBinary;
@property NSMutableDictionary *helperNotes;

@end

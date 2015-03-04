//
//  ChangeNotesStorage.h
//  filldatabase
//
//  Created by Alfiya on 27.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangeNotesStorage : NSObject

- (NSArray *) getIDsToChangeFromDataBase;
- (NSArray *) getIDsToChangeFromSinglePList;
- (NSArray *) getIDsToChangeFromSingleBinaryPList;
- (NSArray *) getIDsToChangeFromMultiplePList;
- (NSArray *) getIDsToChangeFromMultipleBinaryPList;

- (void) changeNotesFromDataBaseWithNotesData: (NSArray *) notesData;
- (void) changeNotesFromSinglePListWithNoteIDs: (NSArray *) noteIDs;
- (void) changeNotesFromSingleBinaryPListWithNoteIDs: (NSArray *) noteIDs;
- (void) changeNotesFromMultiplePListWithNoteIDs: (NSArray *) noteIDs;
- (void) changeNotesFromMultipleBinaryPListWithNoteIDs: (NSArray *) noteIDs;

@end

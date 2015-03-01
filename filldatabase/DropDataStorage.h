//
//  DropDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDataStorage : NSObject

- (void) dropNotesForNotepadFromDataBase;
- (void) dropNotesForNotepadFromSinglePList;
- (void) dropNotesForNotepadFromSingleBinaryPList;
- (void) dropNotesForNotepadFromMultiplePList;
- (void) dropNotesForNotepadFromMultipleBinaryPList;

@property BOOL rollbacked;
@property NSMutableArray *notesToDrop;

@end

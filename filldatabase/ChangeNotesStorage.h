//
//  ChangeNotesStorage.h
//  filldatabase
//
//  Created by Alfiya on 27.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangeNotesStorage : NSObject

- (void) changeNotesForNotepadFromDataBase;
- (void) changeNotesForNotepadFromSinglePList;

@property BOOL rollbacked;

@end

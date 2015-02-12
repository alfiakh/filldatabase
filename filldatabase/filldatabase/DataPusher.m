//
//  DataPusher.m
//  filldatabase
//
//  Created by Alfiya on 12.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DataPusher.h"
#import "AllDefines.h"
#import "SADictionaryAddtions.h"

@implementation DataPusher

-(id)init {
    self = [super init];
    if (self) {
        self.databaseExisted = NO;
        self.databaseOpened = NO;
        self.commitFailPanic = NO;
        self.rollbackFailPanic = NO;
    }
    return self;
}

-(void) createDataBase {
    NSString *databasePath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    NSLog(@"%@", databasePath);
    if(![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        NSLog(@"Database doesn't exist");
    }
    else {
        self.databaseExisted = YES;
    }
    self.database = [FMDatabase databaseWithPath:databasePath];
//    self.database.traceExecution = YES;
    BOOL opened = [self.database open];
    if (opened) {
        self.databaseOpened = YES;
    }
}

-(BOOL) createNoteTable {
    if (![self.database beginTransaction]) {
        self.beginTransactionFailPanic = YES;
        return NO;
    }
    else {
        BOOL created = [self.database executeUpdate:CREATE_NOTE_TABLE_QUERY];
        if (!created) {
            if (![self.database rollback]) {
                self.rollbackFailPanic = YES;
            };
            return NO;
        }
        else {
            if (![self.database commit]) {
                self.commitFailPanic = YES;
                return NO;
            }
            return YES;
        }
    }
}

-(BOOL) deleteAllOldNotes {
    if (![self.database beginTransaction]) {
        self.beginTransactionFailPanic = YES;
        return NO;
    }
    else {
        BOOL deleted = [self.database executeUpdate:DELETE_NOTES_QUERY];
        if (!deleted) {
            if (![self.database rollback]) {
                self.rollbackFailPanic = YES;
            }
            return NO;
        }
        else {
            if (![self.database commit]) {
                self.commitFailPanic = YES;
                return  NO;
            }
            return YES;
        }
    }
}

- (BOOL) pushNote:(NSDictionary *)note {
    NSDictionary *updatedDict = [note flat:nil];
    NSLog(@"%@", updatedDict);
    NSString *sql = [updatedDict makeSQLinsTable:@"note"];
    if (![self.database beginTransaction]) {
        self.beginTransactionFailPanic = YES;
        return NO;
    }
    else {
        BOOL pushed = [self.database executeUpdate:sql];
        if (!pushed) {
            if (![self.database rollback]) {
                self.rollbackFailPanic = YES;
            }
            return NO;
        }
        else {
            if (![self.database commit]) {
                self.commitFailPanic = YES;
                return  NO;
            }
            return YES;
        }
    }
    return YES;
}

- (void) pushNotesFromResponse: (NSDictionary *) notes {
    TICK;
    for (NSDictionary *note in notes) {
        [self pushNote:note];
    }
    TACK;
    NSLog(@"%@", tackInfo);
}
@end

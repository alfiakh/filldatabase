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
    if (![self.database executeUpdate:CREATE_NOTE_TABLE_QUERY]) {
        self.rollbackFailPanic = ![self.database rollback];
        return NO;
    }
    if (![self.database commit]) {
        self.commitFailPanic = YES;
        return NO;
    }
    return YES;

}

-(BOOL) deleteAllOldNotes {
    if (![self.database beginTransaction]) {
        self.beginTransactionFailPanic = YES;
        return NO;
    }
    if (![self.database executeUpdate:DELETE_NOTES_QUERY]) {
        self.rollbackFailPanic = ![self.database rollback];
        return NO;
    }
    if (![self.database commit]) {
        self.commitFailPanic = YES;
        return  NO;
    }
    return YES;
}

- (BOOL) pushNotesFromResponse: (NSDictionary *) notes {
    if (![self.database beginTransaction]) {
        self.beginTransactionFailPanic = YES;
        return NO;
    }
    TICK;
    for (NSDictionary *note in notes) {
        NSDictionary *updatedDict = [note flat:@"_"];
        NSString *sql = [updatedDict makeSQLinsTable:@"note"];
        if(![self.database executeUpdate:sql]) {
            self.rollbackFailPanic = ![self.database rollback];
            TACK;
            return NO;
        }
        else {
            self.commitFailPanic = ![self.database commit];
            TACK;
            return !self.commitFailPanic;
        }
    }
    return YES;
}
@end

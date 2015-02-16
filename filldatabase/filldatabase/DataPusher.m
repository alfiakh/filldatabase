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
        [self createDataBase];
        [self createNoteTable];
        [self deleteAllOldNotes];
    }
    return self;
}

-(void) createDataBase {
    NSString *databasePath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherDatabaseExistedNotification" object: nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherDatabaseDidntExistNotification" object: nil];
    }
    self.database = [FMDatabase databaseWithPath:databasePath];
//    self.database.traceExecution = YES;
    BOOL opened = [self.database open];
    if (opened) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherDatabaseOpenedNotification" object: nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherDatabaseFailedToOpenNotification" object: nil];
    }
}

-(void) createNoteTable {
    if (![self.database beginTransaction]) {
        if ([self.database executeUpdate:CREATE_NOTE_TABLE_QUERY]) {
            if (![self.database commit]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherCommitTransactionFailNotification" object: nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherCreatedNoteTableNotification" object: nil];
            }
        }
        else {
            if (![self.database rollback]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherRollBackTransactionFailNotification" object: nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherTransactionRollbackedNotification" object: nil];
            }
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherBeginTransactionFailNotification" object: nil];
    }
}

-(void) deleteAllOldNotes {
    if (![self.database beginTransaction]) {
        if ([self.database executeUpdate:DELETE_NOTES_QUERY]) {
            if (![self.database commit]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherCommitTransactionFailNotification" object: nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherOldNotesDeletedNotification" object: nil];
            }
        }
        else {
            if (![self.database rollback]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherRollBackTransactionFailNotification" object: nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherTransactionRollbackedNotification" object: nil];
            }
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherBeginTransactionFailNotification" object: nil];
    }
}

- (void) pushNotesFromResponse: (NSDictionary *) notes {
    if ([self.database beginTransaction]) {
        BOOL rollbacked = NO;
        TICK;
        for (NSDictionary *note in notes[@"data"]) {
            NSDictionary *updatedDict = [note flat:nil];
            NSString *sql = [updatedDict makeSQLinsTable:@"note"];
            if(![self.database executeUpdate:sql]) {
                rollbacked = YES;
                if (![self.database rollback]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherRollBackTransactionFailNotification" object: nil];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherTransactionRollbackedNotification" object: nil];
                }
            }

        }
        if (!rollbacked) {
            if (![self.database commit]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherCommitTransactionFailNotification" object: nil];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherNotesPushedNotification" object: nil];
            }
        }
        TACK;
        NSLog(@"pushNotes: %@", tackInfo);
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"DataPusherBeginTransactionFailNotification" object: nil];
    }
}
@end

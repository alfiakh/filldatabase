//
//  ChangeNotesStorage.m
//  filldatabase
//
//  Created by Alfiya on 27.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ChangeNotesStorage.h"
#import "AllDefines.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation ChangeNotesStorage

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"StorageErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (NSString *) collectSQLStringWithNoteData: (NSDictionary *) noteData {
    NSMutableString *sql = [NSMutableString string];
    NSLog(@"MESSAGE: %@", [self quotesReplaceInString: noteData[@"message"]]);
    [sql appendFormat:@"UPDATE note SET message = \"%@ \" WHERE ID = \"%@\";", [self quotesReplaceInString: noteData[@"message"]], noteData[@"ID"]];
    return sql;
}

- (NSString *) quotesReplaceInString: (NSString *) string{
    NSArray *separated = [string componentsSeparatedByString:@"\""];
    NSString *newString = [separated componentsJoinedByString:@"\"\""];
    separated = [newString componentsSeparatedByString:@"''"];
    return  [separated componentsJoinedByString:@"'"];
}

- (void) changeNotesForNotepadFromDataBase {
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        database.traceExecution = YES;
        if ([database beginTransaction]) {
            FMResultSet *results = [database executeQuery:@"SELECT ID, message FROM note"];
            while ([results next]) {
                if(self.rollbacked) {
                    break;
                }
                NSTimer *timer = [NSTimer
                                  timerWithTimeInterval:0.5
                                  target:self
                                  selector:@selector(pushOneNoteToDataBase:)
                                  userInfo:[results resultDictionary]
                                  repeats:NO];
                [timer fire];
            }
            if (!self.rollbacked && ![database commit]) {
                [self sendErrorNotification:@"Не удалочь закоммитить транзакцию"];
            }
        }
        else {
            [self sendErrorNotification:@"Не удалось начать транзакцию"];
        }

    }
    else {
        [self sendErrorNotification:@"Не удалось открыть базу"];
    }
}

- (void) pushOneNoteToDataBase:(NSTimer *) timer {
    NSDictionary *noteData = [timer.userInfo[@"results"] resultDictionary];
    NSString *sql = [self collectSQLStringWithNoteData:noteData];
    if(![timer.userInfo[@"database"] executeUpdate:sql]) {
        self.rollbacked = YES;
        if (![timer.userInfo[@"database"] rollback]) {
            [self sendErrorNotification:@"Не удадось зароллбечить транзакцию"];
        }
        else {
            [self sendErrorNotification:@"Не прошел запрос"];
        }
    }
}

- (void) changeNotesForNotepadFromSinglePList {
    NSArray *notes = [NSArray arrayWithContentsOfFile:PLIST_PATH];
}

@end

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
    self.rollbacked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        database.traceExecution = YES;
        if ([database beginTransaction]) {
            FMResultSet *results = [database executeQuery:@"SELECT ID, message FROM note"];
            while ([results next]) {
                if(self.rollbacked) {
                    break;
                }
                NSDictionary *userInfo = @{
                                           @"results": [results resultDictionary],
                                           @"database": database
                                           };
                NSTimer *timer = [NSTimer
                                  timerWithTimeInterval:0.5
                                  target:self
                                  selector:@selector(changeOneNoteInDataBase:)
                                  userInfo:userInfo
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

- (void) changeNotesForNotepadFromSinglePList {
    self.rollbacked = NO;
    NSArray *notes= [NSMutableArray arrayWithContentsOfFile:PLIST_PATH];
    for (NSDictionary *note in notes) {
        if (self.rollbacked) {
            break;
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0.4
                          target:self
                          selector:@selector(changeOneNoteInSinglePlist:)
                          userInfo:@{@"note": note}
                          repeats:NO];
        [timer fire];
    }
    if (!self.rollbacked) {
        [self.changedNotes writeToFile:PLIST_PATH atomically:YES];
    }
}

- (void) changeNotesForNotepadFromSingleBinaryPList {
    self.rollbacked = NO;
    NSArray *notes= [NSMutableArray arrayWithContentsOfFile:PLIST_PATH];
    for (NSDictionary *note in notes) {
        if (self.rollbacked) {
            break;
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0.4
                          target:self
                          selector:@selector(changeOneNoteInSinglePlist:)
                          userInfo:@{@"note": note}
                          repeats:NO];
        [timer fire];
    }
    if (!self.rollbacked) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:self.changedNotes
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (!error) {
            BOOL ok = [representation writeToFile:PLIST_BINARY_PATH atomically:YES];
            if (!ok) {
                [self sendErrorNotification:@"Не удалось записать данные в файл"];
            }
        }
        else {
            [self sendErrorNotification:@"Не удалось преобразовать данные"];
        }
    }
}

- (void) changeOneNoteInDataBase:(NSTimer *) timer {
    NSString *sql = [self collectSQLStringWithNoteData:timer.userInfo[@"results"]];
    if(![timer.userInfo[@"database"] executeUpdate:sql]) {
        self.rollbacked = YES;
        if (![timer.userInfo[@"database"] rollback]) {
            [self sendErrorNotification:@"Не удалось зароллбечить транзакцию"];
        }
        else {
            [self sendErrorNotification:@"Не прошел запрос"];
        }
    }
}

- (void) changeOneNoteInSinglePlist:(NSTimer *) timer {
    NSMutableDictionary *newNote = [NSMutableDictionary dictionaryWithDictionary:timer.userInfo[@"note"]];
    NSString *newMessage = [NSString stringWithFormat:@"%@ ", timer.userInfo];
    [newNote setObject:newMessage forKey:@"message"];
    [self.changedNotes addObject:newNote];
}

@end

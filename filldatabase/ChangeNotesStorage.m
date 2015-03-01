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
    [sql appendFormat:@"UPDATE note SET message = \"%@ \" WHERE ID = \"%@\";", [self quotesReplaceInString: noteData[@"message"]], noteData[@"ID"]];
    return sql;
}

- (NSString *) quotesReplaceInString: (NSString *) string{
    NSArray *separated = [string componentsSeparatedByString:@"\""];
    NSString *newString = [separated componentsJoinedByString:@"\"\""];
    separated = [newString componentsSeparatedByString:@"''"];
    return  [separated componentsJoinedByString:@"'"];
}

- (NSArray *) getIDsToChangeFromDataBase {
    NSMutableArray *notesData = [NSMutableArray array];
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        FMResultSet *results = [database executeQuery:@"SELECT ID, message FROM note"];
        while ([results next]) {
            [notesData addObject:[results resultDictionary]];
        }
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть базу"];
    }
    return notesData;
}

- (NSArray *) collectIDsFromPListWithPath: (NSString *) path {
    NSMutableArray *noteIDs = [NSMutableArray array];
    NSArray *notes = [NSArray arrayWithContentsOfFile:path];
    // память не утекай!
    for (NSDictionary *note in notes) {
        [noteIDs addObject:note[@"ID"]];
    }
    return noteIDs;
}

- (NSArray *) getIDsToChangeFromSinglePList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_PATH];
}

- (NSArray *) getIDsToChangeFromSingleBinaryPList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_BINARY_PATH];
}

- (NSArray *) getIDsToChangeFromMultiplePList {
    return [self collectIDsFromPListWithPath:HELPER_PLIST_PATH];
}

- (NSArray *) getIDsToChangeFromMultipleBinaryPList {
    return [self collectIDsFromPListWithPath:HELPER_BINARY_PLIST_PATH];
}

- (void) changeNotesFromDataBaseWithNotesData:(NSArray *)notesData {
    self.rollbacked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        if ([database beginTransaction]) {
            for (NSString *note in notesData) {
                if(self.rollbacked) {
                    break;
                }
                NSDictionary *userInfo = @{
                                           @"noteData": note,
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

- (void) changeNotesFromSinglePListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    NSArray *notes = [NSArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    for (NSDictionary *note in notes) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:note[@"ID"]]) {
            timer = [NSTimer
                              timerWithTimeInterval:0.4
                              target:self
                              selector:@selector(changeOneNoteInSinglePList:)
                              userInfo:@{@"note": note}
                              repeats:NO];
            [timer fire];
        }
    }
    if (!self.rollbacked) {
        BOOL ok =[self.changedNotes writeToFile:SINGLE_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать заметки в файл"];
        }
    }
}

- (void) changeNotesFromSingleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    NSArray *notes = [NSArray arrayWithContentsOfFile:SINGLE_PLIST_BINARY_PATH];
    NSTimer *timer;
    for (NSDictionary *note in notes) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:note[@"ID"]]) {
            timer = [NSTimer
                              timerWithTimeInterval:0.4
                              target:self
                              selector:@selector(changeOneNoteInSinglePList:)
                              userInfo:@{@"note": note}
                              repeats:NO];
            [timer fire];
        }
    }
    if (!self.rollbacked) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:self.changedNotes
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (!error) {
            BOOL ok = [representation writeToFile:SINGLE_PLIST_BINARY_PATH atomically:YES];
            if (!ok) {
                [self sendErrorNotification:@"Не удалось записать данные в файл"];
            }
        }
        else {
            [self sendErrorNotification:@"Не удалось преобразовать данные"];
        }
    }
}

- (void) changeNotesFromMultiplePListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    for (NSString *noteID in noteIDs) {
        if (self.rollbacked) {
            break;
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0.4
                          target:self
                          selector:@selector(changeOneNoteInMultiplePList:)
                          userInfo:@{@"noteID":noteID}
                          repeats:NO];
        [timer fire];
    }
    if (!self.rollbacked) {
        
    }
}

- (void) changeNotesFromMultipleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    for (NSString *noteID in noteIDs) {
        if (self.rollbacked) {
            break;
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0.4
                          target:self
                          selector:@selector(changeOneNoteInMultipleBinaryPList:)
                          userInfo:@{@"noteID":noteID}
                          repeats:NO];
        [timer fire];
    }
    if (!self.rollbacked) {
        
    }
}

- (void) changeOneNoteInDataBase:(NSTimer *) timer {
    NSString *sql = [self collectSQLStringWithNoteData:timer.userInfo[@"noteData"]];
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

- (void) changeOneNoteInSinglePList:(NSTimer *) timer {
    NSMutableDictionary *newNote = [NSMutableDictionary dictionaryWithDictionary:timer.userInfo[@"note"]];
    NSString *newMessage = [NSString stringWithFormat:@"%@ ", timer.userInfo];
    [newNote setObject:newMessage forKey:@"message"];
    [self.changedNotes addObject:newNote];
}

- (void) changeOneNoteInMultiplePList:(NSTimer *) timer {
    NSString *notePath = [MULTIPLE_PLIST_FOLDER stringByAppendingPathComponent:timer.userInfo[@"noteData"]];
    NSMutableDictionary *note = [NSMutableDictionary dictionaryWithContentsOfFile:notePath];
    if(!note) {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Да нету заметки!"];
    }
    note[@"message"] = [NSString stringWithFormat:@"%@ ", note[@"message"]];
    BOOL ok = [note writeToFile:notePath atomically:YES];
    if (!ok) {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Не удалось записать заметку в файл=("];
    }
}

- (void) changeOneNoteInMultipleBinaryPList:(NSTimer *) timer {
    NSString *notePath = [MULTIPLE_BINARY_PLIST_FOLDER stringByAppendingPathComponent:timer.userInfo[@"noteID"]];
    NSMutableDictionary *note = [NSMutableDictionary dictionaryWithContentsOfFile:notePath];
    if(!note) {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Да нету заметки!"];
    }
    note[@"message"] = [NSString stringWithFormat:@"%@ ", note[@"message"]];
    NSError *error = nil;
    NSData *representation= [NSPropertyListSerialization
                             dataWithPropertyList:note
                             format:NSPropertyListXMLFormat_v1_0
                             options:0
                             error:&error];
    if (!error) {
        BOOL ok = [representation writeToFile:notePath atomically:YES];
        if (!ok) {
            self.rollbacked = YES;
            [self sendErrorNotification:@"Не удалось вписать заметку в файл"];
        }
    }
    else {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Не удалось сериализовать данные"];
    }
}

@end

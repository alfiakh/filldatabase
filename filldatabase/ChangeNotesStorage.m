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

@implementation ChangeNotesStorage {
    NSMutableArray *_changedNotes;
    NSMutableArray *_changedNotesBinary;
    
    // состояния отката дропа
    BOOL _rollbackedDataBase;
    BOOL _rollbackedSinglePList;
    BOOL _rollbackedSingleBinaryPList;
    BOOL _rollbackedMultiplePList;
    BOOL _rollbackedMultipleBinaryPList;
    
    // состояния файра таймера
    BOOL _timerFiredDataBase;
    BOOL _timerFiredSinglePList;
    BOOL _timerFiredSingleBinaryPList;
    BOOL _timerFiredMultiplePList;
    BOOL _timerFiredMultipleBinaryPList;
}

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

- (NSArray *) collectIDsFromPListWithHelperPath: (NSString *) path {
    NSDictionary *notes = [NSDictionary dictionaryWithContentsOfFile:path];
    return [notes allKeys];
}

- (NSArray *) getIDsToChangeFromSinglePList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_PATH];
}

- (NSArray *) getIDsToChangeFromSingleBinaryPList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_BINARY_PATH];
}

- (NSArray *) getIDsToChangeFromMultiplePList {
    return [self collectIDsFromPListWithHelperPath:HELPER_PLIST_PATH];
}

- (NSArray *) getIDsToChangeFromMultipleBinaryPList {
    return [self collectIDsFromPListWithHelperPath:HELPER_BINARY_PLIST_PATH];
}

- (void) changeNotesFromDataBaseWithNotesData:(NSArray *)notesData {
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![database open]) {
        [self sendErrorNotification:@"Не удалось открыть базу"];
        return;
    }
    if (![database beginTransaction]) {
        [self sendErrorNotification:@"Не удалось начать транзакцию"];
        return;
    }
    _timerFiredDataBase = YES;
    for (NSString *note in notesData) {
        if(_rollbackedDataBase) {
            break;
        }
        if (_timerFiredDataBase) {
            sleep(0.1);
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0
                          target:self
                          selector:@selector(changeOneNoteInDataBase:)
                          userInfo:@{
                                     @"noteData": note,
                                     @"database": database
                                     }
                          repeats:NO];
        [timer fire];
    }
    if (!_rollbackedDataBase && ![database commit]) {
        [self sendErrorNotification:@"Не удалочь закоммитить транзакцию"];
    }
}

- (void) changeNotesFromSinglePListWithNoteIDs:(NSArray *)noteIDs {
    NSArray *notes = [NSArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    _timerFiredSinglePList = YES;
    for (NSDictionary *note in notes) {
        if (_rollbackedSinglePList) {
            break;
        }
        while (!_timerFiredSinglePList) {
            sleep(0.1);
        }
        if ([noteIDs containsObject:note[@"ID"]]) {
            timer = [NSTimer
                              timerWithTimeInterval:0
                              target:self
                              selector:@selector(changeOneNoteInSinglePList:)
                              userInfo:@{@"note": note}
                              repeats:NO];
            [timer fire];
        }
    }
    if (!_timerFiredSinglePList) {
        BOOL ok =[_changedNotes writeToFile:SINGLE_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать заметки в файл"];
        }
    }
}

- (void) changeNotesFromSingleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    NSArray *notes = [NSArray arrayWithContentsOfFile:SINGLE_PLIST_BINARY_PATH];
    NSTimer *timer;
    _timerFiredSingleBinaryPList = YES;
    for (NSDictionary *note in notes) {
        if (_rollbackedSingleBinaryPList) {
            break;
        }
        while (!_timerFiredSingleBinaryPList) {
            sleep(0.1);
        }
        if ([noteIDs containsObject:note[@"ID"]]) {
            timer = [NSTimer
                              timerWithTimeInterval:0
                              target:self
                              selector:@selector(changeOneNoteInSingleBinaryPList:)
                              userInfo:@{@"note": note}
                              repeats:NO];
            [timer fire];
        }
    }
    if (!_rollbackedSingleBinaryPList) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:_changedNotesBinary
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (error) {
            [self sendErrorNotification:@"Не удалось преобразовать данные"];
            return;
        }
        BOOL ok = [representation writeToFile:SINGLE_PLIST_BINARY_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать данные в файл"];
        }
    }
}

- (void) changeNotesFromMultiplePListWithNoteIDs:(NSArray *)noteIDs {
    _timerFiredMultiplePList = YES;
    for (NSString *noteID in noteIDs) {
        if (_rollbackedMultiplePList) {
            break;
        }
        while (!_timerFiredMultiplePList) {
            sleep(0.1);
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0
                          target:self
                          selector:@selector(changeOneNoteInMultiplePList:)
                          userInfo:@{@"noteID":noteID}
                          repeats:NO];
        [timer fire];
    }
}

- (void) changeNotesFromMultipleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    _timerFiredMultipleBinaryPList = YES;
    for (NSString *noteID in noteIDs) {
        if (_rollbackedMultipleBinaryPList) {
            break;
        }
        while (!_timerFiredMultipleBinaryPList) {
            sleep(0.1);
        }
        NSTimer *timer = [NSTimer
                          timerWithTimeInterval:0
                          target:self
                          selector:@selector(changeOneNoteInMultipleBinaryPList:)
                          userInfo:@{@"noteID":noteID}
                          repeats:NO];
        [timer fire];
    }
}

- (void) changeOneNoteInDataBase:(NSTimer *) timer {
    NSString *sql = [self collectSQLStringWithNoteData:timer.userInfo[@"noteData"]];
    if(![timer.userInfo[@"database"] executeUpdate:sql]) {
        _rollbackedDataBase = YES;
        if (![timer.userInfo[@"database"] rollback]) {
            [self sendErrorNotification:@"Не удалось зароллбечить транзакцию"];
            return;
        }
        [self sendErrorNotification:@"Не прошел запрос в базу"];
    }
    _timerFiredDataBase = YES;
}

- (void) changeOneNoteInSinglePList:(NSTimer *) timer {
    NSMutableDictionary *newNote = [NSMutableDictionary dictionaryWithDictionary:timer.userInfo[@"note"]];
    NSString *newMessage = [NSString stringWithFormat:@"%@ ", timer.userInfo];
    [newNote setObject:newMessage forKey:@"message"];
    [_changedNotes addObject:newNote];
    _timerFiredSinglePList = YES;
}

- (void) changeOneNoteInSingleBinaryPList:(NSTimer *) timer {
    NSMutableDictionary *newNote = [NSMutableDictionary dictionaryWithDictionary:timer.userInfo[@"note"]];
    NSString *newMessage = [NSString stringWithFormat:@"%@ ", timer.userInfo];
    [newNote setObject:newMessage forKey:@"message"];
    [_changedNotesBinary addObject:newNote];
    _timerFiredSingleBinaryPList = YES;
}

- (void) changeOneNoteInMultiplePList:(NSTimer *) timer {
    NSString *notePath = [MULTIPLE_PLIST_FOLDER stringByAppendingPathComponent:timer.userInfo[@"noteData"]];
    NSMutableDictionary *note = [NSMutableDictionary dictionaryWithContentsOfFile:notePath];
    if(!note) {
        _rollbackedMultiplePList = YES;
        [self sendErrorNotification:@"Да нету заметки!"];
    }
    note[@"message"] = [NSString stringWithFormat:@"%@ ", note[@"message"]];
    BOOL ok = [note writeToFile:notePath atomically:YES];
    if (!ok) {
        _rollbackedMultiplePList = YES;
        [self sendErrorNotification:@"Не удалось записать заметку в файл=("];
    }
    _timerFiredMultiplePList = YES;
}

- (void) changeOneNoteInMultipleBinaryPList:(NSTimer *) timer {
    NSString *notePath = [MULTIPLE_BINARY_PLIST_FOLDER stringByAppendingPathComponent:timer.userInfo[@"noteID"]];
    NSMutableDictionary *note = [NSMutableDictionary dictionaryWithContentsOfFile:notePath];
    if(!note) {
        _rollbackedMultipleBinaryPList = YES;
        [self sendErrorNotification:@"Да нету заметки!"];
    }
    note[@"message"] = [NSString stringWithFormat:@"%@ ", note[@"message"]];
    NSError *error = nil;
    NSData *representation= [NSPropertyListSerialization
                             dataWithPropertyList:note
                             format:NSPropertyListXMLFormat_v1_0
                             options:0
                             error:&error];
    if (error) {
        _rollbackedMultipleBinaryPList = YES;
        [self sendErrorNotification:@"Не удалось сериализовать данные"];
        return;
    }
    BOOL ok = [representation writeToFile:notePath atomically:YES];
    if (!ok) {
        _rollbackedMultipleBinaryPList = YES;
        [self sendErrorNotification:@"Не удалось вписать заметку в файл"];
    }
    _timerFiredMultipleBinaryPList = YES;
}

@end

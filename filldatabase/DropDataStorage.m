//
//  DropDataStorage.m
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DropDataStorage.h"
#import "FMDatabase.h"
#import "AllDefines.h"

@implementation DropDataStorage {
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
    
    // вспомогательные структуры для записи
    
    // из этих сносятся заметки и потом пишется
    NSMutableArray *_notesToWrite;
    NSMutableArray *_notesToWriteBinary;
    // это для обновления вспомогательных структур мультиплов
    NSMutableDictionary *_helperNotes;
    NSMutableDictionary *_helperNotesBinary;
}

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"StorageErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (NSArray *) getIDsToDropFromDataBase {
    NSMutableArray *notesData = [NSMutableArray array];
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        FMResultSet *results = [database executeQuery:@"SELECT ID FROM note"];
        while ([results next]) {
            [notesData addObject:[results resultDictionary][@"ID"]];
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

- (NSArray *) getIDsToDropFromSinglePList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_PATH];
}

- (NSArray *) getIDsToDropFromSingleBinaryPList {
    return [self collectIDsFromPListWithPath:SINGLE_PLIST_BINARY_PATH];
}

- (NSArray *) getIDsToDropFromMultiplePList {
    return [self collectIDsFromPListWithPath:HELPER_PLIST_PATH];
}

- (NSArray *) getIDsToDropFromMultipleBinaryPList {
    return [self collectIDsFromPListWithPath:HELPER_BINARY_PLIST_PATH];
}

- (void) dropNotesFromDataBasetWithNoteIDs:(NSArray *)noteIDs {
    _rollbackedDataBase = NO;
    _timerFiredDataBase = YES;
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        if ([database beginTransaction]) {
            for (NSString *noteID in noteIDs) {
                while (!_timerFiredDataBase) {
                    sleep(0.1);
                }
                if(_rollbackedDataBase) {
                    break;
                }
                _timerFiredDataBase = NO;
                NSDictionary *userInfo = @{
                                           @"noteID": noteID,
                                           @"database": database
                                           };
                NSTimer *timer = [NSTimer
                                  timerWithTimeInterval:0
                                  target:self
                                  selector:@selector(dropOneNoteInDataBase:)
                                  userInfo:userInfo
                                  repeats:NO];
                [timer fire];
            }
            if (!_rollbackedDataBase && ![database commit]) {
                [self sendErrorNotification:@"Не удалоcь закоммитить транзакцию"];
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

- (void) dropNotesFromSinglePListWithNoteIDs:(NSArray *)noteIDs {
    _rollbackedSinglePList = NO;
    _timerFiredSinglePList = YES;
    _notesToWrite = [NSMutableArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    for (int i = (int)[_notesToWrite count] - 1; i >= 0; i--) {
        while (!_timerFiredSinglePList) {
            sleep(0.1);
        }
        _timerFiredSinglePList = NO;
        if (_rollbackedSinglePList) {
            break;
        }
        if ([noteIDs containsObject:_notesToWrite[i][@"ID"]]) {
            timer = [NSTimer
                     timerWithTimeInterval:0
                     target:self
                     selector:@selector(dropOneNoteInSinglePList:)
                     userInfo:@{
                                @"note": _notesToWrite[i],
                                @"counter": @(i),
                                @"type": @"single"
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!_rollbackedSinglePList) {
        NSLog(@"%@", _notesToWrite);
        BOOL ok =[_notesToWrite writeToFile:SINGLE_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать заметки в файл"];
        }
    }
}

- (void) dropNotesFromSingleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    _rollbackedSingleBinaryPList = NO;
    _timerFiredSingleBinaryPList = YES;
    _notesToWriteBinary = [NSMutableArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    for (int i = (int)[_notesToWriteBinary count] - 1; i >= 0; i--) {
        while (!_timerFiredSingleBinaryPList) {
            sleep(0.1);
        }
        if (_rollbackedSingleBinaryPList) {
            break;
        }
        _timerFiredSingleBinaryPList = NO;
        if ([noteIDs containsObject:_notesToWriteBinary[i][@"ID"]]) {
            timer = [NSTimer
                     timerWithTimeInterval:0
                     target:self
                     selector:@selector(dropOneNoteInSinglePList:)
                     userInfo:@{
                                @"note": _notesToWriteBinary[i],
                                @"counter": @(i),
                                @"type": @"single binary"
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!_rollbackedSingleBinaryPList) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:_notesToWriteBinary
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

- (void) dropNotesFromMultiplePListWithNoteIDs:(NSArray *)noteIDs {
    _rollbackedMultiplePList = NO;
    _timerFiredMultiplePList = YES;
    _helperNotes = [NSMutableDictionary dictionaryWithContentsOfFile:HELPER_PLIST_PATH];
    NSTimer *timer;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error= nil;
    NSArray *multipleNotes = [manager contentsOfDirectoryAtPath:MULTIPLE_PLIST_FOLDER error:&error];
    if ([_helperNotes count] != [multipleNotes count]) {
        NSLog(@"%lu %lu", (unsigned long)[_helperNotes count], (unsigned long)[multipleNotes count]);
    }
    for (NSString *noteID in _helperNotes) {
        while (!_timerFiredMultiplePList) {
            NSLog(@"sleep");
            sleep(0.1);
        }
        if (_rollbackedMultiplePList) {
            break;
        }
        _timerFiredMultiplePList = NO;
        if ([noteIDs containsObject:noteID]) {
            sleep(0.1);
            timer = [NSTimer
                     timerWithTimeInterval:0
                     target:self
                     selector:@selector(dropOneNoteInMultiplePList:)
                     userInfo:@{
                                @"noteID": noteID,
                                @"type": @"multiple"
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!_rollbackedMultiplePList) {
        BOOL ok = [_helperNotes writeToFile:HELPER_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Произошла ошибка при записи во вспомогательный файл"];
        }
    }
}

- (void) dropNotesFromMultipleBinaryPListWIthNoteIDs:(NSArray *)noteIDs {
    _rollbackedMultipleBinaryPList = NO;
    _timerFiredMultipleBinaryPList = YES;
    _helperNotesBinary = [NSMutableDictionary dictionaryWithContentsOfFile:HELPER_PLIST_PATH];
    NSTimer *timer;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error= nil;
    NSArray *multipleNotes = [manager contentsOfDirectoryAtPath:MULTIPLE_BINARY_PLIST_FOLDER error:&error];
    if ([_helperNotes count] != [multipleNotes count]) {
        NSLog(@"%lu %lu", (unsigned long)[_helperNotes count], (unsigned long)[multipleNotes count]);
    }
    for (NSString *noteID in _helperNotesBinary) {
        while (!_timerFiredMultipleBinaryPList) {
            sleep(0.1);
        }
        if (_rollbackedMultipleBinaryPList) {
            break;
        }
        _timerFiredMultipleBinaryPList = NO;
        if ([noteIDs containsObject:noteID]) {
            sleep(0.1);
            timer = [NSTimer
                     timerWithTimeInterval:0
                     target:self
                     selector:@selector(dropOneNoteInMultiplePList:)
                     userInfo:@{
                                @"noteID": noteID,
                                @"type": @"multiple binary"
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!_rollbackedMultipleBinaryPList) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:_helperNotesBinary
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (!error) {
            BOOL ok = [representation writeToFile:HELPER_BINARY_PLIST_PATH atomically:YES];
            if (!ok) {
                [self sendErrorNotification:@"Не удалось записать бинарный данные файл"];
            }
        }
        else {
            [self sendErrorNotification:@"Не удалось преобразовать данные в бинарный форомат"];
        }
    }
}

- (void) dropOneNoteInDataBase: (NSTimer *) timer {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM note WHERE ID = \"%@\"", timer.userInfo[@"noteID"]];
    if(![timer.userInfo[@"database"] executeUpdate:sql]) {
        _rollbackedDataBase = YES;
        if (![timer.userInfo[@"database"] rollback]) {
            [self sendErrorNotification:@"Не удалось зароллбечить транзакцию"];
        }
        else {
            [self sendErrorNotification:@"Не прошел запрос"];
        }
    }
    _timerFiredDataBase = YES;
}

- (void) dropOneNoteInSinglePList: (NSTimer *)timer {
    //на страх и риск. нужен алгоритм который ищет в аррае по entityID и возвращает индекс. пробегаться каждый раз аррай бред
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSUInteger counter = [timer.userInfo[@"counter"] integerValue];
        if (counter < [_notesToWrite count]) {
            BOOL correctNote = [[_notesToWrite objectAtIndex:counter]isEqualToDictionary:timer.userInfo[@"note"]];
            if (correctNote) {
                [_notesToWrite removeObjectAtIndex:counter];
            }
            else {
                _rollbackedSinglePList = YES;
                [self sendErrorNotification:@"Объект был изменен в процессе удаления"];
            }
        }
        else {
            _rollbackedSinglePList = YES;
            [self sendErrorNotification:@"Объект был изменен в процессе удаления"];
        }
    });
    _timerFiredSinglePList = YES;
}

- (void) dropOneNoteInSingleBinaryPList: (NSTimer *)timer {
    //на страх и риск. нужен алгоритм который ищет в аррае по entityID и возвращает индекс. пробегаться каждый раз аррай бред
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSUInteger counter = [timer.userInfo[@"counter"] integerValue];
        if (counter < [_notesToWriteBinary count]) {
            BOOL correctNote = [[_notesToWriteBinary objectAtIndex:counter]isEqualToDictionary:timer.userInfo[@"note"]];
            if (correctNote) {
                [_notesToWriteBinary removeObjectAtIndex:counter];
            }
            else {
                _rollbackedSingleBinaryPList = YES;
                [self sendErrorNotification:@"Объект был изменен в процессе удаления"];
            }
        }
        else {
            _rollbackedSingleBinaryPList = YES;
            [self sendErrorNotification:@"Объект был изменен в процессе удаления"];
        }
    });
    _timerFiredSingleBinaryPList = YES;
}

- (void) dropOneNoteInMultiplePList: (NSTimer *) timer {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *noteID = timer.userInfo[@"noteID"];
        NSString *notePath = [MULTIPLE_PLIST_FOLDER stringByAppendingPathComponent:noteID];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error= nil;
        NSArray *multipleNotes = [manager contentsOfDirectoryAtPath:MULTIPLE_PLIST_FOLDER error:&error];
        NSLog(@"%lu, %lu", (unsigned long) [_helperNotes count], (unsigned long)[multipleNotes count]);
        
        
        if (_helperNotes[noteID]) {
            [_helperNotes removeObjectForKey:noteID];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:notePath]) {
                NSError *error;
                BOOL ok = [manager removeItemAtPath:notePath error:&error];
                if (error || !ok) {
                    _rollbackedMultiplePList = YES;
                    [self sendErrorNotification:@"Не удалось снести заметку"];
                }
            }
            else {
                _rollbackedMultiplePList = YES;
                [self sendErrorNotification:@"Заметки которую вы пытаетесь удалить уже не было"];
            }
        }
        else {
            _rollbackedMultiplePList = YES;
            [self sendErrorNotification:@"Во вспомогательном PList нет заметки, которая пришла на удаление"];
        }
    });
    _timerFiredMultiplePList = YES;
}

- (void) dropOneNoteInMultipleBinaryPList: (NSTimer *) timer {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *noteID = timer.userInfo[@"noteID"];
        NSString *notePath = [MULTIPLE_BINARY_PLIST_FOLDER stringByAppendingPathComponent:noteID];
        if (_helperNotesBinary[noteID]) {
            [_helperNotesBinary removeObjectForKey:noteID];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:notePath]) {
                NSError *error;
                BOOL ok = [manager removeItemAtPath:notePath error:&error];
                if (error || !ok) {
                    _rollbackedMultipleBinaryPList = YES;
                    [self sendErrorNotification:@"Не удалось снести заметку"];
                }
            }
            else {
                _rollbackedMultipleBinaryPList = YES;
                [self sendErrorNotification:@"Заметки которую вы пытаетесь удалить уже не было"];
            }
        }
        else {
            _rollbackedMultipleBinaryPList = YES;
            [self sendErrorNotification:@"Во вспомогательном PList нет заметки, которая пришла на удаление"];
        }
    });
    _timerFiredMultiplePList = YES;
}

@end

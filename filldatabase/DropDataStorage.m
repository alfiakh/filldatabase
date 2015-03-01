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

@implementation DropDataStorage

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

- (void) dropNotesFromDataBaseWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        if ([database beginTransaction]) {
            for (NSString *noteID in noteIDs) {
                if(self.rollbacked) {
                    break;
                }
                NSDictionary *userInfo = @{
                                           @"noteID": noteID,
                                           @"database": database
                                           };
                NSTimer *timer = [NSTimer
                                  timerWithTimeInterval:0.5
                                  target:self
                                  selector:@selector(dropOneNoteInDataBase:)
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

- (void) dropNotesFromSinglePListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    self.notesToWrite = [NSMutableArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    for (int i = (int)[self.notesToWrite count] - 1; i >= 0; i--) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:self.notesToWrite[i][@"ID"]]) {
            timer = [NSTimer
                     timerWithTimeInterval:0.4
                     target:self
                     selector:@selector(dropOneNoteInSinglePList:)
                     userInfo:@{
                                @"note": self.notesToWrite[i],
                                @"counter": @(i)
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!self.rollbacked) {
        BOOL ok =[self.notesToWrite writeToFile:SINGLE_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать заметки в файл"];
        }
    }
    self.notesToWrite = [NSMutableArray array];
}

- (void) dropNotesFromSingleBinaryPListWithNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    self.notesToWrite = [NSMutableArray arrayWithContentsOfFile:SINGLE_PLIST_PATH];
    NSTimer *timer;
    for (int i = (int)[self.notesToWrite count] - 1; i >= 0; i--) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:self.notesToWrite[i][@"ID"]]) {
            timer = [NSTimer
                     timerWithTimeInterval:0.4
                     target:self
                     selector:@selector(dropOneNoteInSinglePList:)
                     userInfo:@{
                                @"note": self.notesToWrite[i],
                                @"counter": @(i)
                                }
                     repeats:NO];
            [timer fire];
        }
    }
    if (!self.rollbacked) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:self.notesToWrite
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
    self.rollbacked = NO;
    NSDictionary *helperNotes = [NSDictionary dictionaryWithContentsOfFile:HELPER_PLIST_PATH];
    self.helperNotes = [helperNotes mutableCopy];
    NSTimer *timer;
    for (NSString *noteID in self.helperNotes) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:noteID]) {
            timer = [NSTimer
                     timerWithTimeInterval:0.4
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
    if (!self.rollbacked) {
        BOOL ok = [self.notesToWrite writeToFile:HELPER_PLIST_PATH atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Произошла ошибка при записи во вспомогательный файл"];
        }
    }
}

- (void) dropNotesFromMultipleBinaryPListWIthNoteIDs:(NSArray *)noteIDs {
    self.rollbacked = NO;
    NSDictionary *helperNotes = [NSDictionary dictionaryWithContentsOfFile:HELPER_PLIST_PATH];
    self.helperNotes = [helperNotes mutableCopy];
    NSTimer *timer;
    for (NSString *noteID in self.helperNotes) {
        if (self.rollbacked) {
            break;
        }
        if ([noteIDs containsObject:noteID]) {
            timer = [NSTimer
                     timerWithTimeInterval:0.4
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
    if (!self.rollbacked) {
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:self.notesToWrite
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
        self.rollbacked = YES;
        if (![timer.userInfo[@"database"] rollback]) {
            [self sendErrorNotification:@"Не удалось зароллбечить транзакцию"];
        }
        else {
            [self sendErrorNotification:@"Не прошел запрос"];
        }
    }
}

- (void) dropOneNoteInSinglePList: (NSTimer *)timer {
    //на страх и риск. нужен алгоритм который ищет в аррае по entityID и возвращает индекс. пробегаться каждый раз аррай бред
    NSUInteger counter = [timer.userInfo[@"counter"] integerValue];
    BOOL correctNote = [[self.notesToWrite objectAtIndex:counter] isEqualToDictionary:timer.userInfo[@"note"]];
    if (correctNote) {
        [self.notesToWrite removeObjectAtIndex:counter];
    }
    else {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Заметка, которую пытаемся удалить не соответствует индексу"];
    }
}

- (void) dropOneNoteInMultiplePList: (NSTimer *) timer {
    NSString *noteID = timer.userInfo[@"noteID"];
    NSString *notePath;
    if ([timer.userInfo[@"type"] isEqualToString:@"multiple"]) {
        notePath = [MULTIPLE_PLIST_FOLDER stringByAppendingPathComponent:noteID];
    }
    else if ([timer.userInfo[@"type"] isEqualToString:@"multiple binary"]) {
        notePath = [MULTIPLE_BINARY_PLIST_FOLDER stringByAppendingString:noteID];
    }
    else {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Переданый некорректный тип стореджа в таймер"];
    }
    if (self.helperNotes[noteID]) {
        [self.helperNotes removeObjectForKey:noteID];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:notePath]) {
            NSError *error;
            BOOL ok = [manager removeItemAtPath:notePath error:&error];
            if (error || !ok) {
                self.rollbacked = YES;
                [self sendErrorNotification:@"Не удалось снести заметку"];
            }
        }
        else {
            [self sendErrorNotification:@"Заметки которую вы пытаетесь удалить уже не было"];
        }
    }
    else {
        self.rollbacked = YES;
        [self sendErrorNotification:@"Во вспомогательном PList нет заметки, которая пришла на удаление"];
    }
}

@end

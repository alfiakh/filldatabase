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

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"DataErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (void) createDataBase {
    NSString *databasePath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    if([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        [self sendErrorNotification:@"База уже существует"];
    }
    else {
        [self sendErrorNotification:@"Базы не было будем создавать"];
    }
    self.database = [FMDatabase databaseWithPath:databasePath];
//    self.database.traceExecution = YES;
    if ([self.database open]) {
        [self sendErrorNotification:@"Удалось открыть базу"];
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть базу"];
    }
}

- (void) createNoteTable {
    if ([self.database beginTransaction]) {
        if ([self.database executeUpdate:CREATE_NOTE_TABLE_QUERY]) {
            if (![self.database commit]) {
                [self sendErrorNotification:@"Не удалось закоммитить транзакцию после создания таблицы note"];
            }
            else {
                [self sendErrorNotification:@"Таблица note успешно создана"];
            }
        }
        else {
            if (![self.database rollback]) {
                [self sendErrorNotification:@"Не удалось откатить транзакцию после неуспешного создания таблицы note"];
            }
            else {
                [self sendErrorNotification:@"Откатили транзакцию после неуспешного создания таблицы note"];
            }
        }
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть транзакцию для таблицы note"];
    }
}

- (void) deleteAllOldNotes {
    if ([self.database beginTransaction]) {
        if ([self.database executeUpdate:DELETE_NOTES_QUERY]) {
            if (![self.database commit]) {
                [self sendErrorNotification:@"Не удалось закоммитить транзакцию после удаления старых записей"];
            }
            else {
                [self sendErrorNotification:@"Старые записи успешно удалены"];
            }
        }
        else {
            if (![self.database rollback]) {
                [self sendErrorNotification:@"Не удалось откатить транзакцию после неуспешного удаления старых записей"];
            }
            else {
                [self sendErrorNotification:@"Откатили транзакцию после неуспешного удаления старых записей"];
            }
        }
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть транзакцию для удаления старых записей"];
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
                    [self sendErrorNotification:@"Не удалось откатить транзакцию после неуспешного добавления новой записи"];
                    break;
                }
                else {
                    [self sendErrorNotification:@"Откатили транзакцию после неуспешного добавления новой записи"];
                }
            }

        }
        if (!rollbacked) {
            if (![self.database commit]) {
                [self sendErrorNotification:@"Не удалось закоммитить транзакцию после добавления новых записей"];
            }
            else {
                [self sendErrorNotification:@"Новые записи успешно добавлены в базу"];
            }
        }
        TACK;
        NSLog(@"pushNotes: %@", tackInfo);
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть транзакцию для пуша новых заметок"];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        [self createDataBase];
        [self createNoteTable];
        [self deleteAllOldNotes];
    }
    return self;
}

@end

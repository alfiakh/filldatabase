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

- (id)init {
    self = [super init];
    if (self) {
        [self createDataBase];
        [self createNoteTable];
        [self deleteAllOldNotes];
    }
    return self;
}

- (void) sendErrorNotification:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName: @"DataErrorNotification"
         object: nil
         userInfo: @{@"message": message}];
    });
}

- (void) sendDoneNotification:(NSString *)message withTackInfo: (NSDictionary *) tackInfo{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName: @"DataErrorNotification"
         object: nil
         userInfo: @{@"message": [NSString stringWithFormat:@"%@ %@", message, tackInfo[@"time"]]}];
    });
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

- (void) pushNotesFromResponse {
    TICK;
    NSString *helperNotesFile = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:REQUEST_NOTES_FILE_NAME];
    self.notesToPush = [NSMutableArray arrayWithContentsOfFile:helperNotesFile];
    if ([self.database beginTransaction]) {
        while ( [self.notesToPush count] != 0 ) {
            if (self.rollbacked) {
                break;
            }
            NSTimer *notesToUpdateTimer = [NSTimer timerWithTimeInterval: 0.5
                                                              target: self
                                                            selector: @selector( pushOneNote )
                                                            userInfo: nil
                                                             repeats: NO];
            [notesToUpdateTimer fire];
        }
        if (!self.rollbacked) {
            if (![self.database commit]) {
                [self sendErrorNotification:@"Не удалось закоммитить транзакцию после добавления новых записей"];
            }
            else {
                TACK;
                [self sendDoneNotification:@"Новые записи успешно добавлены в базу" withTackInfo:tackInfo];
            }
        }
    }
    else {
        [self sendErrorNotification:@"Не удалось открыть транзакцию для пуша новых заметок"];
    }
}

-(void) pushOneNote {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSMutableDictionary *note = [self.notesToPush[0] mutableCopy];
        [note setObject:@"" forKey:@"history"];
        NSString *sql = [[[note nullReplace] flat:nil] makeSQLinsTable:@"note"];
        if(![self.database executeUpdate:sql]) {
            self.rollbacked = YES;
            if (![self.database rollback]) {
                [self sendErrorNotification:@"Не удалось откатить транзакцию после неуспешного добавления новой записи"];
            }
            else {
                [self sendErrorNotification:@"Откатили транзакцию после неуспешного добавления новой записи"];
            }
        }
        else {
            [self.notesToPush removeObjectAtIndex:0];
        }
    });

}
@end

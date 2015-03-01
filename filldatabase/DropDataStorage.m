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

- (void) dropNotesForNotepadFromDataBase {
    self.rollbacked = NO;
    FMDatabase *database = [FMDatabase databaseWithPath:DATABASE_PATH];
    if ([database open]) {
        //        database.traceExecution = YES;
        if ([database beginTransaction]) {
            FMResultSet *results = [database executeQuery:@"SELECT ID FROM note"];
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

- (void) dropNotesForNotepadFromSinglePList {
    
}

- (void) dropNotesForNotepadFromSingleBinaryPList {
    
}

- (void) dropNotesForNotepadFromMultiplePList {
    
}

- (void) dropNotesForNotepadFromMultipleBinaryPList {
    
}

- (void) dropOneNoteInDataBase: (NSTimer *) timer {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM note WHERE ID = \"%@\"", timer.userInfo[@"results"][@"ID"]];
    NSLog(@"%@", sql);
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

@end

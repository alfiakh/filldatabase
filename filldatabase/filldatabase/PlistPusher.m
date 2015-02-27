//
//  PlistPusher.m
//  filldatabase
//
//  Created by Alfiya on 17.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "PlistPusher.h"
#import "AllDefines.h"


#define PLIST_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:PLIST_NAME]
#define PLIST_BINARY_PATH [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:PLIST_BINARY_NAME]
#define SELECTION_KEYS @[@"event_enable", @"event_start_TS", @"event_end_TS", @"create_TS", @"modify_TS"]

@implementation PlistPusher

- (void) sendErrorNotification:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void){
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"DataErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
    });
}

- (void) sendDoneNotification:(NSString *)message withTackInfo: (NSDictionary *) tackInfo{
    [self sendErrorNotification:[NSString stringWithFormat:@"%@ %@", message, tackInfo[@"time"]]];
}

- (void) collectPlistFileInfo {
    if([[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
        [self sendErrorNotification:@"PList уже существует"];
    }
    else {
        [self sendErrorNotification:@"PList'а не было будем создавать"];
    }
}

- (void) collectBinaryPlistFileInfo {
    if([[NSFileManager defaultManager] fileExistsAtPath:PLIST_BINARY_PATH]) {
        [self sendErrorNotification:@"Бинарный PList уже существует"];
    }
    else {
        [self sendErrorNotification:@"Бинарный PList'а не было будем создавать"];
    }
}

- (NSDictionary *) getSelectionInfoForNote:(NSDictionary *)note {
    NSMutableDictionary *selectionHelperDictionary = [NSMutableDictionary dictionary];
    for (NSString *field in SELECTION_KEYS) {
        selectionHelperDictionary[field] = note[field] ? note[field] : @"";
    }
    return selectionHelperDictionary;
}

- (void) writeBinaryToSinglePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self collectBinaryPlistFileInfo];
        NSError *error = nil;
        TICK;
        NSData *representation = [NSPropertyListSerialization dataWithPropertyList:notes
                                                                            format:NSPropertyListXMLFormat_v1_0
                                                                           options:0
                                                                             error:&error];
        if (!error)
        {
            BOOL ok = [representation writeToFile:PLIST_BINARY_PATH
                                       atomically:YES];
            if (ok)
            {
                TACK;
                [self sendDoneNotification:@"Удалось записать данные в файл PList" withTackInfo:tackInfo];
            }
            else
            {
                [self sendErrorNotification:@"Не удалось записать данные в файл PList"];
            }
        }
        else
        {
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать данные для PList"];
        }
    });
}

- (void) writeArrayToSinglePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self collectPlistFileInfo];
        TICK;
        BOOL ok = [notes writeToFile:PLIST_PATH
                          atomically:YES];
        if (ok)
        {
            TACK;
            [self sendDoneNotification:@"Удалось записать данные в файл PList" withTackInfo: tackInfo];
        }
        else
        {
            [self sendErrorNotification:@"Не удалось записать данные в файл PList"];
        }
    });
}

- (void) writeBinaryToMultiplePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        self.rollbacked = NO;
        self.selectionHelper = [NSMutableDictionary dictionary];
        self.binaryNotesToPush = [NSMutableArray arrayWithArray:notes];
        TICK;
        while ( [self.binaryNotesToPush count] != 0 ) {
            if (self.rollbacked) {
                break;
            }
            NSTimer *notesToUpdateTimer = [NSTimer timerWithTimeInterval: 0.5
                                                                  target: self
                                                                selector: @selector( pushBinaryOneNote )
                                                                userInfo: nil
                                                                 repeats: NO];
            [notesToUpdateTimer fire];
        }
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization dataWithPropertyList:self.selectionHelper
                                                                            format:NSPropertyListXMLFormat_v1_0
                                                                           options:0
                                                                             error:&error];
        if (!error){
            BOOL ok = [representation
                       writeToFile:[DOCUMENTS_DIRECTORY stringByAppendingPathComponent:HELPER_BINARY_PLIST]
                       atomically:YES];
            if (!ok) {
                [self sendErrorNotification:@"Не удалось записать хелпер для выборки в файл PList"];
            }
            else {
                TACK;
                [self sendDoneNotification:@"Готово" withTackInfo:tackInfo];
            }
        }
        else{
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать хелпер для выборки для PList"];
        }
    });
}

- (void) writeDictionaryToMultiplePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        TICK;
        self.selectionHelper = [NSMutableDictionary dictionary];
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
        BOOL ok = [self.selectionHelper
                   writeToFile:[DOCUMENTS_DIRECTORY stringByAppendingPathComponent:HELPER_PLIST]
                   atomically:YES];
        if (!ok){
            [self sendErrorNotification:@"Не удалось записать хелпер для выборки в файл PList"];
        }
        else {
            TACK;
            [self sendDoneNotification:@"Готово" withTackInfo:tackInfo];
        }
    });
}

- (void) pushBinaryOneNote {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"%i", [self.binaryNotesToPush count]);
        NSError *error = nil;
        NSDictionary *note = self.notesToPush[0];
        self.selectionHelper[note[@"ID"]] = [self getSelectionInfoForNote: note];
        NSString *newPath = [MULTIPLE_BINARY_NOTES_FOLDER stringByAppendingString:note[@"ID"]];
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:note
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (!error){
            BOOL ok = [representation writeToFile:newPath atomically:YES];
            if (!ok) {
                [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
            }
        }
        else{
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать данные для PList"];
        }
        [self.notesToPush removeObjectAtIndex:0];
    });
}

- (void) pushOneNote {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSLog(@"%lu", (unsigned long)[self.notesToPush count]);
        NSDictionary *note = self.notesToPush[0];
        self.selectionHelper[note[@"ID"]] = [self getSelectionInfoForNote: note];
        NSString *newPath = [MULTIPLE_NOTES_FOLDER stringByAppendingString:note[@"ID"]];
        BOOL ok = [note writeToFile:newPath atomically:YES];
        if (!ok){
            [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
        }
        [self.notesToPush removeObjectAtIndex:0];
    });
}

@end

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
        selectionHelperDictionary[field] = note[field];
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
        TICK;
        NSMutableDictionary *selectionHelper = [NSMutableDictionary dictionary];
        for (NSDictionary *note in notes) {
            NSError *error = nil;
            selectionHelper[note[@"ID"]] = [self getSelectionInfoForNote: note];
            NSString *newPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:note[@"ID"]];
            NSData *representation = [NSPropertyListSerialization dataWithPropertyList:note
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
        }
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization dataWithPropertyList:selectionHelper
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
        NSMutableDictionary *selectionHelper = [NSMutableDictionary dictionary];
        for (NSDictionary *note in notes) {
            selectionHelper[note[@"ID"]] = [self getSelectionInfoForNote: note];
            NSString *newPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:note[@"ID"]];
            BOOL ok = [note writeToFile:newPath atomically:YES];
            if (!ok){
                [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
            }
        }
        BOOL ok = [selectionHelper
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

@end

//
//  PlistPusher.m
//  filldatabase
//
//  Created by Alfiya on 17.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "PlistPusher.h"
#import "AllDefines.h"

#define SELECTION_KEYS @[@"event_enable", @"event_start_TS", @"event_end_TS", @"create_TS", @"modify_TS"]

@implementation PlistPusher {
    NSMutableArray *_notesToPush;
    NSMutableArray *_notesToPushBinary;
    NSMutableDictionary *_helperPList;
    NSMutableDictionary *_helperPListBinary;
 
    BOOL _rollbackedMultiple;
    BOOL _rollbackedMultipleBinary;

    BOOL _timerFiredMultiple;
    BOOL _timerFiredMultipleBinary;
}

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
    if([[NSFileManager defaultManager] fileExistsAtPath:SINGLE_PLIST_PATH]) {
        [self sendErrorNotification:@"PList уже существует"];
    }
    else {
        [self sendErrorNotification:@"PList'а не было будем создавать"];
    }
}

- (void) collectBinaryPlistFileInfo {
    if([[NSFileManager defaultManager] fileExistsAtPath:SINGLE_PLIST_BINARY_PATH]) {
        [self sendErrorNotification:@"Бинарный PList уже существует"];
    }
    else {
        [self sendErrorNotification:@"Бинарный PList'а не было будем создавать"];
    }
}

- (BOOL) createDirectoryWithPath: (NSString *) path {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary
                              dictionaryWithObject:NSFileProtectionComplete
                              forKey:NSFileProtectionKey];
        [manager createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        return !error;
    }
    else {
        return NO;
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
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:notes
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (error) {
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать данные для PList"];
            return;
        }
        BOOL ok = [representation writeToFile:SINGLE_PLIST_BINARY_PATH
                                   atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать данные в файл PList"];
            return;
        }
        TACK;
        [self sendDoneNotification:@"Удалось записать данные в файл PList" withTackInfo:tackInfo];
    });
}

- (void) writeArrayToSinglePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self collectPlistFileInfo];
        TICK;
        BOOL ok = [notes writeToFile:SINGLE_PLIST_PATH
                          atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать данные в файл PList"];
            return;
        }
        TACK;
        [self sendDoneNotification:@"Удалось записать данные в файл PList" withTackInfo: tackInfo];
    });
}

- (void) writeDictionaryToMultiplePlistFile:(NSArray *)notes {
    // создадим папку для множественных заметок
    if (![self createDirectoryWithPath:MULTIPLE_PLIST_FOLDER]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        _notesToPush = [NSMutableArray arrayWithArray:notes];
        _timerFiredMultiple = YES;
        _helperPList = [NSMutableDictionary dictionary];
        TICK;
        while ([_notesToPush count] > 0) {
            if (_rollbackedMultiple) {
                break;
            }
            if (!_timerFiredMultiple) {
                sleep(0.1);
            }
            _timerFiredMultiple = NO;
            NSTimer *notesToUpdateTimer = [NSTimer
                                           timerWithTimeInterval: 0
                                           target: self
                                           selector: @selector( pushOneNote )
                                           userInfo: nil
                                           repeats: NO];
            [notesToUpdateTimer fire];
        }
        BOOL ok = [_helperPList
                   writeToFile:HELPER_PLIST_PATH
                   atomically:YES];
        if (!ok){
            [self sendErrorNotification:@"Не удалось записать хелпер для выборки в файл PList"];
            return;
        }
        TACK;
        [self sendDoneNotification:@"Пропушится мультипл " withTackInfo:tackInfo];
    });
}

- (void) writeBinaryToMultiplePlistFile:(NSArray *)notes {
    if (![self createDirectoryWithPath:MULTIPLE_BINARY_PLIST_FOLDER]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        _notesToPushBinary = [NSMutableArray arrayWithArray:notes];
        _helperPListBinary = [NSMutableDictionary dictionary];
        _timerFiredMultipleBinary = YES;
        TICK;
        while ([_notesToPushBinary count] > 0) {
            if (_rollbackedMultipleBinary) {
                break;
            }
            while (!_timerFiredMultipleBinary) {
                sleep(0.1);
            }
            NSTimer *notesToUpdateTimer = [NSTimer
                                           timerWithTimeInterval: 0
                                           target: self
                                           selector: @selector( pushBinaryOneNote )
                                           userInfo: nil
                                           repeats: NO];
            [notesToUpdateTimer fire];
        }
        NSError *error = nil;
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:_helperPListBinary
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (error) {
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать хелпер для выборки для PList"];
            return;
        }
        BOOL ok = [representation
                   writeToFile:HELPER_BINARY_PLIST_PATH
                   atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать хелпер для выборки в файл PList"];
            return;
        }
        TACK;
        [self sendDoneNotification:@"Пропушлися мультипл бинари " withTackInfo:tackInfo];
    });
}

- (void) pushOneNote {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSDictionary *note = _notesToPush[0];
        _helperPList[note[@"ID"]] = [self getSelectionInfoForNote: note];
        NSString *newPath = [MULTIPLE_PLIST_FOLDER stringByAppendingPathComponent:note[@"ID"]];
        BOOL ok = [note writeToFile:newPath atomically:YES];
        if (!ok){
            _rollbackedMultiple = YES;
            [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
            return;
        }
        [_notesToPush removeObjectAtIndex:0];
    });
    _timerFiredMultiple = YES;
}

- (void) pushBinaryOneNote {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        //
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error1 = nil;
        NSArray *notesInFolder = [manager contentsOfDirectoryAtPath:MULTIPLE_BINARY_PLIST_FOLDER error:&error1];
        NSLog(@"%lu %lu", (unsigned long)[notesInFolder count], (unsigned long)[_helperPListBinary count]);
        //
        
        NSError *error = nil;
        NSDictionary *note = _notesToPushBinary[0];
        _helperPListBinary[note[@"ID"]] = [self getSelectionInfoForNote: note];
        
        NSString *newPath = [MULTIPLE_BINARY_PLIST_FOLDER stringByAppendingPathComponent:note[@"ID"]];
        NSData *representation = [NSPropertyListSerialization
                                  dataWithPropertyList:note
                                  format:NSPropertyListXMLFormat_v1_0
                                  options:0
                                  error:&error];
        if (error) {
            _rollbackedMultipleBinary = YES;
            [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать данные для PList"];
            return;
        }
        BOOL ok = [representation writeToFile:newPath atomically:YES];
        if (!ok) {
            [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
            _rollbackedMultipleBinary = YES;
            return;
        }
        [_notesToPushBinary removeObjectAtIndex:0];
    });
}

@end

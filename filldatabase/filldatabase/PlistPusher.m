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
@implementation PlistPusher

- (void) sendErrorNotification:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void){
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"DataErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
    });
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

- (void) writeBinaryToSinglePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self collectBinaryPlistFileInfo];
        NSError *error = nil;
        TICK;
        NSData *representation = [NSPropertyListSerialization dataWithPropertyList:notes
                                                                            format:NSPropertyListXMLFormat_v1_0 options:0
                                                                             error:&error];
        if (!error)
        {
            BOOL ok = [representation writeToFile:PLIST_BINARY_PATH
                                       atomically:YES];
            if (ok)
            {
                [self sendErrorNotification:@"Удалось записать данные в файл PList"];
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
        TACK;
        NSLog(@"Push to single PList binary: %@", tackInfo);
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
            [self sendErrorNotification:@"Удалось записать данные в файл PList"];
        }
        else
        {
            [self sendErrorNotification:@"Не удалось записать данные в файл PList"];
        }
        TACK;
        NSLog(@"Push to single PList from array: %@", tackInfo);
    });
}

- (void) writeBinaryToMultiplePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        TICK;
        for (NSDictionary *note in notes) {
            NSError *error = nil;
            NSString *newPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:note[@"ID"]];
            NSData *representation = [NSPropertyListSerialization dataWithPropertyList:note format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
            if (!error)
            {
                BOOL ok = [representation writeToFile:newPath atomically:YES];
                if (!ok) {
                    [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
                }
            }
            else
            {
                [self sendErrorNotification:@"Пичаль=((( Не удалось сериализовать данные для PList"];
            }
        }
        TACK;
        NSLog(@"Push to multiple PList binary: %@", tackInfo);
    });
}

- (void) writeDictionaryToMultiplePlistFile:(NSArray *)notes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        TICK;
        for (NSDictionary *note in notes) {
            NSString *newPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:note[@"ID"]];
            BOOL ok = [note writeToFile:newPath atomically:YES];
            if (!ok){
                [self sendErrorNotification:@"Не удалось записать заметку в файл PList"];
            }
        }
        TACK;
        NSLog(@"Push to multiple PList binary: %@", tackInfo);
    });
}

@end

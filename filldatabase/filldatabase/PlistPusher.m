//
//  PlistPusher.m
//  filldatabase
//
//  Created by Alfiya on 17.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "PlistPusher.h"
#import "AllDefines.h"

@implementation PlistPusher

- (void) sendErrorNotification:(NSString *)message {
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"DataErrorNotification"
     object: nil
     userInfo: @{@"message": message}];
}

- (id) init {
    self = [super init];
    if (self) {
        [self collectPlistFileInfo];
    }
    return self;
}

- (void) collectPlistFileInfo {
    NSString *plistPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:PLIST_NAME];
    if([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [self sendErrorNotification:@"PList уже существует"];
    }
    else {
        [self sendErrorNotification:@"PList'а не было будем создавать"];
    }
}

- (void) writeToPlistFile:(NSDictionary *)notes {
    NSString *plistPath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:PLIST_NAME];
    NSError *error = nil;
    NSData *representation = [NSPropertyListSerialization dataWithPropertyList:notes format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (!error)
    {
        BOOL ok = [representation writeToFile:plistPath atomically:YES];
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
}

@end

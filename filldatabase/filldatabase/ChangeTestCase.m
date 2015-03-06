//
//  ChangeTextCase.m
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ChangeTestCase.h"
#import "AllDefines.h"

@implementation ChangeTestCase {
    dispatch_queue_t _testCaseQUeue;
}

- (id) init {
    self = [super init];
    if (self) {
        _testCaseQUeue = dispatch_queue_create("com.testcases.queue", DISPATCH_QUEUE_SERIAL);
        [self run];
    }
    return self;
}

- (void) sendDoneNotification: (NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TastCaseFinishedNotification"
         object:nil
         userInfo:@{@"message": message}];
    });
}

- (void) sendTCDoneNotification: (NSString *) storageType
                   withTackInfo: (NSDictionary *) tackInfo {
    NSString *message = [NSString stringWithFormat:@"Change TC finished %@ %@", storageType, tackInfo[@"time"]];
    [self sendDoneNotification:message];
}
- (void) callTestCaseWithStoraType: (NSString *) storageType {
    if ([storageType isEqualToString:@"DataBase"]) {
        dispatch_async(_testCaseQUeue, ^(void) {
            TICK;
            [self.storage changeNotesFromDataBaseWithNotesData:[self.storage getIDsToChangeFromDataBase]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"SinglePList"]) {
        dispatch_async(_testCaseQUeue, ^(void) {
            TICK;
            [self.storage changeNotesFromSinglePListWithNoteIDs:[self.storage getIDsToChangeFromSinglePList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"SingleBinaryPList"]) {
        dispatch_async(_testCaseQUeue, ^(void) {
            TICK;
            [self.storage changeNotesFromSingleBinaryPListWithNoteIDs:[self.storage getIDsToChangeFromSingleBinaryPList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"MultiplePList"]) {
        dispatch_async(_testCaseQUeue, ^(void) {
            TICK;
            [self.storage changeNotesFromMultiplePListWithNoteIDs:[self.storage getIDsToChangeFromMultiplePList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"MultipleBinaryPList"]) {
        dispatch_async(_testCaseQUeue, ^(void) {
            TICK;
            [self.storage changeNotesFromMultipleBinaryPListWithNoteIDs:[self.storage getIDsToChangeFromMultipleBinaryPList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else {
        [self sendDoneNotification:@"Выслан некорректный тип стореджа"];
    }
}

- (void) run {
    self.storage = [[ChangeNotesLauncher alloc] init];
    for (NSString *dataStorage in DATA_STORAGES) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end

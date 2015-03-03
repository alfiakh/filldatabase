//
//  DropTestCase.m
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DropTestCase.h"
#import "AllDefines.h"

@implementation DropTestCase

- (id) init {
    self = [super init];
    if (self) {
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

//- (void) callTestCaseWithStoraType: (NSString *) storageType {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        // собираем строки для селекторов
//        NSString *getIDsSelectorName = [NSString stringWithFormat:@"getIDsToDropFrom%@", storageType];
//        NSString *dropNotesSelectorName = [NSString stringWithFormat:@"dropNotesFrom%@WithNoteIDs", storageType];
//        
//        // создаем селекторы
//        SEL getIDsSelector = NSSelectorFromString(getIDsSelectorName);
//        SEL dropNotesSelector = NSSelectorFromString(dropNotesSelectorName);
//                NSLog(@"%@ %@ %@", dropNotesSelectorName, [self.storage respondsToSelector:getIDsSelector] ? @"YES" : @"NO", [self.storage respondsToSelector:dropNotesSelector] ? @"YES" : @"NO");
//        // сам вызов
//        TICK;
//        NSArray *IDs = [self.storage performSelector:getIDsSelector];
//
////        NSInvocation *dropNotesInvocation = [NSInvocation new];
//        NSMethodSignature *signature = [self.storage methodSignatureForSelector:dropNotesSelector];
//        NSInvocation *dropNotesInvocation = [NSInvocation invocationWithMethodSignature:@selector(signature:NSArray *)];
//        [dropNotesInvocation setSelector:dropNotesSelector];
//        [dropNotesInvocation setArgument:&IDs atIndex:2];
//        [dropNotesInvocation setTarget:self.storage];
//        [dropNotesInvocation invoke];
//        TACK;
//        
//        NSString *message = [NSString stringWithFormat:@"Drop TC finished %@ %@", storageType, tackInfo[@"time"]];
//        [self sendDoneNotification:message];
//    });
//}

- (void) sendTCDoneNotification: (NSString *) storageType
                   withTackInfo: (NSDictionary *) tackInfo {
    NSString *message = [NSString stringWithFormat:@"Drop TC finished %@ %@", storageType, tackInfo[@"time"]];
    [self sendDoneNotification:message];
}

- (void) callTestCaseWithStoraType: (NSString *) storageType {
    if ([storageType isEqualToString:@"DataBase"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            TICK;
            [self.storage dropNotesFromDataBasetWithNoteIDs:[self.storage getIDsToDropFromDataBase]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"SinglePList"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            TICK;
            [self.storage dropNotesFromSinglePListWithNoteIDs:[self.storage getIDsToDropFromSinglePList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"SingleBinaryPList"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            TICK;
            [self.storage dropNotesFromSingleBinaryPListWithNoteIDs:[self.storage getIDsToDropFromSingleBinaryPList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"MultiplePList"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            TICK;
            [self.storage dropNotesFromMultiplePListWithNoteIDs:[self.storage getIDsToDropFromMultiplePList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else if ([storageType isEqualToString:@"MultipleBinaryPList"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            TICK;
            [self.storage dropNotesFromMultipleBinaryPListWIthNoteIDs:[self.storage getIDsToDropFromMultipleBinaryPList]];
            TACK;
            [self sendTCDoneNotification:storageType withTackInfo:tackInfo];
        });
    }
    else {
        [self sendDoneNotification:@"Выслан некорректный тип стореджа"];
    }
}

- (void) run {
    self.storage = [[DropDataStorage alloc] init];
    for (NSString *dataStorage in @[@"MultiplePList"]) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end

//
//  ChangeTextCase.m
//  filldatabase
//
//  Created by Alfiya on 01.03.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ChangeTestCase.h"
#import "AllDefines.h"

@implementation ChangeTestCase

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

- (void) callTestCaseWithStoraType: (NSString *) storageType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *getIDsSelectorName = [NSString stringWithFormat:@"getIDsToChangeFrom%@", storageType];
        SEL getIDsSelector = NSSelectorFromString(getIDsSelectorName);
        NSString *changeNotesSelectorName = [NSString stringWithFormat:@"changeNotesFrom%@tWithNoteIDs", storageType];
        SEL changeNotesSelector = NSSelectorFromString(changeNotesSelectorName);
        NSInvocation *changeNotesInvocation = [NSInvocation new];
        NSInvocation *getIDsInvocation = [NSInvocation new];
        [changeNotesInvocation setSelector:changeNotesSelector];
        [getIDsInvocation setSelector:getIDsSelector];
        [getIDsInvocation invokeWithTarget:self.storage];
        NSArray *IDs;
        [getIDsInvocation getReturnValue:&IDs];
        [changeNotesInvocation setArgument:&IDs atIndex:0];
        TICK;
        [changeNotesInvocation invokeWithTarget:self.storage];
        TACK;
        NSString *message = [NSString stringWithFormat:@"Change TC finished %@ %@", storageType, tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
}

- (void) run {
    self.storage = [[ChangeNotesStorage alloc] init];
    for (NSString *dataStorage in DATA_STORAGES) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end

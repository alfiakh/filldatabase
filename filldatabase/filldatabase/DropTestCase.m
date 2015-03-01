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

- (void) callTestCaseWithStoraType: (NSString *) storageType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // собираем строки для селекторов
        NSString *getIDsSelectorName = [NSString stringWithFormat:@"getIDsToChangeFrom%@", storageType];
        NSString *changeNotesSelectorName = [NSString stringWithFormat:@"changeNotesFrom%@tWithNoteIDs", storageType];
        
        // создаем селекторы
        SEL getIDsSelector = NSSelectorFromString(getIDsSelectorName);
        SEL changeNotesSelector = NSSelectorFromString(changeNotesSelectorName);
        
        // создаем объекты NSInvocation
        NSInvocation *changeNotesInvocation = [NSInvocation new];
        NSInvocation *getIDsInvocation = [NSInvocation new];
        
        // подвязываем invocation к селекторам
        [changeNotesInvocation setSelector:changeNotesSelector];
        [getIDsInvocation setSelector:getIDsSelector];
        
        // вызываем получение ID заметок для изменения
        [getIDsInvocation invokeWithTarget:self.storage];
        
        // создаем пространство для резултьтата и получаем результат
        NSArray *IDs;
        [getIDsInvocation getReturnValue:&IDs];
        
        // устанавливаем аргумент у invocation
        [changeNotesInvocation setArgument:&IDs atIndex:0];
        
        // сам вызов
        TICK;
        [changeNotesInvocation invokeWithTarget:self.storage];
        TACK;
        
        NSString *message = [NSString stringWithFormat:@"Change TC finished %@ %@", storageType, tackInfo[@"time"]];
        [self sendDoneNotification:message];
    });
}

- (void) run {
    self.storage = [[DropDataStorage alloc] init];
    for (NSString *dataStorage in DATA_STORAGES) {
        [self callTestCaseWithStoraType:dataStorage];
    }
}

@end

//
//  ViewController.m
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "PushToStorageViewController.h"

#import "AllDefines.h"
#import "SADictionaryAddtions.h"
#import "PlistPusher.h"

@interface PushToStorageViewController ()

@end

@implementation PushToStorageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleError:)
                                                 name:@"DataErrorNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRequestDone:)
                                                 name:@"RequestDoneNotification"
                                               object:nil];
}

- (void) handleError: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
}

- (void) runRequestWithUserID: (NSString *) userID
                withTImeStamp: (NSNumber *) timeStamp {
    NSString *listUrl = [self.getter collectUrlForListWithUserID:userID
                                                   lastTimeStamp:[timeStamp integerValue]
                                                      notesCount:[NOTES_COUNT integerValue]];
    [self.getter runRequestWithUrl:listUrl];
}

- (void) handleRequestDone: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
    if (!self.responseData) {
        self.responseData = [NSMutableArray array];
    }
    
    [self.responseData addObjectsFromArray: notification.userInfo[@"notes"]];
    int notesLength = [notification.userInfo[@"notes"] count];
    
    if ([notification.userInfo[@"notes"] count] == 1000) {
        NSNumber *lastModifyTS = notification.userInfo[@"notes"][notesLength - 1][@"modify_TS"];
        [self runRequestWithUserID:[ACCOUNTS objectAtIndex:self.accountNumber]
                     withTImeStamp:lastModifyTS];
    }
    else if (self.accountNumber == [ACCOUNTS count] - 1){
        [self addToConsole:[NSString stringWithFormat:@"Загрузили все заметки. Количество :%i", [self.responseData count]]];
    }
    else {
        self.accountNumber++;
        [self runRequestWithUserID:[ACCOUNTS objectAtIndex:self.accountNumber]
                     withTImeStamp:[self.getter giveMeTS]];
    }
}

- (BOOL) checkDidResponseRecieve {
    if (!self.responseData) {
        [self addToConsole:@"Вы еще не загружали данных. Нажмите на кнопку \"Загрузить\""];
    }
    return !!self.responseData;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadNotes:(id)sender {
    self.responseData = [NSMutableArray array];
    [self addToConsole:@"Пошел запрос"];
    self.accountNumber = 0;
    self.getter = [[DataGetter alloc] init];
    NSString *listUrl = [self.getter
                         collectUrlForListWithUserID:[ACCOUNTS objectAtIndex:self.accountNumber]
                          lastTimeStamp:[[self.getter giveMeTS] integerValue]
                             notesCount:[NOTES_COUNT integerValue]];
    NSLog(@"URL: %@", listUrl);
    [self.getter runRequestWithUrl:listUrl];
}

- (IBAction)pushNotes:(id)sender {
    [self clearConsole];
    if ([self checkDidResponseRecieve]){
        DataPusher *pusher = [[DataPusher alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            [pusher pushNotesFromResponse:self.responseData];
    
        });
    }
}

- (IBAction)pushBinaryToSinglePList:(id)sender {
    [self clearConsole];
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToSinglePlistFile:self.responseData];
    }
}

- (IBAction)pushArrayToSinglePList:(id)sender {
    [self clearConsole];
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeArrayToSinglePlistFile:self.responseData];
    }
}

- (IBAction)pushBinaryToMultiplePList:(id)sender {
    [self clearConsole];
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToMultiplePlistFile:self.responseData];
    }
}

- (IBAction)pushDictionaryToMultiplePList:(id)sender {
    [self clearConsole];
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeDictionaryToMultiplePlistFile:self.responseData];
    }
}

- (void) addToConsole: (NSString *) message {
    NSString *appendingString = [@"\n" stringByAppendingString:message];
    self.console.text = [self.console.text stringByAppendingString:appendingString];
}

- (void) clearConsole {
    self.console.text = @"";
}
@end

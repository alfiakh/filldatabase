//
//  ViewController.m
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ViewController.h"

#import "AllDefines.h"
#import "SADictionaryAddtions.h"
#import "PlistPusher.h"

@interface ViewController ()

@end

@implementation ViewController

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

- (void) handleRequestDone: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
    if (!self.responseData) {
        self.responseData = [NSMutableArray array];
    }
    
    [self.responseData addObjectsFromArray: notification.userInfo[@"notes"]];
    int notesLength = [notification.userInfo[@"notes"] count];
    
    if ([notification.userInfo[@"notes"] count] == 1000) {
        NSNumber *lastModifyTS = notification.userInfo[@"notes"][notesLength - 1][@"modify_TS"];
        NSString *listUrl = [self.getter collectUrlForListWithUserID:USER_ID
                                                       lastTimeStamp:[lastModifyTS integerValue]
                                                          notesCount:[NOTES_COUNT integerValue]];
        [self addToConsole:@"Пошел запрос"];
        [self.getter runRequestWithUrl:listUrl];
    }
    else {
        [self addToConsole:[NSString stringWithFormat:@"Загрузили все заметки. Количество :%i", [self.responseData count]]];
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
    [self addToConsole:@"Пошел запрос"];
    self.getter = [[DataGetter alloc] init];
    NSArray *currentTimeStamps = [self.getter giveMeTS];
    NSString *listUrl = [self.getter collectUrlForListWithUserID:USER_ID
                          lastTimeStamp:[currentTimeStamps[0] integerValue]
                             notesCount:[NOTES_COUNT integerValue]];
    [self.getter runRequestWithUrl:listUrl];
}

- (IBAction)pushNotes:(id)sender {
    if ([self checkDidResponseRecieve]){
        DataPusher *pusher = [[DataPusher alloc] init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            [pusher pushNotesFromResponse:self.responseData];
    
        });
    }
}

- (IBAction)pushBinaryToSinglePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToSinglePlistFile:self.responseData];
    }
}

- (IBAction)pushArrayToSinglePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeArrayToSinglePlistFile:self.responseData];
    }
}

- (IBAction)pushBinaryToMultiplePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToMultiplePlistFile:self.responseData];
    }
}

- (IBAction)pushDictionaryToMultiplePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeDictionaryToMultiplePlistFile:self.responseData];
    }
}

- (void) addToConsole: (NSString *) message {
    NSString *appendingString = [@"\n" stringByAppendingString:message];
    self.console.text = [self.console.text stringByAppendingString:appendingString];
}

@end

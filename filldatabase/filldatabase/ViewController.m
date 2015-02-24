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

- (id) init {
    self = [super init];
    if (self) {
        //some code
    }
    return self;
}

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
    self.responseData = notification.userInfo[@"data"];
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
    DataGetter *getter = [[DataGetter alloc] init];
    NSArray *currentTimeStamps = [getter giveMeTS];
    NSString *listUrl = [getter collectUrlForListWithUserID:USER_ID
                          lastTimeStamp:[currentTimeStamps[0] integerValue]
                             notesCount:[NOTES_COUNT integerValue]];
    [getter runRequestWithUrl:listUrl];
}

- (IBAction)pushNotes:(id)sender {
    if ([self checkDidResponseRecieve]){
        DataPusher *pusher = [[DataPusher alloc] init];
        [pusher pushNotesFromResponse:self.responseData];
    }
}

- (IBAction)pushBinaryToSinglePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToSinglePlistFile:self.responseData[@"data"]];
    }
}

- (IBAction)pushArrayToSinglePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeArrayToSinglePlistFile:self.responseData[@"data"]];
    }
}

- (IBAction)pushBinaryToMultiplePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeBinaryToMultiplePlistFile:self.responseData[@"data"]];
    }
}

- (IBAction)pushDictionaryToMultiplePList:(id)sender {
    if ([self checkDidResponseRecieve]) {
        PlistPusher *pusher = [[PlistPusher alloc] init];
        [pusher writeDictionaryToMultiplePlistFile:self.responseData[@"data"]];
    }
}

- (void) addToConsole: (NSString *) message {
    NSString *appendingString = [@"\n" stringByAppendingString:message];
    self.console.text = [self.console.text stringByAppendingString:appendingString];
}

@end

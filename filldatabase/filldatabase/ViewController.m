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
}

- (void) handleError: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
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
    if (!self.responseData) {
        [self addToConsole:@"Вы еще не загружали данных. Нажмите на кнопку \"Загрузить\""];
    }
    else {
        DataPusher *pusher = [[DataPusher alloc] init];
        [pusher pushNotesFromResponse:self.responseData];
    }
}

- (void) addToConsole: (NSString *) message {
    NSString *appendingString = [@"\n" stringByAppendingString:message];
    self.console.text = [self.console.text stringByAppendingString:appendingString];
}

@end

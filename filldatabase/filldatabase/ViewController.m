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

- (id)init {
    self = [super init];
    if (self) {
        //some code
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRequestError:)
                                                 name:@"DataGetterDetectedRequestErrorNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWrongStatusCode:)
                                                 name:@"DataGetterDetectedWrongStatusCodeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleErrorEncodingJson:)
                                                 name:@"DataGetterDetectedErrorEncodingJsonNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWrongSrvMessageCode:)
                                                 name:@"DataGetterDetectedWrongSrvMessageCodeNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotesLoaded:)
                                                 name:@"DataGetterNotesLoadedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDatabaseExisted:)
                                                 name:@"DataPusherDatabaseExistedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDatabaseDidntExist:)
                                                 name:@"DataPusherDatabaseDidntExistNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDatabaseOpened:)
                                                 name:@"DataPusherDatabaseOpenedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDatabaseFailedToOpen:)
                                                 name:@"DataPusherDatabaseFailedToOpenNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BeginTransactionFail:)
                                                 name:@"DataPusherBeginTransactionFailNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCommitTransactionFail:)
                                                 name:@"DataPusherCommitTransactionFailNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRollBackTransactionFail:)
                                                 name:@"DataPusherRollBackTransactionFailNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTransactionRollbacked:)
                                                 name:@"DataPusherTransactionRollbackedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCreatedNoteTable:)
                                                 name:@"DataPusherCreatedNoteTableNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOldNotesDeleted:)
                                                 name:@"DataPusherOldNotesDeletedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotesPushed:)
                                                 name:@"DataPusherNotesPushedNotification"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
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

- (void) handleRequestError:(NSNotification *)notification {
    [self addToConsole: @"Произошла ошибка при отправке запроса"];
}

- (void) handleWrongStatusCode:(NSNotification *)notification {
    [self addToConsole: @"Запрос пришел с некорректным статус кодом"];
}

- (void) handleWrongSrvMessageCode:(NSNotification *)notification {
    [self addToConsole: @"Произошла логическая ошибка при отправке запроса. Неверный srvMessageCode"];
}

- (void) handleErrorEncodingJson:(NSNotification *)notification {
    [self addToConsole: @"Произошла ошибка при декодировании JSON-ответа"];
}

- (void) handleNotesLoaded:(NSNotification *)notification {
    [self addToConsole: @"Congratulations! Заметки загружены и декодированы"];
    self.responseData = notification.userInfo[@"responseData"];
}

- (void) handleDatabaseExisted:(NSNotification *)notification {
    [self addToConsole: @"База уже была создана"];
}

- (void) handleDatabaseDidntExist:(NSNotification *)notification {
    [self addToConsole: @"Базы раньше не было"];
}

- (void) handleDatabaseOpened:(NSNotification *)notification {
    [self addToConsole: @"Удалось открыть базу"];
}

- (void) handleDatabaseFailedToOpen:(NSNotification *)notification {
    [self addToConsole: @"Не удалось открыть базу"];
}

- (void) BeginTransactionFail:(NSNotification *)notification {
    [self addToConsole: @"Не удалось начать транзакцию"];
}

- (void) handleCommitTransactionFail:(NSNotification *)notification {
    [self addToConsole: @"Не удалось закоммитить транзакцию"];
}

- (void) handleRollBackTransactionFail:(NSNotification *)notification {
    [self addToConsole: @"Не удалось откатить транзакцию"];
}

- (void) handleTransactionRollbacked:(NSNotification *)notification {
    [self addToConsole: @"Откатили транзакцию"];
}

- (void) handleCreatedNoteTable:(NSNotification *)notification {
    [self addToConsole: @"Таблица note успешно создана"];
}

- (void) handleOldNotesDeleted:(NSNotification *)notification {
    [self addToConsole: @"Старые записи в таблице note удалены"];
}

- (void) handleNotesPushed:(NSNotification *)notification {
    [self addToConsole: @"Заметки успешно залиты в базу"];
}

@end

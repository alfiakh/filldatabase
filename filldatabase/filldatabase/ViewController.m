//
//  ViewController.m
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "ViewController.h"
#import "DataGetter.h"
#import "DataPusher.h"
#import "AllDefines.h"
#import "SADictionaryAddtions.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadNotes:(id)sender {
    self.console.text = [self.console.text stringByAppendingString:@"\nПошел запрос"];
    DataGetter *getter = [[DataGetter alloc] init];
    NSArray *currentTimeStamps = [getter giveMeTS];
    NSString *listUrl = [getter collectUrlForListWithUserID:USER_ID
                          lastTimeStamp:[currentTimeStamps[0] integerValue]
                             notesCount:[NOTES_COUNT integerValue]];
    [getter runRequestWithUrl:listUrl];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_group_wait(getter.requestGroup, DISPATCH_TIME_FOREVER);
//        NSLog(@"%@", getter.requestError);
//        NSLog(@"%ld", getter.statusCode);
//        NSLog(@"%@", getter.jsonParsingError);
//        NSLog(@"%ld", (long)getter.srvMessageCode);
//        NSLog(@"%ld", getter.notesCount);
//        NSLog(@"statusCode: %ld", getter.statusCode);
        if (getter.requestError) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.console.text = [self.console.text stringByAppendingString:@"\nНеизвестная ошибка при отправке запроса"];
            });
        }
        else if (getter.statusCode != 200){
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSString *incorrectStatusCodeMessage = [NSString stringWithFormat:@"\nНекорректный статус-код ответа. Код %ld", (long)getter.statusCode];
                self.console.text = [self.console.text stringByAppendingString:incorrectStatusCodeMessage];
            });
        }
        else if (getter.jsonParsingError) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.console.text = [self.console.text stringByAppendingString:@"\nПроизошла ошибка при сериализации JSON"];
            });
        }
        else if (getter.srvMessageCode && getter.srvMessageCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSString *logicalError = [NSString stringWithFormat:@"\nПроизошла логическая ошибка при отправке запроса на сервер. Код %i.", (int)getter.srvMessageCode];
                self.console.text = [self.console.text stringByAppendingString:logicalError];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSString *notesRecievedMessage = [NSString stringWithFormat:@"\nЗапрос вернул корректный ответ. Получено %ld заметок", (long)getter.notesCount];
                self.console.text = [self.console.text stringByAppendingString:notesRecievedMessage];
            });
            self.responseData = getter.responseData;
        }
    }
    );
}

- (void) addToConsole: (NSString *) message {
    self.console.text = [self.console.text stringByAppendingString:message];
}

- (IBAction)pushNotes:(id)sender {
    if (!self.responseData) {
        [self addToConsole:@"\nВЫ НЕ НАЖАЛИ КНОПКУ \"Загрузить\"!!!"];
    }
    else {
    DataPusher *pusher = [[DataPusher alloc] init];
    [pusher createDataBase];
    if (!pusher.databaseExisted) {
        [self addToConsole:@"\nБазы не было, создали"];
    }
    else {
        [self addToConsole:@"\nБаза уже была"];
    }
    if (pusher.databaseOpened) {
        [self addToConsole:@"\nУдалось открыть базу"];
        BOOL noteTableCreated = [pusher createNoteTable];
        if (!noteTableCreated) {
            [self addToConsole:@"\nНе удалось создать таблицу note"];
        }
        else {
            [self addToConsole:@"\nТаблица note создана либо уже была"];
            BOOL oldRowsDeleted = [pusher deleteAllOldNotes];
            if (!oldRowsDeleted) {
                [self addToConsole:@"\nНе удалось удалить старые записи из таблицы note"];
            }
            else {
                [self addToConsole:@"\nСтарые заметки удалены"];
                
            }
        }
    }
    else {
        [self addToConsole:@"\nБаза не была открыта"];
    }
    }
}

@end

//
//  ViewController.h
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "DataGetter.h"
#import "DataPusher.h"

@interface ViewController : UIViewController

- (void) addToConsole: (NSString *) message;
- (void) handleRequestError: (NSNotification *) notification;
- (void) handleWrongStatusCode: (NSNotification *) notification;
- (void) handleErrorEncodingJson: (NSNotification *) notification;
- (void) handleWrongSrvMessageCode: (NSNotification *) notification;
- (void) handleNotesLoaded: (NSNotification *) notification;


- (void) handleDatabaseExisted: (NSNotification *) notification;
- (void) handleDatabaseDidntExist: (NSNotification *) notification;
- (void) handleDatabaseOpened: (NSNotification *) notification;
- (void) handleDatabaseFailedToOpen: (NSNotification *) notification;
- (void) BeginTransactionFail: (NSNotification *) notification;
- (void) handleCommitTransactionFail: (NSNotification *) notification;
- (void) handleRollBackTransactionFail: (NSNotification *) notification;
- (void) handleTransactionRollbacked: (NSNotification *) notification;
- (void) handleCreatedNoteTable: (NSNotification *) notification;
- (void) handleOldNotesDeleted: (NSNotification *) notification;
- (void) handleNotesPushed: (NSNotification *) notification;

@property (weak, nonatomic) IBOutlet UITextView *console;
@property NSDictionary *responseData;
@property DataGetter *getter;

@end


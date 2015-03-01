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

@interface PushToStorageViewController : UIViewController

- (void) addToConsole: (NSString *) message;
- (void) handleError: (NSNotification *) notification;
- (void) handleRequestDone: (NSNotification *) notification;

@property (weak, nonatomic) IBOutlet UITextView *console;
@property NSMutableArray *responseData;
@property DataGetter *getter;
@property NSUInteger accountNumber;

@end


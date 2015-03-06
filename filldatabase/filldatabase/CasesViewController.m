//
//  CasesViewController.m
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "CasesViewController.h"
#import "NotepadDataSelection.h"
#import "DateRangeDataSelection.h"
#import "FirstTestCase.h"
#import "SecondTestCase.h"
#import "ThirdTestCase.h"
#import "ChangeTestCase.h"
#import "DropTestCase.h"

@interface CasesViewController ()

@end

@implementation CasesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFinishedSelection:)
                                                 name:@"TastCaseFinishedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFinishedSelection:)
                                                 name:@"StorageErrorNotification"
                                               object:nil];
}

- (void) handleFinishedSelection: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
}

- (void) addToConsole: (NSString *) message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSString *appendingString = [@"\n" stringByAppendingString:message];
        self.console.text = [self.console.text stringByAppendingString:appendingString];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firstCase:(id)sender {
    FirstTestCase *testCase = [[FirstTestCase alloc] init];
    [testCase run];
}

- (IBAction)secondCase:(id)sender {
    SecondTestCase *testCase = [[SecondTestCase alloc] init];
    [testCase run];
}

- (IBAction)thirdCase:(id)sender {
    ThirdTestCase *testCase = [[ThirdTestCase alloc] init];
    [testCase run];
}

- (IBAction)changeManyNotes:(id)sender {
    [[ChangeTestCase alloc] init];
}

- (IBAction)deleteManyNotes:(id)sender {
    [[DropTestCase alloc] init];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

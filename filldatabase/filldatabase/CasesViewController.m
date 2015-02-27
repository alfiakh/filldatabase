//
//  CasesViewController.m
//  filldatabase
//
//  Created by Alfiya on 24.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "CasesViewController.h"
#import "NotepadDataStorage.h"
#import "DateRangeDataStorage.h"
#import "FirstTestCase.h"
#import "SecondTestCase.h"
#import "ThirdTestCase.h"

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
                                                 name:@"DataStorageErrorNotification"
                                               object:nil];
}

- (void) handleFinishedSelection: (NSNotification *) notification {
    [self addToConsole: notification.userInfo[@"message"]];
}

- (void) addToConsole: (NSString *) message {
    NSString *appendingString = [@"\n" stringByAppendingString:message];
    self.console.text = [self.console.text stringByAppendingString:appendingString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firstCase:(id)sender {
    [[FirstTestCase alloc] init];
}

- (IBAction)secondCase:(id)sender {
    [[SecondTestCase alloc] init];
}

- (IBAction)thirdCase:(id)sender {
    [[ThirdTestCase alloc] init];
}

- (IBAction)changeManyNotes:(id)sender {
}

- (IBAction)deleteManyNotes:(id)sender {
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

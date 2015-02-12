//
//  ViewController.h
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *console;
@property NSDictionary *responseData;

@end


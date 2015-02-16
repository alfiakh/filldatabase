//
//  DataGetter.h
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataGetter : NSObject

- (NSArray *) giveMeTS;
- (NSString *) collectAuthPartWithUserID: (NSString *) userID;
- (NSString *) collectCmdPartForListWithCount:(NSInteger) count lastTimeStamp: (NSInteger) timestamp;
- (NSString *) collectTailPart;
- (NSString *) collectUrlForListWithUserID: (NSString *) userID
                             lastTimeStamp: (NSInteger) timestamp
                                notesCount: (NSInteger) count;
- (void) runRequestWithUrl: (NSString*) url;
- (void) decodeJsonData: (NSData*) data;
- (void) createErrorNotification: (NSString *) message;
- (void) createDoneRequestNotification: (NSString *) message withResponseData: (NSDictionary *) data;

@end

//
//  DataGetter.m
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DataGetter.h"
#import "AllDefines.h"
#import "JSONKit.h"

@implementation DataGetter

- (NSNumber *) giveMeTS {
    int ts = [[NSDate date] timeIntervalSince1970];
    return @(ts);
}

- (NSString *) collectAuthPartWithUserID: (NSString *) userID{
    NSString *authPart = [NSString stringWithFormat:@"u:%@_s:%@_d:4ad674c0-b0be-48ff-b7eb-0f788ceda519_r:8ef0e934-cda9-4a7c-9b41-77b3958c2910_t:%@", userID, TESTER_SIGNATURE, [self giveMeTS]];
    return authPart;
}

- (NSString *) collectCmdPartForListWithCount:(NSInteger)count lastTimeStamp:(NSInteger)timestamp{
    NSString *cmdPart = [NSString stringWithFormat:@"list:note,modify,%ld,0,%ld", (long)timestamp, (long) count];
    return cmdPart;
}

- (NSString *) collectTailPart {
    NSString *tailPart = [NSString stringWithFormat:@"?_%@", [self giveMeTS]];
    return tailPart;
}

- (NSString *) collectUrlForListWithUserID:(NSString *)userID
                            lastTimeStamp:(NSInteger)timestamp
                               notesCount:(NSInteger)noteCount{
    NSString *authPart = [self collectAuthPartWithUserID:userID];
    NSString *cmdPart = [self collectCmdPartForListWithCount:noteCount lastTimeStamp: timestamp];
    NSString *tailPart = [self collectTailPart];
    NSString *url = [NSString stringWithFormat:@"http://%@/api/v2/%@/%@/%@", API_NODE, authPart, cmdPart, tailPart];
    return url;
}

- (void) createErrorNotification:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DataErrorNotification"
         object:nil
         userInfo:@{@"message": message}];
    });
}

- (void) createDoneRequestNotification: (NSString *) message withResponseData: (NSDictionary *) data {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RequestDoneNotification"
         object:nil
         userInfo:@{@"message": message, @"notes": data[@"data"]}];
    });
}

- (void) runRequestWithUrl: (NSString *) url {
    NSURLSession *session = [NSURLSession sharedSession];
    TICK;
    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithURL:[NSURL URLWithString:url]
                                      completionHandler:^(
                                                          NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
                                          if (!error) {
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              if([httpResponse statusCode] == 200) {
                                                  [self decodeJsonData:data];
                                              }
                                              else {
                                                  NSString *errorMessage = [NSString stringWithFormat:@"Получен некорректный статус код %ld", (long)[httpResponse statusCode]];
                                                  [self createErrorNotification:errorMessage];
                                              }
                                          }
                                          else {
                                              [self createErrorNotification: @"Произошла ошибка при отправке запроса"];
                                          }
                                          TACK;
                                          NSLog(@"%@", tackInfo);
    }];
    [dataTask resume];
}

- (void) decodeJsonData:(NSData *)data {
    NSError *jsonParsingError;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
//    NSLog(@"%@", jsonParsingError);
    if (jsonParsingError) {
        [self createErrorNotification:@"Произошла ошибка при преобразовании JSON"];
    }
    else {
        NSInteger srvMessageCode = [responseData[@"srvMessageCode"] integerValue];
        if (srvMessageCode != 200) {
            [self createErrorNotification:@"Некорректный srvMessageCode"];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"%lu",(unsigned long)[responseData[@"data"] count]];
            [self createDoneRequestNotification: message withResponseData: responseData];
        }
    }
}

@end

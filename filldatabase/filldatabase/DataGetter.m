//
//  DataGetter.m
//  filldatabase
//
//  Created by Alfiya on 11.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DataGetter.h"
#import "AllDefines.h"

@implementation DataGetter

-(NSArray *) giveMeTS {
    int ts = [[NSDate date] timeIntervalSince1970];
    long msts =round((float) [[NSDate date]timeIntervalSince1970] * 1000);
    return @[@(ts), @(msts)];
}

-(NSString *) collectAuthPartWithUserID: (NSString *) userID{
    NSArray *timestamps = [self giveMeTS];
    NSString *authPart = [NSString stringWithFormat:@"u:%@_s:%@_d:4ad674c0-b0be-48ff-b7eb-0f788ceda519_r:8ef0e934-cda9-4a7c-9b41-77b3958c2910_t:%@", userID, TESTER_SIGNATURE, timestamps[0]];
    return authPart;
}

-(NSString *) collectCmdPartForListWithCount:(NSInteger)count lastTimeStamp:(NSInteger)timestamp{
    NSString *cmdPart = [NSString stringWithFormat:@"list:note,modify,%ld,0,%ld", (long)timestamp, (long) count];
    return cmdPart;
}

-(NSString *) collectTailPart {
    NSArray *timestamps = [self giveMeTS];
    NSString *tailPart = [NSString stringWithFormat:@"?_%@", timestamps[1]];
    return tailPart;
}

-(NSString *) collectUrlForListWithUserID:(NSString *)userID
                            lastTimeStamp:(NSInteger)timestamp
                               notesCount:(NSInteger)noteCount{
    NSString *authPart = [self collectAuthPartWithUserID:userID];
    NSString *cmdPart = [self collectCmdPartForListWithCount:noteCount lastTimeStamp: timestamp];
    NSString *tailPart = [self collectTailPart];
    NSString *url = [NSString stringWithFormat:@"http://%@/api/v2/%@/%@/%@", API_NODE, authPart, cmdPart, tailPart];
    return url;
}

-(void) runRequestWithUrl: (NSString *) url {
    NSURLSession *session = [NSURLSession sharedSession];
    self.requestGroup = dispatch_group_create();
    dispatch_group_enter(self.requestGroup);
    NSLog(@"URL:%@", url);
    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithURL:[NSURL URLWithString:url]
                                      completionHandler:^(
                                                          NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error) {
                                          if (!error) {
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                              self.statusCode = [httpResponse statusCode];
                                              if(self.statusCode == 200) {
                                                  NSLog(@"It's OK!!!");
                                                  [self encodeJsonData:data];
                                              }
                                          }
                                          else {
                                              self.requestError = error;
                                          }
                                          dispatch_group_leave(self.requestGroup);
    }];
    [dataTask resume];
}

-(void) encodeJsonData:(NSData *)data {
    NSError *jsonParsingError;
    self.responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
    if (jsonParsingError) {
        self.jsonParsingError = jsonParsingError;
    }
    else {
        self.srvMessageCode = [self.responseData[@"srvMessageCode"] integerValue];
        self.notesCount = [self.responseData[@"data"] count];
    }
}

@end

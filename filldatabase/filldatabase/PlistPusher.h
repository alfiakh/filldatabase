//
//  PlistPusher.h
//  filldatabase
//
//  Created by Alfiya on 17.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistPusher : NSObject

- (void) sendErrorNotification:(NSString *)message;
- (void) collectPlistFileInfo;
- (void) writeToPlistFile: (NSDictionary *)notes;

@end

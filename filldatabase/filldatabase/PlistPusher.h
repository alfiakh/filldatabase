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
- (void) collectBinaryPlistFileInfo;
- (NSArray *) getSelectionInfoForNote: (NSDictionary *)note;
- (void) writeBinaryToSinglePlistFile: (NSArray *)notes;
- (void) writeArrayToSinglePlistFile: (NSArray *)notes;
- (void) writeBinaryToMultiplePlistFile: (NSArray *)notes;
- (void) writeDictionaryToMultiplePlistFile: (NSArray *)notes;

@end

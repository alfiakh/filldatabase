//
//  DataPusher.m
//  filldatabase
//
//  Created by Alfiya on 12.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import "DataPusher.h"
#import "AllDefines.h"

@implementation DataPusher

-(id)init {
    self = [super init];
    if (self) {
        self.databaseExisted = NO;
        self.noteTableCreated = NO;
        self.databaseOpened = NO;
    }
    return self;
}

-(void) createDataBase {
    NSString *databasePath = [DOCUMENTS_DIRECTORY stringByAppendingPathComponent:DATABASE_NAME];
    NSLog(@"%@", databasePath);
    if(![[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        NSLog(@"Database doesn't exist");
    }
    else {
        self.databaseExisted = YES;
    }
    self.database = [FMDatabase databaseWithPath:databasePath];
    BOOL opened = [self.database open];
    if (opened) {
        self.databaseOpened = YES;
    }
}

-(void) createNoteTable {
    if (![self.database executeUpdate:CREATE_NOTE_TABLE_QUERY]) {
        NSLog(@"Table note didn't create");
    }
    else {
        NSLog(@"Table note created");
        self.noteTableCreated = YES;
    }
}

@end

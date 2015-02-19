//
//  NotesDataStorage.h
//  filldatabase
//
//  Created by Alfiya on 19.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotesDataStorage : NSObject

- (id) initWithOrder: (NSString *) order
            withNotes: (BOOL) displayNotes
     withFutureEvents: (BOOL) displayFutureEvents
       withPastEvents: (BOOL) displayPastEvents;

@property NSString *order;
@property BOOL displayNotes;
@property BOOL displayFutureEvents;
@property BOOL displayPastEvents;

- (NSString *) buildQuery;

@end

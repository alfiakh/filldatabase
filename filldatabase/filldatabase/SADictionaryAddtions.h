//
//  NSDictionary+SAddtions.h
//  simplanum
//
//  Created by Nikolay Ilin on 13.01.14.
//  Copyright (c) 2014 simplanum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SADictionaryAddtions)

- (NSString *) stringByFormat:(NSString*) format;

- (NSDictionary* ) flat:(NSString *) rootKey;
- (NSDictionary *) renameKeysByPrefix:(NSString *) prefix;

- (NSDictionary* ) merge:(NSDictionary* ) model;

- (NSDictionary* ) diff:(NSDictionary* ) compare;

-(NSDictionary *) prepareToStore;
-(NSDictionary *) nullReplace;


-(NSString *) sqlCreateTable:(NSString*) tableName;
-(NSString *) sqlInsert:(NSString*) table With:(NSArray *) rows;

//- (NSDictionary* ) split;


- (NSString *) makeSQLupdTable:(NSString *) tblname Where:(NSString *) where;
- (NSString *) makeSQLinsTable:(NSString *) tblname;

-(NSDictionary *) split;

//+ dictionaryWithLayoutAttributes:(UICollectionViewLayoutAttributes *) la;
//- (UICollectionViewLayoutAttributes *) layoutAttributes;
//
//+ dictionaryWithCGRect:(CGRect)frame;
//-(CGRect) CGRectValue;
@end


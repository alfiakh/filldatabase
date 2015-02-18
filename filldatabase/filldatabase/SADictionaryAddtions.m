//
//  NSDictionary+SAddtions.m
//  simplanum
//
//  Created by Nikolay Ilin on 13.01.14.
//  Copyright (c) 2014 simplanum. All rights reserved.
//

#import "SADictionaryAddtions.h"

#define DICTLEVELDIVIDER @"_"

@implementation NSDictionary (SADictionaryAddtions)


-(NSString *) stringByFormat:(NSString*) format{
    
    NSMutableString * w = [NSMutableString string];
    
    for (id key in self) {
        
        id value = self[ key ];
        
        if( [value isKindOfClass: [NSDictionary class] ] )
            [w appendFormat:@"%@", [value stringByFormat: format] ];
        
        else
            [w appendFormat:format, key, value ];
        
        
        //   id val = wD[ key];
        //   пока сделаем просто - строка по ключу - то что надо
        
    }
    return [w copy];
}



- (NSDictionary* ) flat:(NSString *) rootKey{
    
    __block NSMutableDictionary * newDict;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString * keyFormat = (rootKey)?[NSString stringWithFormat:@"%@%@%%@",rootKey,DICTLEVELDIVIDER]: @"%@";
        
        
        newDict = [NSMutableDictionary dictionaryWithCapacity:self.count];
        
        for (id key in self) {
            
            id value = self[ key ];
            
            if( [value isKindOfClass: [NSArray class] ] && [value count] > 0){
                newDict[ [NSString stringWithFormat:keyFormat,key] ] = [NSString stringWithFormat:@"%@", value];
            }
            else if( [value isKindOfClass: [NSDictionary class] ] && [value count] > 0 )
                [newDict addEntriesFromDictionary: [value flat: [NSString stringWithFormat:keyFormat,[key description]] ] ];
            
            else
                newDict[ [NSString stringWithFormat:keyFormat,key] ] = [NSString stringWithFormat:@"%@", value];
            
        }
    });
    
    return  [newDict copy];
}

- (NSDictionary *) renameKeysByPrefix:(NSString *) prefix{
    
    __block NSMutableDictionary * newDict;
    //    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSString * keyFormat = (prefix)?[NSString stringWithFormat:@"%@%@%%@",prefix,DICTLEVELDIVIDER]: @"%@";
    newDict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (id key in self) {
        id value = self[ key ];
        newDict[ [NSString stringWithFormat:keyFormat,key] ] = value;
    }
    //    });
    
    return  [newDict copy];
    
}



-(NSDictionary *) prepareToStore{
    
    __block NSDictionary * m;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        m = [self nullReplace];
    });
    
    return m;
    
}

-(NSDictionary *) nullReplace{
    
    NSMutableDictionary * m;
    
    m = [NSMutableDictionary dictionary];
    
    for (id key in self ) {
        
        if( [self[ key ] isKindOfClass:[NSMutableDictionary class] ] || [self[ key ] isKindOfClass:[NSDictionary class] ] )
            m[ key ] = [self[key] nullReplace];
        
        else
            if( self [ key ] == [NSNull null])
            {
                m[ key ]=@"";
            }
            else{
                m[ key ] = self [ key ];
            }
    }
    
    return [m copy];
}


- (NSDictionary* ) merge:(NSMutableDictionary* ) model{
    
    __block NSMutableDictionary * m;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        m = [model mutableCopy];
        
        for (id key in model) {
            
            id modelValue = model[ key ];
            id selfValue  = self [ key ];
            
            
            if( ! [modelValue isKindOfClass: [NSDictionary class] ] && ![modelValue isKindOfClass: [NSMutableDictionary class] ] && selfValue  )
                
                m[ key ] = (selfValue != [NSNull null])?selfValue:@"";
            
            
            else
                if( selfValue && ([selfValue isKindOfClass: [NSDictionary class] ] || [selfValue isKindOfClass: [NSMutableDictionary class] ]) )
                {
                    if([modelValue count]>0 )
                        m[ key ] = [selfValue merge:modelValue];
                    else
                        m[ key ] = [selfValue nullReplace];
                }
        }
        
    });
    
    return  [m copy];
}





- (NSDictionary* ) diff:(NSDictionary* ) compare{
    
    __block NSMutableDictionary * diff = [NSMutableDictionary dictionary];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        
        // wats dif in new and null
        for (id key in self) {
            
            id compValue = compare[ key ];
            id selfValue  = self [ key ];
            
            
            if( !compValue )
                diff[ key ] = @{ @"from":selfValue, @"to":@"NULL"};
            
            else{
                
                if(
                   ([selfValue isKindOfClass:[NSDictionary class]] ||
                    [selfValue isKindOfClass:[NSMutableDictionary class]] ) &&
                   (
                    [compValue isKindOfClass:[NSDictionary class]] ||
                    [compValue isKindOfClass:[NSMutableDictionary class]]
                    )
                   )
                    
                {
                    // both values is Arrays
                    
                    NSDictionary * diffDict = [(NSDictionary *)selfValue diff:(NSDictionary*) compValue];
                    
                    if(diffDict && diffDict.count>0)
                        diff[ key ] = diffDict;
                    
                }
                
                
                else
                    if( ![selfValue isEqual: compValue] )
                        diff[ key ] = @{ @"from":selfValue, @"to":compValue};
                
            }
        }
        
        
        
        
        for (id key in compare) {
            
            id compValue = compare[ key ];
            id selfValue  = self [ key ];
            
            
            if( !selfValue )
                diff[ key ] = @{ @"from":@"NULL", @"to":compValue};
            
        }
        
        
        
        
        
        
    });
    
    return  [diff copy];
    
    
}






-(NSString *) sqlCreateTable:(NSString*) tableName{
    
    NSDictionary * aggD = [self flat:nil];
    
    NSMutableString * sql = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (\n",tableName];
    
    for (id key in aggD) {
        
        id value = aggD[ key ];
        
        
        if([value isKindOfClass:[NSString class]] && [value isEqualToString:@"PK"])
            [sql appendFormat:@" %@ uniqueidentifier PRIMARY KEY NOT NULL,\n", key ];
        
        else
            if([value isKindOfClass:[NSNumber class]])
                [sql appendFormat:@" %@ NUMERIC DEFAULT %@,\n", key, value ];
        
            else
                [sql appendFormat:@" %@ TEXT DEFAULT '%@',\n", key, value ];
        
        
    }
    
    [sql deleteCharactersInRange:NSMakeRange( sql.length-2 , 1)];
    [sql appendString:@");"];
    
    return sql;
    
}


-(NSString *) sqlInsert:(NSString*) table With:(NSArray *) rows;
{
    
    __block NSMutableString *  sql = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ \n(", table];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary * sqlD =[self flat:nil];
        
        NSArray * fields = [sqlD allKeys];
        
        
        for (NSString * key in fields)
            [sql appendFormat:@" %@,",key];
        
        [sql deleteCharactersInRange:NSMakeRange( sql.length-1, 1)];
        
        [sql appendFormat:@" )\n\nVALUES "];
        
        for ( NSDictionary * rowD in rows)
        {
            NSDictionary * row = [rowD flat:nil];
            [sql appendFormat:@"\n("];
            
            for (NSString * key in fields)
            {
                id value = row[ key ];
                
                if(value == nil)
                {
                    [sql appendFormat:@"0,"];
                }
                else
                    if([value isKindOfClass:[NSNumber class]])
                        [sql appendFormat:@"%@,",value];
                
                    else
                        if([value isKindOfClass:[NSDictionary class]])
                            [sql appendFormat:@"'%@',",[value description]];
                
                        else
                            [sql appendFormat:@" '%@',",[value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
            }
            [sql deleteCharactersInRange:NSMakeRange( sql.length-1, 1)];
            [sql appendFormat:@"),"];
        }
        
        
        [sql deleteCharactersInRange:NSMakeRange( sql.length-1, 1)];
        [sql appendFormat:@";"];
    });
    
    rows = nil;
    return sql;
}






- (NSString *) makeSQLupdTable:(NSString *) tblname Where:(NSString *) where{
    
    NSDateFormatter * sqlDF = [[NSDateFormatter alloc] init];
    [sqlDF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [sqlDF setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    
    NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET ", tblname];
    
    for (NSString * key in self) {
        
        id value = [self objectForKey:key];
        
        if([value isKindOfClass:[NSNumber class]])
        {
            
            sql = [sql stringByAppendingFormat:@"\n  %@ = %@,",key, value];
            
        }
        else if([value isKindOfClass:[NSString class]])
        {
            sql = [sql stringByAppendingFormat:@"\n  %@ = '%@',",key, [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            
        }
        else if([value isKindOfClass:[NSDate class]])
        {
            
            
            sql = [sql stringByAppendingFormat:@"\n  %@ = '%@',",key, [sqlDF stringFromDate:value]];
        }
    }
    
    sql = [sql stringByAppendingString:@"#!#"];
    sql = [sql stringByReplacingOccurrencesOfString:@",#!#" withString:@"\n  WHERE "];
    sql = [sql stringByAppendingFormat:@" %@ ;",where];
    
    return sql;
}


- (NSString *) makeSQLinsTable:(NSString *) tblname{
    
    //    NSDateFormatter * sqlDF = [[NSDateFormatter alloc] init];
    //    [sqlDF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //     [sqlDF setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString * sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ", tblname];
    
    NSArray * keys = [self allKeys];
    NSArray * vals = [self allValues];
    
    NSMutableString * keySQL = [@"( " mutableCopy];
    NSMutableString * valSQL = [@"\nVALUES ( " mutableCopy];
    
    
    for (int i=0; i<keys.count; i++) {
        
        [keySQL appendFormat:@" %@,",[keys objectAtIndex:i]];
        
        
        id value = [vals objectAtIndex:i];
        
        if([value isKindOfClass:[NSNumber class]])
        {
            
            [valSQL  appendFormat:@" %@,", value];
            
        }
        else if([value isKindOfClass:[NSString class]])
        {
            [valSQL appendFormat:@" '%@',",[value stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            
        }
        else if([value isKindOfClass:[NSArray class]]) {
            [valSQL appendFormat:@" '%@',", value];
        }
        else {
            NSLog(@"UNDEFINED TYPE: %@", NSStringFromClass([value class]));
        }
        //        else if([value isKindOfClass:[NSDate class]])
        //        {
        //
        //            [valSQL appendFormat:@" '%@',",[sqlDF stringFromDate:value]];
        //        }
        //
        
        
    }
    
    NSRange keyR;
    keyR.location=keySQL.length -1;
    keyR.length = 1;
    
    [keySQL deleteCharactersInRange:keyR];
    [keySQL appendString:@" )\n"];
    
    keyR.location=valSQL.length -1;
    
    [valSQL deleteCharactersInRange:keyR];
    [valSQL appendString:@" );"];
    
    sql = [sql stringByAppendingString:keySQL];
    sql = [sql stringByAppendingString:valSQL];
    
    return sql;
    
}





/**
 * Из Dictionary вида @[key1_key2_...: value1} делает @{key1:@{key2:...:value}}
 * @param keysArray массив ключей
 * @param object конечное значение поля
 * @return Полученный Dictionary
 */
-(NSDictionary *) makeLevel: (NSArray *) keysArray withObject:(NSObject *) object{
    if(keysArray.count==1){
        return @{keysArray[0]:object};
    }else{
        NSMutableArray * array=[keysArray mutableCopy];
        [array removeObjectAtIndex:0];
        return @{keysArray[0]:[self makeLevel:array withObject:object]};
    }
}
/**
 * Рекурсивно добавляет поля одного dictionary в другое dictionary, то есть
 * @{key1:
 @{key2:
 @{key3: value1}}} +
 + @{key1:
 @{key2:
 @{key3.1: value2}}} =
 = @{key1:
 @{key2:
 @{key3: value1,
 key3.1: value2}}}
 @param toDict исходный Dictionary
 @param fromDict dictionary откуда надо добавить поля
 @return Объединенный Dictionary
 
 */
-(NSDictionary *) recursiveAddEntriesTo:(NSMutableDictionary *) toDict from:(NSDictionary *) fromDict{
    NSMutableDictionary * dict=[toDict mutableCopy];
    for (NSString * key in fromDict.allKeys) {
        if(dict[key]){
            if([fromDict[key] isKindOfClass:[NSDictionary class]]){
                dict[key]=[self recursiveAddEntriesTo:dict[key] from:fromDict[key]];
            }
        }else{
            [dict addEntriesFromDictionary:fromDict];
        }
    }
    return dict;
}
/**
 * Из Dictionary вида @[key1_key2_...: value1} делает @{key1:@{key2:...:value}}
 */
-(NSDictionary *) split{
    NSMutableDictionary * result=[NSMutableDictionary new];
    for (NSString * key in self.allKeys) {
        NSArray * keysArray=[key componentsSeparatedByString:@"_"];
        if (keysArray.count==1) {
            result[key]=self[key];
        } else {
            NSDictionary * temp=[self makeLevel:keysArray withObject:self[key]];
            result=[[self recursiveAddEntriesTo:result from:temp] mutableCopy];
        }
    }
    return result;
}




//+ dictionaryWithLayoutAttributes:(UICollectionViewLayoutAttributes *) la{
//    return @{@"x": @(la.frame.origin.x),
//             @"y": @(la.frame.origin.y),
//             @"width": @(la.frame.size.width),
//             @"height": @(la.frame.size.height),
//             @"zIndex":@(la.zIndex),
//             @"alpha":@(la.alpha),
//             };
//}
//
//
//
//- (UICollectionViewLayoutAttributes *) layoutAttributes{
//    
//    UICollectionViewLayoutAttributes * la = [[UICollectionViewLayoutAttributes alloc] init];
//    la.frame = CGRectMake([self[@"x"] floatValue], [self[@"y"] floatValue],[self[@"width"] floatValue],[self[@"height"] floatValue]);
//    la.zIndex =[self[@"zIndex"] integerValue];
//    la.alpha =[self[@"alpha"] floatValue];
//    return la;
//}
//
//+ dictionaryWithCGRect:(CGRect)frame
//{
//    return @{@"x": @(frame.origin.x),
//             @"y": @(frame.origin.y),
//             @"width": @(frame.size.width),
//             @"height": @(frame.size.height)
//             };
//}
//-(CGRect) CGRectValue
//{
//    return CGRectMake([self[@"x"] floatValue], [self[@"y"] floatValue],[self[@"width"] floatValue],[self[@"height"] floatValue]);
//}



@end
//
//  AllDefines.h
//  FillDatabase
//
//  Created by Alfiya on 10.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#define DOCUMENTS_DIRECTORY NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define DATABASE_NAME @"notes.sqlite"
#define PLIST_NAME @"notes.plist"
#define PLIST_BINARY_NAME @"notesBinary.plist"
#define HELPER_PLIST @"selectionHelper.plist"
#define HELPER_BINARY_PLIST @"selectionBinaryHelper.plist"
#define NOTES_COUNT @500
#define USER_ID @"15ff1ce5-d2f7-4bf9-828a-dc3f3913655e"
//#define USER_ID @"5cbce5fc-6c4a-4ad6-bb6f-c294eb2e91f6"
#define TESTER_SIGNATURE @"050703fb81f5f43a8d77c63fe261d804"
#define API_NODE @"api-test.bossnote.ru"
#define CREATE_NOTE_TABLE_QUERY @"CREATE TABLE IF NOT EXISTS note (_id INTEGER PRIMARY KEY AUTOINCREMENT, ID TEXT UNIQUE NOT NULL, type TEXT, ownerID TEXT, status INTEGER, shared INTEGER, smart_enabled INTEGER, history TEXT, relations TEXT, message TEXT, complete TEXT, event_enable TEXT, event_start_TS INTEGER, event_end_TS INTEGER, event_tz_name TEXT, event_alarms TEXT, event_repeat_type INTEGER, event_repeat_expDay INTEGER, event_repeat_rules TEXT, event_repeat_exceptions TEXT, event_geo_lat TEXT, event_geo_lng TEXT, event_geo_acc TEXT, event_geo_inf TEXT, event_geo_TS TEXT, event_geo_inf_address TEXT, event_geo_inf_country TEXT, event_geo_inf_administrative_area_level_1 TEXT, event_geo_inf_locality TEXT, event_geo_inf_route TEXT, event_geo_inf_street_number TEXT, event_geo_inf_postal_code TEXT, pwd TEXT, smart TEXT, attachments TEXT, create_TS INTEGER, create_srvTS INTEGER, create_devID TEXT, create_geo_inf TEXT, create_geo_TS TEXT, create_geo_lat TEXT, create_geo_lng TEXT, create_geo_acc TEXT, create_geo_inf_address TEXT, create_geo_inf_street_number TEXT, create_geo_inf_administrative_area_level_1 TEXT, create_geo_inf_country TEXT, create_geo_inf_locality TEXT, create_geo_inf_postal_code TEXT, create_geo_inf_route TEXT, modify_TS INTEGER, modify_srvTS INTEGER, modify_devID TEXT, modify_geo_inf TEXT, modify_geo_TS TEXT, modify_geo_lat TEXT, modify_geo_lng TEXT, modify_geo_acc TEXT, modify_geo_inf_address TEXT, modify_geo_inf_country TEXT, modify_geo_inf_administrative_area_level_1 TEXT, modify_geo_inf_locality TEXT, modify_geo_inf_route TEXT, modify_geo_inf_street_number TEXT, modify_geo_inf_postal_code TEXT, strucVer INTEGER, is_cached INTEGER, is_draft INTEGER, sync INTEGER, cmdTS TEXT, meta TEXT);"
#define DELETE_NOTES_QUERY @"DELETE FROM note"
#define TICK NSDate * DATE_NOW = [NSDate date]
#define TACK NSDictionary * tackInfo = @{@"msg":[NSString stringWithFormat:@"%@: %f",[[NSString alloc] initWithUTF8String:__PRETTY_FUNCTION__ ], -[DATE_NOW timeIntervalSinceNow]], @"time":@(-[DATE_NOW timeIntervalSinceNow])};

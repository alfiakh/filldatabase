//
//  AllDefines.h
//  FillDatabase
//
//  Created by Alfiya on 10.02.15.
//  Copyright (c) 2015 Alfiya Khairetdinova. All rights reserved.
//

#define DOCUMENTS_DIRECTORY NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define DATABASE_NAME @"notes.sqlite"
#define NOTES_COUNT @500
#define USER_ID @"15ff1ce5-d2f7-4bf9-828a-dc3f3913655e"
#define TESTER_SIGNATURE @"050703fb81f5f43a8d77c63fe261d804"
#define API_NODE @"api-test.bossnote.ru"
#define CREATE_NOTE_TABLE_QUERY @"CREATE TABLE IF not exists note (_id INTEGER PRIMARY KEY AUTOINCREMENT, ID TEXT UNIQUE NOT NULL, type TEXT, ownerID TEXT, status INTEGER, shared INTEGER, history TEXT, relations TEXT, message TEXT, complete TEXT, event_enable TEXT, event_start_TS TEXT, event_end_TS TEXT, event_tz_name TEXT, event_alarms TEXT, event_repeat_type INTEGER, event_repeat_expDay INTEGER, event_repeat_rules TEXT, event_repeat_exceptions TEXT, event_geo_lat TEXT, event_geo_lng TEXT, event_geo_acc TEXT, event_geo_inf TEXT, pwd TEXT, smart TEXT, attachments TEXT, create_TS INTEGER, create_srvTS INTEGER, create_devID TEXT, create_geo_lat TEXT, create_geo_lng TEXT, create_geo_acc TEXT, create_geo_inf TEXT, modify_TS INTEGER, modify_srvTS INTEGER, modify_devID TEXT, modify_geo_lat TEXT, modify_geo_lng TEXT, modify_geo_acc TEXT, modify_geo_inf TEXT, strucVer INTEGER, is_cached INTEGER, is_draft INTEGER, sync INTEGER, cmdTS TEXT, meta TEXT);"
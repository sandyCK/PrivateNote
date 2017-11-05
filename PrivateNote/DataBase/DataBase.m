//
//  DataBase.m
//  PrivateNoteBook
//
//  Created by sandy on 2017/8/22.
//  Copyright © 2017年 concox. All rights reserved.
//

#import "DataBase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

static NSString *const DatabaseName = @"PrivateNoteBook.db";
static NSString *const TableName = @"PrivateMessage";
static NSString *const PropertyIndex = @"PrimaryKeyIndex";
static NSString *const PropertyName = @"Name";
static NSString *const PropertyContent = @"Content";

@implementation DataBase
{
    FMDatabaseQueue *_dbQueue;
}

static DataBase *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

+ (instancetype)sharedDataBase
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[super alloc]init];
        }
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:DatabaseName];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        
        [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            if ([db open]) {
                BOOL res = [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, %@ TEXT, %@ TEXT)", TableName, PropertyIndex, PropertyName, PropertyContent]];
                if (!res) {
                    NSLog(@"Create database failed!!!");
                } else
                    NSLog(@"Create database success.");
            }
            [db close];
        }];
    }
    return self;
}

- (BOOL)insertData:(DataModel *)data
{
    __block BOOL res = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TableName]];
            [rs next];
            
            res = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO PrivateMessage(%@, %@) VALUES(?, ?)", PropertyName, PropertyContent], data.name, data.content];
        }
        [db close];
    }];
    return res;
}

- (BOOL)deleteData:(int)primaryKey
{
    __block BOOL res = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            res = [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM PrivateMessage WHERE %@='%d'", PropertyIndex, primaryKey]];
        }
        [db close];
    }];
    return res;
}

- (BOOL)modifyData:(DataModel *_Nonnull)data
{
    __block BOOL res = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            res = [db executeUpdate:[NSString stringWithFormat:@"UPDATE PrivateMessage SET %@='%@' , %@='%@' WHERE %@='%d'", PropertyName, data.name, PropertyContent, data.content, PropertyIndex, data.index]];
        }
        [db close];
    }];
    return res;
}

- (nonnull NSArray<DataModel *> *)getAllData
{
    NSMutableArray *tmp = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TableName]];
            while ([rs next]) {
                DataModel *data = [[DataModel alloc]init];
                data.index = [rs intForColumn:PropertyIndex];
                data.name = [rs stringForColumn:PropertyName];
                data.content = [rs stringForColumn:PropertyContent];
                [tmp addObject:data];
            }
        }
        [db close];
    }];
    return tmp;
}

@end

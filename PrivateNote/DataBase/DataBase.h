//
//  DataBase.h
//  PrivateNoteBook
//
//  Created by sandy on 2017/8/22.
//  Copyright © 2017年 concox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject

+ (instancetype _Nonnull )sharedDataBase;

/**
 * 插入数据
 */
- (BOOL)insertData:(DataModel *_Nonnull)data;

/**
 * 删除数据
 */
- (BOOL)deleteData:(int)primaryKey;

/**
 * 修改数据
 */
- (BOOL)modifyData:(DataModel *_Nonnull)data;

/**
 * 获取表中所有数据
 */
- (nonnull NSArray<DataModel *> *)getAllData;

@end

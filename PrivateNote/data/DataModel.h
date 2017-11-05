//
//  DataModel.h
//  PrivateNoteBook
//
//  Created by sandy on 2017/8/19.
//  Copyright © 2017年 concox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, assign)int index;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *content;

@end

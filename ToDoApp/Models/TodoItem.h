//
//  TodoItem.h
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoItem : NSObject
@property NSString *key;
@property NSString *text;
@property NSDate *createdAt;

- (instancetype) initWithText: (NSString *)text createdAt: (NSDate *) date;
- (instancetype) initWithKey: (NSString *)text key: (NSString *) key;
- (instancetype) initWithText: (NSString *)text;
- (NSString *) asDict;

@end


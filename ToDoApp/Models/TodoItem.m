//
//  TodoItem.m
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import "TodoItem.h"

@implementation TodoItem
- (instancetype) initWithText: (NSString *)text {
    if (self = [super init])
    {
        self.text = text;
        self.createdAt = [[NSDate alloc]init];
    }
    return self;
}

- (instancetype) initWithText: (NSString *)text createdAt: (NSDate *) date{
    if (self = [super init])
    {
        self.text = text;
        self.createdAt = date;
    }
    return self;
}

- (NSString *)dateAsString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:self.createdAt];
}

- (NSDictionary *) asDict {
    //this should be done using a lib for JSON serialization
    return @{@"text": self.text, @"created_at": [NSNumber numberWithDouble:[self.createdAt timeIntervalSince1970]]};
//    return [NSString stringWithFormat:@"{\"text\":\"%@\", \"complete\":\"%d\"}", self.text, self.isComplete];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"TODO: Text=%@", self.text];
}
@end

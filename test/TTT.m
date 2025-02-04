//
//  TTT.m
//  test
//
//  Created by jia yu on 2024/11/9.
//

#import "TTT.h"

@implementation TTT
@synthesize str;

+ (BOOL)supportsSecureCoding {
    return TRUE;
}


#pragma mark - NSSecureCoding
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:str forKey:@"Name"];
    return;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder { 
    self = [super init];
    if (self){
        str = [coder decodePropertyListForKey:@"Name"];
    }
    return self;
}

@end

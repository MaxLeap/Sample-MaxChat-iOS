//
//  MaxSocialRemoteShuoShuo.m
//  MaxChat
//
//  Created by 周和生 on 16/5/11.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "MaxSocialRemoteShuoShuo.h"

@implementation MaxSocialRemoteShuoShuo

- (id)initWithMaxSocialShuoShuo:(MaxSocialShuoShuo *)shuoshuo {
    if (self = [super init]) {
        self.objectId = shuoshuo.objectId;
        self.createdAt = shuoshuo.createdAt;
        self.updatedAt = shuoshuo.updatedAt;
        self.userId = shuoshuo.userId;
        self.location = shuoshuo.location;
        self.content = shuoshuo.content;
    }
    
    return self;
}

@end

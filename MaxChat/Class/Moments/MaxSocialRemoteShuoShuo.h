//
//  MaxSocialRemoteShuoShuo.h
//  MaxChat
//
//  Created by 周和生 on 16/5/11.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

@import MaxSocial;

@interface MaxSocialRemoteShuoShuo : MaxSocialShuoShuo

@property (nonatomic, strong) NSMutableArray<MaxSocialComment *> *zans, *comments;
- (id)initWithMaxSocialShuoShuo:(MaxSocialShuoShuo *)shuoshuo;

@end

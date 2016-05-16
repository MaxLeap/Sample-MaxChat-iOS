//
//  MLStatusQuery.h
//  MaxIMLib
//
//  Created by Sun Jin on 3/28/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MLStatusQuerySortByUserId = 0,
    MLStatusQuerySortByCreatedTime = 1
} MLStatusQuerySort;

NS_ASSUME_NONNULL_BEGIN

@interface MaxSocialQuery : NSObject

@property (nonatomic) int page;
@property (nonatomic) int limit;

@property (nonatomic) MLStatusQuerySort sort; // default is 1
@property (nonatomic) BOOL ascending; // default is NO

@end

NS_ASSUME_NONNULL_END

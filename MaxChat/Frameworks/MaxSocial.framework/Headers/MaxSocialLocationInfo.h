//
//  MaxSocialLocationInfo.h
//  MaxSocial
//
//  Created by Sun Jin on 3/28/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaxSocialLocation.h"

@interface MaxSocialLocationInfo : NSObject

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) MaxSocialLocation *location;

+ (instancetype)infoFromDictionary:(NSDictionary *)dict;

@end

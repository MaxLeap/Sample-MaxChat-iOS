//
//  MaxSocialLocation.h
//  MaxSocial
//
//  Created by Sun Jin on 3/28/16.
//  Copyright © 2016 maxleap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaxSocialLocation : NSObject

@property (nonatomic) double latitude; // [-90, 90]
@property (nonatomic) double longitude; // [-180, 180]

+ (instancetype)locationWithLatitude:(double)latitude longitude:(double)longitude;

@end

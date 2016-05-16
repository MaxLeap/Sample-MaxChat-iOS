//
//  MLFFUserIconCell.m
//  MaxLeapFood
//
//  Created by julie on 15/11/6.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MCUserIconCell.h"

@interface MCUserIconCell ()

@end

@implementation MCUserIconCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview: self.iconImageView];
        
        self.iconImageView.layer.cornerRadius = 2;
        self.iconImageView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImageView.frame = CGRectMake(self.contentView.frame.size.width - self.contentView.frame.size.height,
                                          5,
                                          self.contentView.frame.size.height-10,
                                          self.contentView.frame.size.height-10);
    
}


@end

//
//  MLAMTextViewInternal.h
//  MLAppMaker
//
//  Created by Miracle on 3/30/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCTextViewInternal : UITextView


@property (nonatomic, weak) UIResponder *overrideNextResponder;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic) BOOL displayPlaceHolder;

@end
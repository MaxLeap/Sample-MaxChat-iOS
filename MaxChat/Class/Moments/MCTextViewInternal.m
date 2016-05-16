//
//  MLAMTextViewInternal.m
//  MLAppMaker
//
//  Created by Miracle on 3/30/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import "MCTextViewInternal.h"

@implementation MCTextViewInternal

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
    if(self.tracking || self.decelerating){
        //initiated by user...
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
    } else {
        
        float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
        if(s.y < bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;
        }
    }
    
    // Fix "overscrolling" bug
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
    [super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
    UIEdgeInsets insets = s;
    
    if(s.bottom>8) insets.bottom = 0;
    insets.top = 0;
    
    [super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    // is this an iOS5 bug? Need testing!
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor)
    {
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = self.textAlignment;
            [self.placeholder drawInRect:CGRectMake(5, 8 + self.contentInset.top, self.frame.size.width-self.contentInset.left, self.frame.size.height- self.contentInset.top) withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
        }
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    [self setNeedsDisplay];
}

- (UIResponder *)nextResponder {
    if (_overrideNextResponder != nil)
        return _overrideNextResponder;
    else
        return [super nextResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_overrideNextResponder != nil)
        return NO;
    else
        return [super canPerformAction:action withSender:sender];
}
@end
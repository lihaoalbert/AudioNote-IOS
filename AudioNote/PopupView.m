//
//  PopupView.m
//  MSCDemo
//
//  Created by iflytek on 13-6-7.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//


#import "PopupView.h"
#import <QuartzCore/QuartzCore.h>
#ifdef __IPHONE_6_0
# define ALIGN_CENTER NSTextAlignmentCenter
#else
# define ALIGN_CENTER UITextAlignmentCenter
#endif
@implementation PopupView {
    
}
@synthesize ParentView = _parentView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.75f];
        self.layer.cornerRadius = 5.0f;
        lVolice = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _parentView.frame.size.width, 10)];
        lVolice.numberOfLines = 0;
        lVolice.font = [UIFont systemFontOfSize:17];
        lVolice.textColor = [UIColor whiteColor];
        lVolice.backgroundColor = [UIColor clearColor];
        lVolice.textAlignment = ALIGN_CENTER;
        [self addSubview:lVolice];
        lText = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, _parentView.frame.size.width, 200)];
        lText.numberOfLines = 0;
        lText.font = [UIFont systemFontOfSize:15];
        lText.textColor = [UIColor whiteColor];
        lText.backgroundColor = [UIColor clearColor];
        lText.textAlignment = ALIGN_CENTER;
        [self addSubview:lText];
        _queueCount = 0;
    }
    return self;
}

- (void) setVolume:(NSString *) volume Text:(NSString *) text {
    _queueCount ++;
    self.alpha = 1.0f;
    lVolice.frame = CGRectMake(0, 10, _parentView.frame.size.width, 10);
    lVolice.text = volume;
    [lVolice sizeToFit];
 
    lText.frame = CGRectMake(0, 30, _parentView.frame.size.width, 200);
    lText.text = text;
    [lText sizeToFit];

    //NSLog(@"lText - width: %f, height: %f", lText.frame.size.width, lText.frame.size.height);
    //NSLog(@"x:%f, y:%f, width:%f, height:%f",(_parentView.frame.size.width - lText.frame.size.width)/2, self.frame.origin.y, lVolice.frame.size.width+10, lVolice.frame.size.height+lText.frame.size.height+20);
    
    CGRect  fMain =  CGRectMake(_parentView.frame.size.width/4, _parentView.frame.size.height/2, _parentView.frame.size.width/2, _parentView.frame.size.height/4);
    self.frame = fMain;
    [UIView animateWithDuration:3.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if (_queueCount == 1) {
                             [self removeFromSuperview];
                         }
                         _queueCount--;
                         
                     }
     ];
    
}


@end


//
//  iFlyPopupView.m
//  AudioNote
//
//  Created by lijunjie on 15-1-8.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "IFlyPopupView.h"

@implementation FlyPopupView

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        //you init
    }
    return self;
}

+(FlyPopupView *)instanceTextView {
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"IFlyPopupView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

@end

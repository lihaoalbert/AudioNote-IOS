//
//  iFlyPopupView.h
//  AudioNote
//
//  Created by lijunjie on 15-1-8.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_iFlyPopupView_h
#define AudioNote_iFlyPopupView_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface FlyPopupView : UIView

@property (weak, nonatomic) IBOutlet UILabel *volume;

+(FlyPopupView *)instanceTextView;

@end

#endif

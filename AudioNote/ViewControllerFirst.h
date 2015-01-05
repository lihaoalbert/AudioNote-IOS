//
//  ViewControllerFirst.h
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// ifly frameworks
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySetting.h"

@interface ViewControllerFirst : UIViewController

- (IBAction)startUpVoice:(id)sender;

@end


//
//  ViewControllerFirst.h
//  AudioNote
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


//https://github.com/tonymillion/Reachability
#import "Reachability.h"

#import "DidShowCurrent.h"

// ifly frameworks
/* without ui
无UI语音识别demo
使用该功能仅仅需要四步
1.创建识别对象；
2.设置识别参数；
3.有选择的实现识别回调；
4.启动识别
*/

/* with ui
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"
*/
#import "iflyMSC/IFlySetting.h"

@interface ViewControllerFirst : UIViewController<DidShowCurrent>

@end


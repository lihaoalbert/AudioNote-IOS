//
//  ViewUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ViewUtils.h"
#define RMB_WAN 10000
#define TIME_HOUR 60

@implementation ViewUtils

+ (void) simpleAlertView: delegate Title: (NSString*) title Message: (NSString*) message ButtonTitle: (NSString*) buttonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:buttonTitle otherButtonTitles:nil];
    [alert show];
}

+ (UIView *)loadNibClass:(Class)cls {
    UINib *nib=[UINib nibWithNibName:NSStringFromClass(cls) bundle:nil];
    NSArray *views=[nib instantiateWithOwner:nil options:nil];
    return [views firstObject];
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  弹出框架显示临时性文字
 *
 *  @param view controller.view
 *  @param text 提示文字
 */
+ (void)showPopupView:(UIView *)view Info:(NSString*)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode                      = MBProgressHUDModeText;
    hud.labelText                 = text;
    hud.margin                    = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}

+ (void)showPopupView:(UIView *)view Info:(NSString*)text while:(void(^)(void))executeBlock {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode                      = MBProgressHUDModeText;
    hud.labelText                 = text;
    hud.margin                    = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    executeBlock();
    
    [hud hide:YES];
}

/**
 *  tableViewCell根据内容自定义高度
 *
 *  @param text     cell显示内容
 *  @param width    cell的宽度，以此自适应高度
 *  @param fontSize 内容字段大小
 *
 *  @return CGSize
 */
+ (CGSize) sizeForTableViewCell:(NSString *)text
                          Width:(NSInteger)width
                       FontSize:(NSInteger)fontSize {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50000)];
    textLabel.text=text;
    textLabel.numberOfLines=0;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:fontSize];
    [textLabel sizeToFit];
    CGRect rect = textLabel.frame;;
    return rect.size;
}

+ (void)myCellTime:(MyTableViewCell *)myCell {
    CGFloat width = myCell.frame.size.width;
    CGFloat move  = width*3/8;
    CGRect rect1  = myCell.cellDivider.frame;
    CGRect rect2  = myCell.cellTime.frame;
    CGRect rect3  = myCell.cellTagRight.frame;
    CGRect rect4  = myCell.cellTimeUnit.frame;
    CGRect rect5  = myCell.cellTimeDesc.frame;
    NSString *state = @"no";
    if([[NSNumber numberWithFloat:myCell.cellTime.tag] isEqualToNumber: [NSNumber numberWithInt:1]]) {
        state = @"moved";
    }
    
    if([state isEqualToString:@"no"]) {
        rect1.origin.x = rect1.origin.x-move;
        rect2.origin.x = rect2.origin.x-move;
        rect3.origin.x = rect3.origin.x-move;
        rect4.origin.x = rect4.origin.x-move;
        rect5.origin.x = rect5.origin.x-move;
        rect5.size.width = width*7/8;
        myCell.cellTime.tag = 1;
    }
    else {
        rect1.origin.x = rect1.origin.x+move;
        rect2.origin.x = rect2.origin.x+move;
        rect3.origin.x = rect3.origin.x+move;
        rect4.origin.x = rect4.origin.x+move;
        rect5.origin.x = rect5.origin.x+move;
        rect5.size.width = width*3/8;
        myCell.cellTime.tag = 0;
    }
    // myCell.cellTimeDesc.backgroundColor = [UIColor orangeColor];
    
    myCell.cellDivider.frame  = rect1;
    myCell.cellTime.frame     = rect2;
    myCell.cellTagRight.frame = rect3;
    myCell.cellTimeUnit.frame = rect4;
    myCell.cellTimeDesc.frame = rect5;
}

+ (void)myCellMoney:(MyTableViewCell *)myCell {
    CGFloat width = myCell.frame.size.width;
    CGFloat move  = width*3/8;
    CGRect rect1  = myCell.cellDivider.frame;
    CGRect rect2  = myCell.cellMoney.frame;
    CGRect rect3  = myCell.cellTagLeft.frame;
    CGRect rect4  = myCell.cellMoneyUnit.frame;
    CGRect rect5  = myCell.cellMoneyDesc.frame;
    NSString *state = @"no";
    if([[NSNumber numberWithFloat:myCell.cellMoney.tag] isEqualToNumber: [NSNumber numberWithInt:1]]) {
        state = @"moved";
    }
    
    
    if([state isEqualToString:@"no"]) {
        rect1.origin.x = rect1.origin.x+move;
        rect2.origin.x = rect2.origin.x+move;
        rect3.origin.x = rect3.origin.x+move;
        rect4.origin.x = rect4.origin.x+move;
        //rect5.origin.x = rect5.origin.x+move;
        rect5.size.width = width*7/8;
        
        myCell.cellMoneyDesc.textAlignment = NSTextAlignmentLeft;
        myCell.cellMoney.tag = 1;
    }
    else {
        rect1.origin.x = rect1.origin.x-move;
        rect2.origin.x = rect2.origin.x-move;
        rect3.origin.x = rect3.origin.x-move;
        rect4.origin.x = rect4.origin.x-move;
        //rect5.origin.x = rect5.origin.x-move;
        rect5.size.width = width*3/8;
        
        myCell.cellMoneyDesc.textAlignment = NSTextAlignmentRight;
        myCell.cellMoney.tag = 0;
    }
    // myCell.cellMoneyDesc.backgroundColor = [UIColor orangeColor];
    
    myCell.cellDivider.frame  = rect1;
    myCell.cellMoney.frame    = rect2;
    myCell.cellTagLeft.frame  = rect3;
    myCell.cellMoneyUnit.frame = rect4;
    myCell.cellMoneyDesc.frame = rect5;
}

// 100000 元 => 10 万元
+ (NSDictionary *)dealWithMoney:(NSString *)nMoney {
    NSString *unit = @"元";
    NSInteger iMoney = [nMoney intValue];
    
    if (iMoney > RMB_WAN) {
        nMoney = [NSString stringWithFormat:@"%.1f", roundf(iMoney * 10 / RMB_WAN ) / 10];
        unit   = @"万元";
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:nMoney,@"nMoney",unit,@"unit", nil];
}

// 90 分钟 => 1.5 小时
+ (NSDictionary *)dealWithHour:(NSString *)nTime {
    NSString *unit = @"分钟";
    NSInteger iTime = [nTime intValue];
    
    if (iTime > TIME_HOUR) {
        nTime = [NSString stringWithFormat:@"%.1f", roundf(iTime * 10 / TIME_HOUR ) / 10];
        unit   = @"小时";
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:nTime,@"nTime",unit,@"unit", nil];
}

+ (NSString *)moneyformat:(int)num {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0"];
    return [numberFormatter stringFromNumber:[NSNumber numberWithInt: num]];
}
@end
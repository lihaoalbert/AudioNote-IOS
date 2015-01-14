//
//  MyTableViewCell.h
//  AudioNote
//
//  Created by lijunjie on 15-1-7.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef AudioNote_MyTableViewCell_h
#define AudioNote_MyTableViewCell_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface MyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellMoney;
@property (weak, nonatomic) IBOutlet UILabel *cellMoneyUnit;
@property (weak, nonatomic) IBOutlet UILabel *cellTime;
@property (weak, nonatomic) IBOutlet UILabel *cellTimeUnit;
@property (weak, nonatomic) IBOutlet UILabel *cellTagLeft;
@property (weak, nonatomic) IBOutlet UILabel *cellTagRight;
@property (weak, nonatomic) IBOutlet UILabel *cellMoneyDesc;
@property (weak, nonatomic) IBOutlet UILabel *cellTimeDesc;

@property (weak, nonatomic) IBOutlet UIImageView *cellDivider;


@end

#endif

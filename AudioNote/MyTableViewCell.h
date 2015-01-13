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

@property (weak, nonatomic) IBOutlet UILabel *cellNum;  // 值: 金额/时间
@property (weak, nonatomic) IBOutlet UILabel *cellTag;  // 分类
@property (weak, nonatomic) IBOutlet UILabel *cellDesc; // 保留字
@property (weak, nonatomic) IBOutlet UILabel *cellUnit; // 金额/时间
@property (weak, nonatomic) IBOutlet UILabel *cellTime; // 创建时间 12：10

@end

#endif

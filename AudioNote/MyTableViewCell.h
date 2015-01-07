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

@property (weak, nonatomic) IBOutlet UILabel *cellNum;
@property (weak, nonatomic) IBOutlet UILabel *cellTag;
@property (weak, nonatomic) IBOutlet UILabel *cellDesc;

@end

#endif

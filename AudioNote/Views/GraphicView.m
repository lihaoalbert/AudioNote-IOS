//
//  GraphicView.m
//  DrawGraphic
//
//  Created by wu on 14-11-12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "GraphicView.h"

#import "DatabaseUtils.h"


@implementation MY_KEY_VALUE
@end

@implementation GraphicView

- (void) setStartPointMoney: (CGPoint) p {
    m_startPointMoney = p;
    NSLog(@"set startPointMoney x=[%d], y=[%d]",(int)p.x,(int)p.y);
}

- (void) setStartPointTime: (CGPoint) p {
    m_startPointTime = p;
    NSLog(@"set startPointTime x=[%d], y=[%d]",(int)p.x,(int)p.y);
}

- (void) setWidth: (int) width {
    m_nWidth = width;
    NSLog(@"set nWidth=[%d]",width);
}

- (void) setHeight: (int) height {
    m_nHeight = height;
    NSLog(@"set nHeight=[%d]",height);
}

- (void) setBeginDate:(NSString *)datestr {
    m_nszBeginDate = datestr;
    NSLog(@"set beginDate=[%@]",m_nszBeginDate);
}

- (void) setEndDate:(NSString *)datestr {
    m_nszEndDate = datestr;
    NSLog(@"set endDate=[%@",m_nszEndDate);
}

- (void) setColorArray: (NSMutableArray *) arrColor {
    if ([arrColor count] > 1)
        m_colorArray = arrColor;
    NSLog(@"set colorArray, count=%d",(int)[arrColor count]);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    m_nWidth = [UIScreen mainScreen].bounds.size.width;
    m_nHeight = [UIScreen mainScreen].bounds.size.height;
    m_startPointMoney.x = 0;
    m_startPointMoney.y = 0;
    m_startPointTime.x = m_nWidth / 2;
    m_startPointTime.y = 0;
    
    m_colorArray = [NSMutableArray arrayWithObjects:
                    [UIColor colorWithRed:(124.0/255.0) green:(181.0/255.0) blue:(236.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(67.0/255.0) green:(67.0/255.0) blue:(72.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(144.0/255.0) green:(237.0/255.0) blue:(125.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(247.0/255.0) green:(163.0/255.0) blue:(92.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(128.0/255.0) green:(133.0/255.0) blue:(233.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(241.0/255.0) green:(92.0/255.0) blue:(128.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(141.0/255.0) green:(70.0/255.0) blue:(83.0/255.0) alpha:1.0],
                    [UIColor colorWithRed:(228.0/255.0) green:(211.0/255.0) blue:(84.0/255.0) alpha:1.0],
                    [UIColor whiteColor],
                  nil];
 /*
  m_colorArray = [NSMutableArray arrayWithObjects:
                [UIColor redColor],
                [UIColor yellowColor],
                [UIColor greenColor],
                [UIColor cyanColor],
                [UIColor orangeColor],
                [UIColor blueColor],
                [UIColor colorWithRed:1.0 green:(182.0/255.0) blue:(193.0/255.0) alpha:1.0],
                [UIColor purpleColor],
                [UIColor whiteColor],
                nil];
     */
    m_nszBeginDate = @"2000-01-01";
    m_nszEndDate = @"2030-12-31";
    m_timeTotal = 0;
    m_moneyTotal = 0;
    m_timePieIndex = 0;
    m_moneyPieIndex = 0;
    return self;
}

NSArray *selectDBwithDate(char *beginDate, char *endDate) {
    NSArray *arr;
    char szSQL[MAX_INPUT_LEN*2];
    char *errorMsg=NULL;
    int result=0;
    sqlite3 *database;
    NSString *databaseFilePath;
    sqlite3_stmt *statement;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    ////////////////////////////////
    // Input checking
    ////////////////////////////////
    if (beginDate == NULL || endDate == NULL)
        return mutableArray;
    
    ////////////////////////////////
    // Open DB
    ////////////////////////////////
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    databaseFilePath=[documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    NSLog(@"db_path=[%@]",databaseFilePath);
    result = sqlite3_open([databaseFilePath UTF8String], &database);
    if (result != SQLITE_OK)
        return arr;
    
    ////////////////////////////////
    // Get the ID just inserted
    ////////////////////////////////
    snprintf(szSQL,MAX_INPUT_LEN*2-1,"Select id,input,description,category,nMoney,nTime,begin,duration,create_time,modify_time from voice_record where create_time >= '%s 00:00:00' AND create_time <= '%s 23:59:59' order by id;",beginDate,endDate);
    szSQL[MAX_INPUT_LEN*2-1] = '\0';
    if (sqlite3_prepare_v2(database, szSQL, -1, &statement, &errorMsg) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            ////////////////////////////
            // Get a record from DB
            ////////////////////////////
            int myid = sqlite3_column_int(statement,0);
            char *szInput = (char *)sqlite3_column_text(statement,1);
            char *szDescription = (char *)sqlite3_column_text(statement,2);
            char *szCategory = (char *)sqlite3_column_text(statement,3);
            int nMoney = sqlite3_column_int(statement,4);
            int nTime = sqlite3_column_int(statement,5);
            char *szBegin = (char *)sqlite3_column_text(statement,6);
            int nDuration = sqlite3_column_int(statement,7);
            char *szCreate_time = (char *)sqlite3_column_text(statement,8);
            char *szModify_time = (char *)sqlite3_column_text(statement,9);
            
            ////////////////////////////
            // Transform to NSMutableDictionary
            ////////////////////////////
            [mutableDictionary setObject:[NSString stringWithFormat:@"%d",myid] forKey:@"id"];
            [mutableDictionary setObject:[NSString stringWithUTF8String:szInput] forKey:@"input"];
            [mutableDictionary setObject:[NSString stringWithUTF8String:szDescription] forKey:@"description"];
            [mutableDictionary setObject:[NSString stringWithUTF8String:szCategory] forKey:@"category"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%d",nMoney] forKey:@"nMoney"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%d",nTime] forKey:@"nTime"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%s",szBegin] forKey:@"begin"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%d",nDuration] forKey:@"duration"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%s",szCreate_time] forKey:@"create_time"];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%s",szModify_time] forKey:@"modify_time"];
            
            //NSLog(@"mutableDictionary allKeys = %@", [mutableDictionary allKeys]);
            //NSLog(@"mutableDictionary allValues = %@", [mutableDictionary allValues]);
            debug_printf("id=%d, input=%s, description=%s, category=%s, nMoney=%d, nTime=%d, begin=%s\n",
                         myid, szInput, szDescription, szCategory, nMoney, nTime, szBegin);
            
            ////////////////////////////
            // Transform mutableDictionary to json NSString
            ////////////////////////////
            NSError *error;
            NSData *jsonData;
            NSString *jsonStr;
            
            if ([NSJSONSerialization isValidJSONObject:mutableDictionary]) {
                // NSMutableDictionary convert to JSON Data
                jsonData = [NSJSONSerialization dataWithJSONObject:mutableDictionary options:NSJSONWritingPrettyPrinted error:&error];
                // JSON Data convert to NSString
                jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                //NSLog(@"NSMutableDictionary to JSON String: %@", jsonStr);
            }
            
            // put josnString to NSMutableArray
            [mutableArray addObject:jsonStr];
        } // end of while (sqlite3_step(statement)
        sqlite3_finalize(statement);
    }
    else
        printf("errorMsg=%s\n",errorMsg);
    sqlite3_close(database);
    
    return mutableArray;
} // end fo selectDBwithDate()

- (int)loadFromDB {
    char szBeginDate[MAX_INPUT_LEN],szEndDate[MAX_INPUT_LEN];
    NSArray *resultArray;
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *timeDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *moneyDict = [[NSMutableDictionary alloc] init];
    NSError *error;
    NSString *nszValue;
    int nValue,nLen=0,i;
    
    /////////////////////
    // 准备 beginDate 以及 endDate， 从 DB 里面读取资料 ==> resultArray
    /////////////////////
    strncpy(szBeginDate,[m_nszBeginDate UTF8String],MAX_INPUT_LEN-1);
    szBeginDate[MAX_INPUT_LEN-1] = '\0';
    strncpy(szEndDate,[m_nszEndDate UTF8String],MAX_INPUT_LEN-1);
    szEndDate[MAX_INPUT_LEN-1] = '\0';
    
    
    
    //resultArray = selectDBwithDate(szBeginDate, szEndDate);
    [DatabaseUtils setUP];
    DatabaseUtils *database = [[DatabaseUtils alloc] init];
    NSString *from = [NSString stringWithFormat:@"%s", szBeginDate];
    NSString *to   = [NSString stringWithFormat:@"%s", szEndDate];
    resultArray = [database selectFrom:from To:to Order:@"create_time" Format:@"json"];
    NSLog(@"result array size=[%d]",(int)resultArray.count);
    
    
    /////////////////////
    // 1. json string => mutableDictionary
    // 2. mutableDictionary => 依照类别以及 time / money, 分成
    //    m_moneyArray + m_timeArray (储存用)
    //    mondyDict + timeDict (加总使用, 会把所有的［学习］时间／金钱 加在一起
    // 3. 把 moneyDict / timeDict => MY_KEY_VALUE 的 Array (sortMoneyArray / sortTimeArray)
    // 4. 把 sortMoneyArray / sortTimeArray 做排序, 结果放在 m_moneyArraySorted / m_timeArraySorted
    /////////////////////
    
    /////////////////////
    // parse resultArray => m_timeArray & m_moneyArray
    // 把急啊总结果存到 m_timeDict & m_moneyDict
    /////////////////////
    m_timeTotal = 0;
    m_moneyTotal = 0;
    m_timeArray = [[NSMutableArray alloc] init];
    m_moneyArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortTimeArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortMoneyArray = [[NSMutableArray alloc] init];
    
    for (NSString *str in resultArray) {
        // 步骤 1.
        mutableDictionary = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        NSString *category = [mutableDictionary objectForKey:@"category"];
        NSString *moneystr = [mutableDictionary objectForKey:@"nMoney"];
        NSString *timestr = [mutableDictionary objectForKey:@"nTime"];
        NSLog(@"category=[%@], moneystr=[%@], timestr=[%@]",category,moneystr,timestr);
        
        if ([moneystr intValue] > 0) {
            [m_moneyArray addObject: mutableDictionary];
            m_moneyTotal += [moneystr intValue];
            if ((nszValue=[moneyDict objectForKey:category]) == NULL) {
                nValue = [moneystr intValue];
            }
            else {
                nValue = [nszValue intValue];
                nValue += [moneystr intValue];
            }
            // 步骤 2.
            [moneyDict setObject:[NSString stringWithFormat:@"%d",nValue] forKey:category];
            NSLog(@"category=[%@], dict_value=[%@]",category,[moneyDict objectForKey:category]);
        }
        else if ([timestr intValue] > 0) {
            [m_timeArray addObject: mutableDictionary];
            m_timeTotal += [timestr intValue];
            if ((nszValue=[timeDict objectForKey:category]) == NULL) {
                nValue = [timestr intValue];
            }
            else {
                nValue = [nszValue intValue];
                nValue += [timestr intValue];
            }
            // 步骤 2.
            [timeDict setObject:[NSString stringWithFormat:@"%d",nValue] forKey:category];
            NSLog(@"category=[%@], dict_value=[%@]",category,[timeDict objectForKey:category]);
        }
    } // end of for
    NSLog(@"%d records in timeArray, total=%d",(int)[m_timeArray count],m_timeTotal);
    NSLog(@"%d records in moneyArray, total=%d",(int)m_moneyArray.count,m_moneyTotal);
    NSSortDescriptor * sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"myValue" ascending:NO];
    
    /////////////////////////
    // Try to sort moneyDict, 结果放在 m_moneyDict
    /////////////////////////
    // moneyDict => sortMoneyArray
    // 步骤 3.
    for (NSString *key in moneyDict) {
        MY_KEY_VALUE * keyValue = [[MY_KEY_VALUE alloc] init];
        keyValue.myKey = key;
        keyValue.myValue = [[moneyDict objectForKey:key] intValue];
        [sortMoneyArray addObject:keyValue];
    }
    
    NSArray * sdMoneyArray = [NSArray arrayWithObject:sortDesc];
    // 步骤 4.
    m_moneyArraySorted = [sortTimeArray sortedArrayUsingDescriptors:sdMoneyArray];
    for (id obj in m_moneyArraySorted) {
        NSLog(@"***** %@ %d",[obj myKey],[obj myValue]);
    }

    /////////////////////////
    // Try to sort timeDict, 结果放在 m_timeDict
    /////////////////////////
    // timeDict => sortTimeArray
    // 步骤 3.
    for (NSString *key in timeDict) {
        MY_KEY_VALUE * keyValue = [[MY_KEY_VALUE alloc] init];
        keyValue.myKey = key;
        keyValue.myValue = [[timeDict objectForKey:key] intValue];
        [sortTimeArray addObject:keyValue];
    }
    
    NSArray * sdTimeArray = [NSArray arrayWithObject:sortDesc];
    // 步骤 4.
    m_timeArraySorted = [sortTimeArray sortedArrayUsingDescriptors:sdTimeArray];
    for (id obj in m_timeArraySorted) {
        NSLog(@"***** %@ %d",[obj myKey],[obj myValue]);
    }
    return SUCCESS;
}

- (void)drawRect:(CGRect)rect {
    
    /////////////////////
    // 1. 取出上下文（画布）
    /////////////////////
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /////////////////////
    // 2. 根据 nszStartDate ~ nszEndDate 从 DB 里面读出资料
    /////////////////////
    //2.选择调用的方法，以绘制图形
//    [self drawLine:context];
//    [self drawShapeRect:context];
    [self drawArc:context];
//    [self drawCure:context];
//    [self drawText:context];
//    [self drawImage:context];
    
}

#pragma mark - 绘制线条

- (void)drawLine2:(CGContextRef)context {
    
    //2.添加多条线
    CGPoint p0 = {50,50};
    CGPoint p1 = {200,200};
    CGPoint p2 = {50,200};
    CGPoint p3 = {50,50};
    CGPoint points[] = {p0,p1,p2,p3};
    CGContextAddLines(context, points, 4);
    
    //设置线条的颜色
    [[UIColor redColor] setStroke];
    //设置线条的填充颜色
    [[UIColor blueColor] setFill];
    
    //设置线条、填充的颜色
    //    [[UIColor blueColor] set];
    
    //3.绘制路径
    CGContextDrawPath(context, kCGPathFillStroke);
}

//绘制线条
- (void)drawLine:(CGContextRef)context {
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //1.获取上下文（画布）
    
    //2.创建一个绘制的路径
    //    CGPathRef
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画线
    //(1)设置起始点
    CGPathMoveToPoint(path, NULL, 50, 50);
    //（2）设置目标点
    CGPathAddLineToPoint(path, NULL, 200, 200);
    CGPathAddLineToPoint(path, NULL, 300, 80);
    
    //关闭路径(使路径封闭起来)
//    CGPathCloseSubpath(path);
    
    //3.将路径添加到上下文
    CGContextAddPath(context, path);
    
    //4.设置上下文的属性
    /**
     *  设置线条的颜色
     red    0-1.0   red/255.0
     green  0-1.0   green/255.0
     blue   0-1.0   blue/255.0
     */
//    CGContextSetRGBStrokeColor(context, 75/255.0, 179/255.0, 72/255.0, 1.0);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    //设置填充的颜色
//    CGContextSetRGBFillColor(context, 20/255.0, 82/255.0, 210/255.0, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    //设置线条的宽度
    CGContextSetLineWidth(context, 3);
    //设置线条顶点样式
    //    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    //5.绘制路径
    /**
     *  绘制模式：
     kCGPathFill  画线（空心）
     kCGPathFill  填充 (实心)
     kCGPathFillStroke  即画线又填充
     */
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //6.释放路径
    CGPathRelease(path);
}

#pragma mark - 绘制矩形
- (void)drawShapeRect:(CGContextRef)context {
    
    /*
     //1.获取上下文
     
     //2.绘制矩形
     CGRect rect = CGRectMake(40, 40, 100, 200);
     //    CGContextAddRect(context, rect);
     
     //3.设置线宽、颜色
     CGContextSetLineWidth(context, 2);
     [[UIColor redColor] setStroke];
     [[UIColor blueColor] setFill];
     
     //4.绘制
     CGContextDrawPath(context, kCGPathFillStroke);
     */
    
    //UIKit 提供绘制矩形的函数
    [[UIColor redColor] setStroke];
    [[UIColor blueColor] setFill];
    
    CGRect rect = CGRectMake(40, 40, 100, 200);
    //绘制填充矩形（实心）
    UIRectFill(rect);
    //绘制线条矩形（空心）
    UIRectFrame(rect);
}

#pragma mark - 绘制圆弧
- (void)drawArc:(CGContextRef)context {
    CGPoint p;
    int radius=0,nLen=0,nColorLen=0,nCount=0;
    float startArc=0,endArc=0,beginArc=0,areaArc;

    //设置圆心
    p.x = m_startPointMoney.x + m_nWidth/2;
    p.y = m_startPointMoney.y + m_nHeight/2;
    radius = (m_nWidth > m_nHeight) ? m_nHeight/2 : m_nWidth/2;
    
    //////////////////////////////////
    //  @param context      上下文
    //  @param x y          圆的中心点
    //  @param radius       圆的半径
    //  @param startAngle   起始的角度
    //  @param endAngle     结束的角度
    //  @param clockwise    顺时针：0   逆时针：1
    //////////////////////////////////
    // 弧度 M_PI        角度 180
    // 弧度 M_PI_2      角度 90
    // 弧度 M_PI_4      角度 45
    // 绘制圆
    
    nLen = [m_timeArraySorted count];
    nColorLen = [m_colorArray count];
    
    if (nColorLen >= nLen) { // 颜色总数超过 Distinct Category 总数
        for (id obj in m_timeArraySorted) {
            areaArc = (float)[obj myValue] / m_timeTotal * 2 * M_PI;
            if (startArc == 0 && endArc == 0) { // 第一个
                startArc = M_PI_2 - areaArc / 2;
                endArc = M_PI_2 + areaArc / 2;
            }
            else {
                startArc = endArc;
                endArc += areaArc;
            }
            UIColor* colorNow = m_colorArray[nCount];
            CGContextMoveToPoint(context, p.x, p.y);
            CGContextSetFillColorWithColor(context, colorNow.CGColor);
            CGContextAddArc(context, p.x, p.y, radius, startArc, endArc, 0);
            CGContextFillPath(context);
            nCount ++;
        }
    }
    else { // Distinct Category 比较多, 最后一个颜色的算是［其它］
        for (id obj in m_timeArraySorted) {
            areaArc = (float)[obj myValue] / m_timeTotal * 2 * M_PI;
            if (startArc == 0 && endArc == 0) { // 第一个
                startArc = M_PI_2 - areaArc / 2;
                endArc = M_PI_2 + areaArc / 2;
                beginArc = startArc;
            }
            else {
                startArc = endArc;
                endArc += areaArc;
            }
            UIColor* colorNow = m_colorArray[nCount];
            CGContextMoveToPoint(context, p.x, p.y);
            CGContextSetFillColorWithColor(context, colorNow.CGColor);
            CGContextAddArc(context, p.x, p.y, radius, startArc, endArc, 0);
            CGContextFillPath(context);
            nCount ++;
            if (nCount == nColorLen-1)
                break;
        }
        // draw 其它
        SEL colorSel = NSSelectorFromString(m_colorArray[nCount]);
        UIColor* colorNow = [UIColor performSelector: colorSel];
        CGContextMoveToPoint(context, p.x, p.y);
        CGContextSetFillColorWithColor(context, colorNow.CGColor);
        CGContextAddArc(context, p.x, p.y, radius, endArc, beginArc, 0);
        CGContextFillPath(context);
    }
    
    ////////////////////////
    // 画三角
    ////////////////////////
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, p.x, p.y+radius*0.98);
    CGContextAddLineToPoint(context, p.x-radius*0.03, p.y+radius*1.1);
    CGContextAddLineToPoint(context, p.x+radius*0.03, p.y+radius*1.1);
    CGContextAddLineToPoint(context, p.x, p.y+radius*0.98);
    CGContextClosePath(context);
    [[UIColor colorWithRed:(226.0/255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:0.3] setFill];
    [[UIColor blackColor] setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - 绘制贝塞尔曲线
- (void)drawCure:(CGContextRef)context {
    
    //1.设置起始点
    CGContextMoveToPoint(context, 20, 200);
    
    /**
     *
     *  @param context
     *  @param cp1x cp1y  第一条切线的终点
     *  @param cp2x cp2y  第二条切线的起始点
     *  @param x  y       第二条切线的终点
     *
     */
    //    CGContextAddCurveToPoint(context, 100, 20,
    //                             200, 300,
    //                             300, 50);
    
    CGContextAddQuadCurveToPoint(context, 140, 20,
                                 300, 200);
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

#pragma mark - 绘制文字
- (void)drawText:(CGContextRef)context {
    
    //Core Text
    
    //    NSString *string = @"Hello World Hello World Hello World Hello World Hello World Hello World";
    
    NSString *string = @"1234567890";
    
    
    //    [string drawInRect:<#(CGRect)#> withAttributes:<#(NSDictionary *)#>]
    
    CGRect rect = CGRectMake(50, 50, 50, 300);
    
    [[UIColor whiteColor] setFill];
    UIRectFill(rect);
    
    UIFont *font = [UIFont systemFontOfSize:20];
    
    
    [[UIColor blackColor] setFill];
    /**
     *lineBreakMode : 换行方式：
     NSLineBreakByCharWrapping  根据字符换行
     NSLineBreakByWordWrapping  根据单词换行
     */
    [string drawInRect:rect withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    
}

#pragma mark - 图像的绘制
- (void)drawImage:(CGContextRef)context {
    UIImage *image = [UIImage imageNamed:@"2012100413195471481.jpg"];
    
    CGContextSaveGState(context);
    
    //转换坐标 ：Quartz 2D 坐标系统 ----> UIKit坐标
    CGContextRotateCTM(context, M_PI);  //1.顺时针旋转180
    CGContextScaleCTM(context, -1, 1);  //2.旋转x坐标
    //3.向上平移
    CGContextTranslateCTM(context, 0, -image.size.height);
    
    
    //1.在指定点绘制图像
    //[image drawAtPoint:CGPointMake(50, 50)];
    
    //2.在指定的矩形区域内绘制,拉伸填充绘制
    //    [image drawInRect:CGRectMake(0, 0, 320, 200)];
    
    //3.在指定的矩形区域内绘制，平铺显示
    //    [image drawAsPatternInRect:CGRectMake(0, 0, 320, 200)];
    
    
    //Core Graphic 中提供的函数绘制图形
    //Core Graphic 框架中没有使用UIKit中相关的类型，目的是不与UIKit耦合，因为Core Graphic 框架是跨平台的，如果依赖了UIKit框架就不能在Mac开发中使用此框架了，跨平台的框架不能与平台中独有的框架耦合
    CGContextDrawImage(context, CGRectMake(30, -50, 200, 200), image.CGImage);
    
    //恢复context
    CGContextRestoreGState(context);
}



@end

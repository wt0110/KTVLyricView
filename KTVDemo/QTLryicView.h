//
//  QTLryicView.h
//  KTVDemo
//
//  Created by wangtao on 2017/11/1.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "QTLyricObject.h"

@class QTLyricView;
@protocol QTLyricViewDelegate <NSObject>
- (CGFloat)lyricViewTimeSync:(QTLyricView *)lyricView;  //调整字幕文件显示不同步
@end

@interface QTLyricView : UIView
@property (nonatomic, strong)id<QTLyricViewDelegate> delegate;
@property (nonatomic, strong)QTLyricObject *object;

@property (nonatomic, strong)UIColor *hightLightColor;
@property (nonatomic, strong)UIColor *normalColor;

- (void)play;
- (void)stop;
@end

//
//  QTLryicView.m
//  KTVDemo
//
//  Created by wangtao on 2017/11/1.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import "QTLryicView.h"
#import "LXMLyricsLabel.h"

@interface QTLyricView()
@property (nonatomic, strong)LXMLyricsLabel *lyricLabel;
@end

@implementation QTLyricView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        LXMLyricsLabel *lyricsLabel = [[LXMLyricsLabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, 20)];
        lyricsLabel.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 2, 200);
        lyricsLabel.backgroundColor = [UIColor lightGrayColor];
        lyricsLabel.textLabel.textColor = [UIColor whiteColor];
        lyricsLabel.font = [UIFont systemFontOfSize:17];
        lyricsLabel.textAlignment = NSTextAlignmentCenter;
        self.lyricLabel = lyricsLabel;
        [self addSubview:lyricsLabel];
    }
    return self;
}

- (void)play {

}

- (void)stop {

}
@end

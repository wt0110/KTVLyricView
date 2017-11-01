//
//  QTLryicView.m
//  KTVDemo
//
//  Created by wangtao on 2017/11/1.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import "QTLyricView.h"
#import "LXMLyricsLabel.h"
#import <CoreText/CoreText.h>

@interface QTLyricView()
@property (nonatomic, strong)LXMLyricsLabel *lyricsLabel;
@property (nonatomic, strong) QTLrcSentence *currentStc;
@property (nonatomic, assign) NSInteger stcIndex;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation QTLyricView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        LXMLyricsLabel *lyricsLabel = [[LXMLyricsLabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, 20)];
        lyricsLabel.backgroundColor = [UIColor lightGrayColor];
        lyricsLabel.textLabel.textColor = [UIColor whiteColor];
        lyricsLabel.font = [UIFont systemFontOfSize:17];
        lyricsLabel.textAlignment = NSTextAlignmentCenter;
        self.lyricsLabel = lyricsLabel;
        [self addSubview:lyricsLabel];
    }
    return self;
}

- (void)play {
    QTLrcSentence *sentence = [self.lyric.sentences firstObject];
    CGFloat diff = sentence.begin/1000.0;
    if ([self.delegate respondsToSelector:@selector(lyricViewTimeSync:)]) {
        diff = sentence.begin/1000.0 - [self.delegate lyricViewTimeSync:self];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:diff target:self selector:@selector(timerFire:) userInfo:nil repeats:NO];
}

- (void)stop {
    [self.timer invalidate];
}

- (void)timerFire:(NSTimer *)timer {
    self.currentStc = [self.lyric.sentences objectAtIndex:self.stcIndex];
    [self.lyricsLabel setText:self.currentStc.sentence];
    [self.lyricsLabel sizeToFit];

    NSArray *ls = [self getSeparatedWordTimeFromLabel:self.lyricsLabel.textLabel];
    NSMutableArray *timeArray = [NSMutableArray array];
    NSMutableArray *locationArray =  [NSMutableArray array];
    [timeArray addObject:@(0)];
    [locationArray addObject:@(0)];

    NSInteger tmpIdx = 0;
    CGFloat timeCount = 0;
    for (int i = 0; i < self.currentStc.words.count; i++) {
        QTLyricWord *wordObj = [self.currentStc.words objectAtIndex:i];

        CGFloat wTime = wordObj.duration/1000.0;
        timeCount += wTime;

        [timeArray addObject:@(timeCount)];

        CGFloat wloc = 0;
        for (int j = 0; j < wordObj.word.length; j++) {
            CGPoint point = [[ls objectAtIndex:tmpIdx] CGPointValue];

            if (j == 0) {
                wloc += point.x + point.y;
            }else {
                wloc += point.y;
            }

            tmpIdx++;
        }

        wloc = wloc/self.lyricsLabel.frame.size.width;
        [locationArray addObject:@(wloc)];
    }

    [timeArray addObject:@(self.currentStc.duration/1000.0)];
    [locationArray addObject:@(1)];

    CGFloat diff = 0;
    if ([self.delegate respondsToSelector:@selector(lyricViewTimeSync:)]) {
        diff = [self.delegate lyricViewTimeSync:self] - self.currentStc.begin/1000.0;
    }

    [self.lyricsLabel startLyricsAnimationWithTimeArray:timeArray andLocationArray:locationArray];

    if (self.stcIndex + 1 < self.lyric.sentences.count) {
        QTLrcSentence *nextSentence = [self.lyric.sentences objectAtIndex:self.stcIndex + 1];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(nextSentence.begin - self.currentStc.begin)/1000.0 - diff target:self selector:@selector(timerFire:) userInfo:nil repeats:NO];
        self.stcIndex++;
    }else {
        self.stcIndex = 0;
    }
}


- (NSArray *)getSeparatedWordTimeFromLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];

    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width + 1000,rect.size.height + 100));

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];

    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
//        CFRange lineRange = CTLineGetStringRange(lineRef);
//        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
//        NSString *lineString = [text substringWithRange:range];

        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);

            CGPoint glyphPositions[glyphCount];
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), glyphPositions);

            CGSize glyphAdvances[glyphCount];
            CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);

            for (NSUInteger g = 0; g < glyphCount; g++) {
                CGPoint pos = glyphPositions[g];
                CGSize adv = glyphAdvances[g];

                NSValue *v = [NSValue valueWithCGPoint:CGPointMake(pos.x, adv.width)];
                [linesArray addObject:v];
            }
        }
    }
    return (NSArray *)linesArray;
}
@end

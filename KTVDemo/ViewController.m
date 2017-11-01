//
//  ViewController.m
//  KTVDemo
//
//  Created by wangtao on 2017/10/30.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import "ViewController.h"
#import "QTLyricObject.h"
#import "LXMLyricsLabel.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreText/CoreText.h>

@interface ViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) LXMLyricsLabel *lyricsLabel;
@property (nonatomic, strong) QTLyricObject *lyric;
@property (nonatomic, strong) QTLrcSentence *currentStc;
@property (nonatomic, assign) NSInteger stcIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel2;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel3;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer; // 播放器palyer
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    LXMLyricsLabel *lyricsLabel = [[LXMLyricsLabel alloc] initWithFrame:CGRectMake(0, 100, 375, 20)];
    lyricsLabel.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) / 2, 200);
    lyricsLabel.backgroundColor = [UIColor lightGrayColor];
    lyricsLabel.textLabel.textColor = [UIColor whiteColor];
    lyricsLabel.font = [UIFont systemFontOfSize:14];
    lyricsLabel.text = @"向前跑！迎着冷眼和嘲笑"; //@"knocking on heaven's door";
    lyricsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lyricsLabel];

    self.lyricsLabel = lyricsLabel;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"yest" ofType:@"zrce"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    QTLyricObject *lyric = [[QTLyricObject alloc] initWithContent:content];
    self.lyric = lyric;

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"yest_ori" withExtension:@"mp3"];
    self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.avAudioPlayer.delegate = self;
    self.avAudioPlayer.volume = 1;
    self.avAudioPlayer.numberOfLoops = 0;
    [self.avAudioPlayer prepareToPlay];
}

- (IBAction)parseBtnClick:(id)sender {
    [self.avAudioPlayer play];
    [self performSelector:@selector(playLyric) withObject:nil afterDelay:1];
}

- (void)playLyric {
    QTLrcSentence *sentence = [self.lyric.sentences firstObject];
    CGFloat diff = sentence.begin/1000.0 - self.avAudioPlayer.currentTime;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:diff target:self selector:@selector(timerFire:) userInfo:nil repeats:NO];
}

- (void)timerFire:(NSTimer *)timer {
    self.currentStc = [self.lyric.sentences objectAtIndex:self.stcIndex];
    [self.lyricsLabel setText:self.currentStc.sentence];
    [self.lyricsLabel sizeToFit];

    //
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
            NSLog(@"location:%f,length:%f",point.x,point.y);

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

    CGFloat diff = self.avAudioPlayer.currentTime - self.currentStc.begin/1000.0;
    self.timerLabel.text = [NSString stringWithFormat:@"%f",self.avAudioPlayer.currentTime];
    [self.timerLabel2 setText:[NSString stringWithFormat:@"%f",self.currentStc.begin/1000.0]];
    [self.timerLabel3 setText:[NSString stringWithFormat:@"%f",diff]];
    [self.lyricsLabel startLyricsAnimationWithTimeArray:timeArray andLocationArray:locationArray];

    if (self.stcIndex + 1 < self.lyric.sentences.count) {
        QTLrcSentence *nextSentence = [self.lyric.sentences objectAtIndex:self.stcIndex + 1];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(nextSentence.begin - self.currentStc.begin)/1000.0 - diff target:self selector:@selector(timerFire:) userInfo:nil repeats:NO];
        self.stcIndex++;
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

    NSLog(@"stence:%@",label.text);

    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        NSLog(@"lineString:%@",lineString);

        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            NSLog(@"glyphCount:%ld",glyphCount);

            CGPoint glyphPositions[glyphCount];
            CTRunGetPositions(run, CFRangeMake(0, glyphCount), glyphPositions);

            CGSize glyphAdvances[glyphCount];
            CTRunGetAdvances(run, CFRangeMake(0, glyphCount), glyphAdvances);

            for (NSUInteger g = 0; g < glyphCount; g++) {
                CGPoint pos = glyphPositions[g];
                CGSize adv = glyphAdvances[g];
                NSLog(@"pos.x:%f adv.w:%f",pos.x,adv.width);

                NSValue *v = [NSValue valueWithCGPoint:CGPointMake(pos.x, adv.width)];
                [linesArray addObject:v];
            }
        }
    }
    return (NSArray *)linesArray;
}
@end

//
//  ViewController.m
//  KTVDemo
//
//  Created by wangtao on 2017/10/30.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QTLyricObject.h"
#import "QTLyricView.h"

@interface ViewController ()<AVAudioPlayerDelegate, QTLyricViewDelegate>
@property (nonatomic, strong) QTLyricView *lyricView;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel2;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel3;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.lyricView = [[QTLyricView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    self.lyricView.delegate = self;
    [self.view addSubview:self.lyricView];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"yest" ofType:@"zrce"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    QTLyricObject *lyric = [[QTLyricObject alloc] initWithContent:content];
    self.lyricView.lyric = lyric;

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
    [self.lyricView play];
}

- (CGFloat)lyricViewTimeSync:(QTLyricView *)lyricView {
    return self.avAudioPlayer.currentTime;
}
@end

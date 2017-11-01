//
//  QTLyricObject.m
//  KTVDemo
//
//  Created by wangtao on 2017/10/30.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import "QTLyricObject.h"

@implementation QTLyricWord
- (id)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        NSArray *results = [content componentsSeparatedByString:@">"];
        NSArray *times = [[results firstObject] componentsSeparatedByString:@","];
        self.word = [results lastObject];
        self.begin = [[times firstObject] integerValue];
        self.duration = [[times objectAtIndex:1] integerValue];
    }
    return self;
}
@end

@implementation QTLrcSentence
- (id)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.words = [NSMutableArray array];

        NSArray *results = [content componentsSeparatedByString:@"]"];
        NSString *time = [[results firstObject] substringFromIndex:1];
        NSArray *timeAndLength = [time componentsSeparatedByString:@","];
        self.begin = [[timeAndLength firstObject] integerValue];
        self.duration = [[timeAndLength lastObject] integerValue];
        NSString *wordsContent = [results lastObject];
        NSArray *words = [wordsContent componentsSeparatedByString:@"<"];

        for (int i = 0; i < words.count; i++) {
            NSString *wc = [words objectAtIndex:i];
            if (wc.length) {
                QTLyricWord *word = [[QTLyricWord alloc] initWithContent:wc];
                [self.words addObject:word];
            }
        }
    }
    return self;
}

- (NSString *)sentence {
    if (!_sentence) {
        _sentence = @"";
        for (int i = 0; i < self.words.count; i++) {
            QTLyricWord *word = [self.words objectAtIndex:i];
            _sentence = [_sentence stringByAppendingString:word.word];
        }
    }
    return _sentence;
}
@end

@implementation QTLyricObject
- (id)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.info = [NSMutableDictionary dictionary];
        self.sentences = [NSMutableArray array];
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        for (int i = 0; i < lines.count; i++) {
            NSString *line = [lines objectAtIndex:i];
            if ([line containsString:@":"]) {
                NSString *result = [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                NSArray *keyValue = [result componentsSeparatedByString:@":"];
                if ([[keyValue objectAtIndex:0] isEqualToString:@"offset"]) {
                    self.offset = [[keyValue objectAtIndex:1] integerValue];
                }else {
                    [self.info setObject:keyValue[1] forKey:keyValue[0]];
                }
            }else {
                if (line.length) {
                   QTLrcSentence *sentence = [[QTLrcSentence alloc] initWithContent:line];
                    [self.sentences addObject:sentence];
                }
            }
        }
    }
    return self;
}
@end

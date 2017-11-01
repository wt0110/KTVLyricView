//
//  QTLyricObject.h
//  KTVDemo
//
//  Created by wangtao on 2017/10/30.
//  Copyright © 2017年 wangtao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface QTLyricWord : NSObject
@property (nonatomic, strong)NSString *word;
@property (nonatomic, assign)NSInteger begin;
@property (nonatomic, assign)NSInteger duration;
- (id)initWithContent:(NSString *)content;
@end

@interface QTLrcSentence : NSObject
@property (nonatomic, strong)NSString *sentence;
@property (nonatomic, assign)NSInteger begin;
@property (nonatomic, assign)NSInteger duration;
@property (nonatomic, strong)NSMutableArray<QTLyricWord *> *words;

- (id)initWithContent:(NSString *)content;
@end

@interface QTLyricObject : NSObject
@property (nonatomic, strong)NSMutableDictionary *info;
@property (nonatomic, assign)NSInteger offset;
@property (nonatomic, strong)NSMutableArray<QTLrcSentence *> *sentences;

- (id)initWithContent:(NSString *)content;
@end

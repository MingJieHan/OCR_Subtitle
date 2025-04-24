//
//  HansVoiceTools.h
//  HansServer
//
//  Created by jia yu on 2024/8/23.
//

#import <Foundation/Foundation.h>
#import <HansServer/HansVoiceSplitedObject.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansVoiceTools : NSObject
/*
 outputFilePathName 输出声音文件的全路径和名字，
 */
+(void)writeVolumes:(nullable NSArray <NSNumber *>*)volumes
   withFilePathName:(nonnull NSString *)outputFilePathName;

/*
 NSString *file = [NSHomeDirectory() stringByAppendingString:@"/Documents/abc.wav"];
 [HansVoiceTools buildSinVoiceDuration:5.f amplitude:@[@0.3] freq:462.12 withFilePathName:file];
 
 NSString *file = [NSHomeDirectory() stringByAppendingString:@"/Documents/all.wav"];
 NSMutableArray *freqs = [[NSMutableArray alloc] init];
 for (float freq=20.f;freq<20000;freq *= 2.f){
     [freqs addObject:[NSNumber numberWithFloat:freq]];
 }
//    [freqs addObject:[NSNumber numberWithFloat:400.f]];
//    [freqs addObject:[NSNumber numberWithFloat:800.f]];
//    [freqs addObject:[NSNumber numberWithFloat:1600.f]];
 [HansVoiceTools buildSinVoiceDuration:1.f amplitude:0.3f freq:freqs withFilePathName:file];
 
 */
+(void)buildSinVoiceDuration:(float)duration
                   amplitude:(float)amplitude
                        freq:(NSArray <NSNumber *>*)freqs
            withFilePathName:(nonnull NSString *)outputFilePathName;
 

//从Audio文件中，提取音频的振幅，用于时间轴中显示出，声音的大小变化
//Rate取样率，如1000，表示为每1000个振幅点，只取1个。 这种方法取得的振幅可绘制振幅度图。
// <NSNumber *> is Float32 type
+(NSMutableArray <NSNumber *> * _Nullable)amplitudeWithAudioURL:(NSURL *)audioFileURL
                                               withSamplingRate:(NSInteger)rate;

// Rate 为 1时，则返回所有的音频振幅点，得到的结果可写入PCM文件，直接播放声音。
//    输出存储所有的取样点，存储为可直接播放的wav文件， 用于输出时 rate要等于1表示全部取样

//    NSString *file = [NSHomeDirectory() stringByAppendingString:@"/Documents/abc.wav"];
//    [HansVoiceTools buildPCMFile:volumes withFilePathName:file];
+(NSMutableArray <NSNumber *>* _Nullable)amplitudeWithAudioURL:(NSURL *)audioFileURL;


/*
 按照播报员的音量，在音量低的位置切分开，切分后的声音，存储到一组文件中。
 返回：切分后的一组文件
 audioFile  需要分割的音频文件
 maxDuration    分割后，每块音频文件的最大时长
 outPath    输出分割文件的路径
 suggestName    输出文件的名字   suggestName_1-n.wav 是最终的名字
 NSArray *results = [HansVoiceTools splitAudioFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/demo.wav"]
                        withMaximumPartDuration:60.f
                                 withOutputPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/"]
                             withSuggestionName:@"demo_part"];
 return;
 */
+(nullable NSMutableArray <HansVoiceSplitedObject *>*)splitAudioFile:(NSURL *)audioFileURL
                            withMaximumPartDuration:(float)maxDuration
                                     withOutputPath:(NSString *)outPath
                                 withSuggestionName:(NSString *)suggestName;

@end
NS_ASSUME_NONNULL_END

//
//  ABI34_0_0EXCameraUtils.m
//  Exponent
//
//  Created by Stanisław Chmiela on 23.10.2017.
//  Copyright © 2017 650 Industries. All rights reserved.
//

#import <ABI34_0_0EXCamera/ABI34_0_0EXCameraUtils.h>

@implementation ABI34_0_0EXCameraUtils

# pragma mark - Camera utilities

+ (AVCaptureDevice *)deviceWithMediaType:(AVMediaType)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
  return [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:mediaType position:position];
}

# pragma mark - Enum conversion

+ (AVCaptureVideoOrientation)videoOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
      return AVCaptureVideoOrientationPortrait;
    case UIInterfaceOrientationPortraitUpsideDown:
      return AVCaptureVideoOrientationPortraitUpsideDown;
    case UIInterfaceOrientationLandscapeRight:
      return AVCaptureVideoOrientationLandscapeRight;
    case UIInterfaceOrientationLandscapeLeft:
      return AVCaptureVideoOrientationLandscapeLeft;
    default:
      return 0;
  }
}

+ (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)orientation
{
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      return AVCaptureVideoOrientationPortrait;
    case UIDeviceOrientationPortraitUpsideDown:
      return AVCaptureVideoOrientationPortraitUpsideDown;
    case UIDeviceOrientationLandscapeLeft:
      return AVCaptureVideoOrientationLandscapeRight;
    case UIDeviceOrientationLandscapeRight:
      return AVCaptureVideoOrientationLandscapeLeft;
    default:
      return AVCaptureVideoOrientationPortrait;
  }
}

+ (float)temperatureForWhiteBalance:(ABI34_0_0EXCameraWhiteBalance)whiteBalance
{
  switch (whiteBalance) {
    case ABI34_0_0EXCameraWhiteBalanceSunny: default:
      return 5200;
    case ABI34_0_0EXCameraWhiteBalanceCloudy:
      return 6000;
    case ABI34_0_0EXCameraWhiteBalanceShadow:
      return 7000;
    case ABI34_0_0EXCameraWhiteBalanceIncandescent:
      return 3000;
    case ABI34_0_0EXCameraWhiteBalanceFluorescent:
      return 4200;
  }
}

+ (NSString *)captureSessionPresetForVideoResolution:(ABI34_0_0EXCameraVideoResolution)resolution
{
  switch (resolution) {
    case ABI34_0_0EXCameraVideo2160p:
      return AVCaptureSessionPreset3840x2160;
    case ABI34_0_0EXCameraVideo1080p:
      return AVCaptureSessionPreset1920x1080;
    case ABI34_0_0EXCameraVideo720p:
      return AVCaptureSessionPreset1280x720;
    case ABI34_0_0EXCameraVideo4x3:
      return AVCaptureSessionPreset640x480;
    default:
      return AVCaptureSessionPresetHigh;
  }
}

# pragma mark - Image utilities

+ (UIImage *)generatePhotoOfSize:(CGSize)size
{
  CGRect rect = CGRectMake(0, 0, size.width, size.height);
  UIImage *image;
  UIGraphicsBeginImageContextWithOptions(size, YES, 0);
  UIColor *color = [UIColor blackColor];
  [color setFill];
  UIRectFill(rect);
  NSDate *currentDate = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
  NSString *text = [dateFormatter stringFromDate:currentDate];
  NSDictionary *attributes = [NSDictionary dictionaryWithObjects: @[[UIFont systemFontOfSize:18.0], [UIColor orangeColor]]
                                                         forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
  [text drawAtPoint:CGPointMake(size.width * 0.1, size.height * 0.9) withAttributes:attributes];
  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect
{
  CGImageRef takenCGImage = image.CGImage;
  CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, rect);
  image = [UIImage imageWithCGImage:cropCGImage scale:image.scale orientation:image.imageOrientation];
  CGImageRelease(cropCGImage);
  return image;
}

+ (NSString *)writeImage:(NSData *)image toPath:(NSString *)path
{
  [image writeToFile:path atomically:YES];
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  return [fileURL absoluteString];
}

+ (void)updateImageSampleMetadata:(CMSampleBufferRef)imageSampleBuffer withAdditionalData:(NSDictionary *)additionalData inResponse:(NSMutableDictionary *)response
{
  CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
  NSDictionary *metadata = (__bridge NSDictionary *)exifAttachments;
  [self updateExifMetadata:metadata withAdditionalData:additionalData inResponse:response];
}

+ (void)updateExifMetadata:(NSDictionary *)metadata withAdditionalData:(NSDictionary *)additionalData inResponse:(NSMutableDictionary *)response
{
  NSMutableDictionary *mutableMetadata = [[NSMutableDictionary alloc] initWithDictionary:metadata];
  mutableMetadata[(NSString *)kCGImagePropertyExifPixelYDimension] = response[@"width"];
  mutableMetadata[(NSString *)kCGImagePropertyExifPixelXDimension] = response[@"height"];

  for (id key in additionalData) {
    mutableMetadata[key] = additionalData[key];
  }

  NSDictionary *gps = mutableMetadata[(NSString *)kCGImagePropertyGPSDictionary];

  if (gps) {
    for (NSString *gpsKey in gps) {
      mutableMetadata[[@"GPS" stringByAppendingString:gpsKey]] = gps[gpsKey];
    }
  }

  response[@"exif"] = mutableMetadata;
}

@end


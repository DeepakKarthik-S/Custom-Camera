//
//  ViewController.h
//  CamRecorder
//
//  Created by deepaks on 30/06/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <ImageIO/CGImageProperties.h>
@interface ViewController : UIViewController<UIGestureRecognizerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureFileOutputRecordingDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIButton *CameraButton;
@property (weak, nonatomic) IBOutlet UILabel *BtnPhoto;
@property (weak, nonatomic) IBOutlet UILabel *BtnVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LeadingMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VerticalMargin;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) IBOutlet UIView *BottomView;
@property (nonatomic, strong)  AVCaptureMovieFileOutput *MovieFileOutput;
@property (weak, nonatomic) IBOutlet UIButton *BtnFlash;
@property (weak, nonatomic) IBOutlet UIButton *BtnToggle;
@property (nonatomic, strong)  AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) int timeSec;
@property (strong, nonatomic) IBOutlet UILabel *TimerLabel;
@property (nonatomic) int timeMin;
@end


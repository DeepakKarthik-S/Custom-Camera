//
//  ViewController.m
//  CamRecorder
//
//  Created by deepaks on 30/06/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
{
    AVCaptureSession*Session;
    BOOL isUsingFrontFacingCamera;
    BOOL Recording;
    AVCaptureDeviceInput *deviceInput;
    AVPlayerItem*playeritem;
    AVPlayer*player;
    AVPlayerLayer*playerLayer;
    AVCaptureDevice *device;
    AVPlayerViewController *playerViewController;UIImageView*imageview;
    BOOL isPhoto;
    BOOL isCamera;
    NSURL*VideoUrl;
    UIImage*CameraImage;
    BOOL isVideo;
    NSTimer*Timer;
    BOOL isInitial;
    BOOL isFront;
    BOOL isFlash;
    BOOL isFlashON;
}
@end

@implementation ViewController
@synthesize BtnPhoto,BtnVideo,LeadingMargin,VerticalMargin;
- (void)viewDidLoad {
    isPhoto=YES;
    isCamera=YES;
    isFront=YES;
    isFlash=YES;
    isFlashON=NO;
    imageview=[[UIImageView alloc]init];
    //    VerticalMargin.constant=0;
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeleft:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiperight:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    [self setupcamera];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.timeMin=0;
    self.timeSec=0;
    [Timer invalidate];
    [self.TimerLabel setText:@"00:00"];
    [self.BtnToggle setHidden:NO];
    isFront=YES;
    isFlash=YES;
    [self setupcamera];
    
}
- (IBAction)BtnactionCapture:(id)sender {
    if (isPhoto) {
        [self captureNow];
    }
    else
    {
        if (!Recording)
        {
            NSLog(@"START RECORDING");
            Recording = YES;
            [self.BtnToggle setHidden:YES];
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"RecordedVideo-%d.mov",arc4random() % 1000]];
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:outputPath])
            {
                NSError *error;
                if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
                {
                }
            }
            Timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:Timer forMode:NSDefaultRunLoopMode];
            
            [self.MovieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
            
            
        }
        else
        {
            NSLog(@"STOP RECORDING");
            [self.BtnToggle setHidden:NO];
            Recording = NO;
            [Session stopRunning];
            [Timer invalidate];
            [_MovieFileOutput stopRecording];
        }
        
    }
}
-(void)SaveVideoToMyAlbumn:(NSURL*)videoURL
{
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc]init];
    [library saveVideo:videoURL toAlbum:@"MyAlbumn" completion:^(NSURL *assetUrl,NSError *error)
     {
         if (error!=nil) {
             NSLog(@"Big error: %@", [error description]);
         }
         else
         {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success"
                                                                                      message:@"Video Saved to My album"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Okay"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [self setupcamera];
                                                              }];
             [alertController addAction:actionOk];
             [self presentViewController:alertController animated:YES completion:nil];

         }
     }failure:nil];
    
    
}

- (void)timerTick:(NSTimer *)timer {
    self.timeSec++;
    if (self.timeSec == 60)
    {
        self.timeSec = 0;
        self.timeMin++;
    }
    //Format the string 00:00
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
    //Display on your label
    self.TimerLabel.text= timeNow;
}
-(void) captureNow {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    NSLog(@"capture from: %@", self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [Session stopRunning];
        
        if (isFlashON) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
       [self SaveImageToMyAlbum:image];
        
    }];
}
-(void)SaveImageToMyAlbum:(UIImage*)image
{
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc]init];
    [library saveImage:image toAlbum:@"MyAlbumn" completion:^(NSURL *assetUrl,NSError *error)
     {
         if (error!=nil) {
             NSLog(@"Big error: %@", [error description]);
         }
         else
         {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success"
                                                                                      message:@"Photo Saved to My album"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Okay"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [self setupcamera];
                                                              }];
             [alertController addAction:actionOk];
             [self presentViewController:alertController animated:YES completion:nil];
         }
     }failure:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)BtnactionClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnactiontoggle:(id)sender {
    if(Session)
    {
        [Session beginConfiguration];
        NSArray *inputs = [Session inputs];
        for (AVCaptureInput *input in inputs)
        {
            [Session removeInput:input];
        }
        AVCaptureDevice *newCamera = nil;
        AVCaptureDevice *audioCaptureDevice=nil;
        if(!isUsingFrontFacingCamera)
        {
            isFront=YES;
            [UIView transitionWithView:self.view
                              duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                            }
                            completion:NULL];
            isUsingFrontFacingCamera=YES;
            [self.BtnFlash setHidden:YES];
            isFlash=YES;
            [self.BtnFlash setImage:[UIImage imageNamed:@"FlashOFF"] forState:UIControlStateNormal];
            
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        }
        else
        {
            [UIView transitionWithView:self.view
                              duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                            }
                            completion:NULL];
            isUsingFrontFacingCamera=NO;
            [self.BtnFlash setHidden:NO];
            isFront=NO;
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        }
        
        NSError *err = nil;
        
        AVCaptureDeviceInput *newaudioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&err];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [Session addInput:newVideoInput];
            [Session addInput:newaudioInput];
            //            newaudioInput = nil;
            //            newVideoInput = nil;
            //            audioCaptureDevice = nil;
            //            newCamera = nil;
        }
        [Session commitConfiguration];
    }}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (device in devices)
    {
        if ([device position] == position)
            return device;
    }
    return nil;
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void)setupcamera
{
    
    NSError *error = nil;
    Session = [[AVCaptureSession alloc] init];
    [self.BtnFlash setHidden:YES];
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            device = d;
            isUsingFrontFacingCamera = YES;
            break;
        }
    }
    if( nil == device )
    {
        isUsingFrontFacingCamera = NO;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    deviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    if ( [Session canAddInput:deviceInput] ){
        [Session addInput:deviceInput];
    }
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        [Session addInput:audioInput];
    }
    self.MovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    Float64 TotalSeconds = 15;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    self.MovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    self.MovieFileOutput.maxRecordedDuration = maxDuration;
    
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ( [Session canAddOutput:self.MovieFileOutput] )
    {
        [Session addOutput:self.MovieFileOutput];
        [Session addOutput:self.stillImageOutput];
    }
    [Session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([Session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720])
    {
        [Session setSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    }
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:Session]];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewLayer setFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    [self.view.layer addSublayer:self.previewLayer];
    [self.view bringSubviewToFront:_BottomView];
    [self.view bringSubviewToFront:_BtnFlash];
    [self.view bringSubviewToFront:_BtnToggle];
    [self.view bringSubviewToFront:_TimerLabel];
    [Session startRunning];
}
- (IBAction)BtnactionFlash:(id)sender {
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (isFlash) {
        if ([device hasTorch]) {
            isFlash=NO;
            isFlashON=YES;
            [self.BtnFlash setImage:[UIImage imageNamed:@"FlashOn"] forState:UIControlStateNormal];
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }
        else
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Sorry"
                                          message:@"You have no torch"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self setupcamera];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
    }
    else
    {
        isFlash=YES;
        isFlashON=NO;
        [self.BtnFlash setImage:[UIImage imageNamed:@"FlashOFF"] forState:UIControlStateNormal];
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
    }
    
}
-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"left");
    isPhoto=NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.VerticalMargin.constant=-75;
                         [self.BottomView layoutSubviews];
                     }completion:^(BOOL finished){
                         
                     }];

    [self.TimerLabel setHidden:NO];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    NSLog(@"Right");
    isPhoto=YES;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.VerticalMargin.constant=0;
                         [self.BottomView layoutSubviews];
                     }completion:^(BOOL finished){
                         
                     }];

    [self.TimerLabel setHidden:YES];
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
        BOOL RecordedSuccessfully = YES;
        if ([error code] != noErr)
        {
            // A problem occurred: Find out if the recording was successful.
            id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
            if (value)
            {
                RecordedSuccessfully = [value boolValue];
            }
        }
        if (RecordedSuccessfully)
        {
            //----- RECORDED SUCESSFULLY -----
            VideoUrl=outputFileURL;
            [self SaveVideoToMyAlbumn:outputFileURL];
            if (isFlashON) {
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device unlockForConfiguration];
            }
        }
}

@end

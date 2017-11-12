//
//  LaunchViewController.m
//  HideNotch
//
//  Created by wutian on 2017/11/12.
//  Copyright © 2017年 Weibo. All rights reserved.
//

#import "LaunchViewController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ViewController.h"

@interface LaunchViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *customStartButton;
@property (weak, nonatomic) IBOutlet UILabel *homeIndicatorLabel;
@property (weak, nonatomic) IBOutlet UITextView *customStartLabel;

@end

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _startButton.layer.cornerRadius = 8;
    
    NSAttributedString * string = _customStartLabel.attributedText;
    NSMutableAttributedString * mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    [mutableString addAttribute:NSLinkAttributeName value:UIApplicationOpenSettingsURLString range:NSMakeRange(mutableString.length - 8, 8)];
    _customStartLabel.attributedText = mutableString;
    _customStartLabel.userInteractionEnabled = YES;
    _customStartLabel.delegate = self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    _startButton.center = CGPointMake(CGRectGetMidX(bounds), bounds.size.height - 250);
    
    {
        CGRect frame = _customStartButton.frame;
        frame.origin.y = CGRectGetMaxY(_startButton.frame);
        _customStartButton.frame = frame;
    }
    
    {
        CGRect frame = _customStartLabel.frame;
        frame.origin.y = CGRectGetMaxY(_customStartButton.frame);
        frame.origin.y -= 10;
        _customStartLabel.frame = frame;
    }
    
    _homeIndicatorLabel.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

- (IBAction)cutomStartButtonPressed:(id)sender
{
    UIImagePickerController * pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = @[(id)kUTTypeQuickTimeMovie, (id)kUTTypeVideo, (id)kUTTypeMovie];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSURL * url = info[UIImagePickerControllerMediaURL];
        if (url) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            viewController.videoURL = url;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:NO completion:NULL];
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return interaction == UITextItemInteractionInvokeDefaultAction;
}

@end

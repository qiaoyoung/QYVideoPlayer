//
//  ViewController.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/17.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "ViewController.h"
#import "QYPlayerView.h"
#import "QYPlayerDefine.h"

@interface ViewController ()<UITextFieldDelegate>

/** 播放器视图 */
@property (nonatomic, strong) QYPlayerView *playerView;
/** 输入框 */
@property (nonatomic, strong) UITextField *textF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
 
    [self.view addSubview:self.playerView];

    self.textF.delegate = self;
    self.textF.text = @"http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4";
    [self.view addSubview:self.textF];
    [self.textF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerView.mas_bottom).mas_offset(10);
        make.left.equalTo(self.view).mas_offset(10);
        make.width.mas_equalTo(kScreenWidth-20);
        make.height.mas_equalTo(30);
    }];

}

#pragma mark - Getter
- (QYPlayerView *)playerView {
    if (!_playerView) {
        CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
        _playerView = [[QYPlayerView alloc] initWithFrame:rect];
        _playerView.backgroundColor = [UIColor blackColor];
        _playerView.layer.borderColor = [UIColor blackColor].CGColor;
        _playerView.layer.borderWidth = 0.5f;
        _playerView.title = @"视频播放器";
    }
    return _playerView;
}
- (UITextField *)textF {
    if (!_textF) {
        _textF = [UITextField new];
        _textF.backgroundColor = [UIColor whiteColor];
        _textF.keyboardType = UIKeyboardTypeWebSearch;
        _textF.enablesReturnKeyAutomatically = YES;
        _textF.placeholder = @"请输入要播放视频的地址...";
        _textF.font = [UIFont systemFontOfSize:15.f];
        _textF.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textF;
}

#pragma mark - UITextViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [self.playerView qy_loadVideo:textField.text];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 在需要全屏的控制器中实现该方法, 控制锁屏功能
- (BOOL)shouldAutorotate {
    return !_playerView.isLockScreen;
}
// iphoneX系列自动隐藏底部横线
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end

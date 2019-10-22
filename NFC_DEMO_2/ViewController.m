//
//  ViewController.m
//  NFC_DEMO_2
//
//  Created by njk on 2019/10/22.
//  Copyright © 2019 NJK. All rights reserved.
//

#import "ViewController.h"

#import <CoreNFC/CoreNFC.h>

@interface ViewController ()<NFCNDEFReaderSessionDelegate>

@property (nonatomic ,strong)UIButton                               *beginButton;
@property (nonatomic ,strong)NFCNDEFReaderSession                   *session;
@property (nonatomic ,strong)UILabel                                *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}
- (void)viewDidAppear:(BOOL)animated{
    [self beginSession];
}

- (void)createUI{
    [self.view addSubview:self.beginButton];
    [self.view addSubview:self.textLabel];
}




- (void)viewDidDisappear:(BOOL)animated{
    self.session = nil;
}

- (void)beginSession{
    if (@available(iOS 11.0, *) && [NFCNDEFReaderSession readingAvailable]) {
        self.session.alertMessage = NSLocalizedString(@"将标签放到手机背面", @"");
        [self.session beginSession];
        
    } else {
        NSLog(NSLocalizedString(@"此设备不支持NFC", @""));
    }
}

- (void)buttonAlick:(UIButton *)button{
    if (button == self.beginButton) {
        [self.session beginSession];
    }
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        for (NFCNDEFMessage *message in messages) {
            for (NFCNDEFPayload *payload in message.records) {
                [self.session invalidateSession];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //在主线程里开启事件
                    NSString *nfcString = [[[NSString alloc] initWithData:payload.payload encoding:NSUTF8StringEncoding] substringFromIndex:1];//因为扫出来的数据多\^C 所以要截取所需要的字符串
                    
                    self.textLabel.text = nfcString;
                });
            }
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(11.0)){
    self.session = nil;
}

- (NFCNDEFReaderSession *)session API_AVAILABLE(ios(11.0)){
    if (!_session) {
        _session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT) invalidateAfterFirstRead:NO];
    }
    return _session;
}
- (UIButton *)beginButton{
    if (!_beginButton) {
        _beginButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 30)];
        [_beginButton setTitle:NSLocalizedString(@"点击开始扫描标签", @"") forState:UIControlStateNormal];
        _beginButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _beginButton.backgroundColor = [UIColor blueColor];
        
        [_beginButton addTarget:self action:@selector(buttonAlick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginButton;
}
- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 200, 80)];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.backgroundColor = [UIColor grayColor];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}


@end

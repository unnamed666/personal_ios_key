//
//  InappController.m
//  PandaKeyboard
//
//  Created by yu dandan on 2019/3/14.
//  Copyright © 2019 CMCM. All rights reserved.
//

#import "CMInappController.h"
//内购
#import "StoreKit/StoreKit.h"
#import "CMRouterManager.h"
#import "CMMainContainerViewController.h"
#import "CMGroupDataManager.h"
#import "CMServicesPrivacyViewController.h"
#import "CMCustomTipsAlert.h"

@interface CMInappController ()
@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, copy) NSString *productID;
@property (nonatomic, copy) NSString *chargeMoneyNumStr;
@property (nonatomic, copy) NSString *orderIDStr;
@property (nonatomic, strong) UILabel* textLabelTitle;
@property (nonatomic, strong) UILabel* textLabelTitle1;
@property (nonatomic, strong) UILabel* textLabel1;
@property (nonatomic, strong) UILabel* textLabel2;
@property (nonatomic, strong) UILabel* textLabel3;
@property (nonatomic, strong) UILabel* textLabel4;
@property (nonatomic, strong) UILabel* textViewPrivacy;
@property (nonatomic, strong) UIButton* yearBuyButton;
@property (nonatomic, strong) UIButton* monthBuyButton;
@property (nonatomic, strong) UIButton* tryAgainButton;
@property (nonatomic, strong) UIButton* restoreButton;
@property (nonatomic, strong) UIButton* termServices;
@property (nonatomic, strong) UIButton* privacyPolicy;
@property (nonatomic, strong) UIImageView* imageViewBg;
@property (nonatomic, strong) UIImageView* imageViewDiscount;
@property (nonatomic, strong) CMCustomTipsAlert* alertView;


@end

@implementation CMInappController

NSString* const kMonthID = @"super_vip_month_monthly";
NSString* const kYearID = @"super_vip_year_yearly";
static NSString * servicesUrlStr = @"https://www.cmcm.com/protocol/site/tos.html";
static NSString * policyUrlStr = @"https://www.cmcm.com/protocol/site/privacy.html";

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpUI];
    
    //请求内购商品的ID的详细信息
    [self requestPruduct];
    
    //设置支付服务
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [CMHostInfoc reportCheetahkeyboard_iapp:@"1" sku:@"null"];
}

- (void)requestPruduct
{
    if([CMOReachability status] == kNavNetWorkNotReachable){ // 无网络
        [self showTryAgain];
    } else {
        [self showBuyButton];
    }

    [self beginRequestWithProductID:kMonthID];
    [self beginRequestWithProductID:kYearID];
}

- (void)showTryAgain {
    _tryAgainButton.hidden = false;
    _monthBuyButton.hidden = YES;
    _yearBuyButton.hidden = YES;
    _imageViewDiscount.hidden = YES;
}

- (void)showBuyButton {
    
    _tryAgainButton.hidden = YES;
    _monthBuyButton.hidden = false;
    _yearBuyButton.hidden = false;
    _imageViewDiscount.hidden = false;
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:_yearProductInfo.priceLocale];
    
    NSDecimalNumber* yearDec = 0;
    if (_yearProductInfo != nil){
        yearDec = [_yearProductInfo price];
    }
    NSString* formattedYearPrice = [numberFormatter stringFromNumber:yearDec];
    NSString* yearPriceStrSubForMonth = [numberFormatter stringFromNumber:[yearDec decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"12"]]];
    
    NSDecimalNumber* monthDec = 0;
    if (_monthProductInfo != nil){
        monthDec = [_monthProductInfo price];
    }
    NSString* monthPriceStr = [numberFormatter stringFromNumber:monthDec];
    
    NSString* yearStr = [NSString stringWithFormat:CMLocalizedString(@"iapp_year_btn", nil), formattedYearPrice];
    NSString* monthStr = [NSString stringWithFormat:CMLocalizedString(@"iapp_month_btn", nil), monthPriceStr];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:yearStr];
    
    NSRange range = [yearStr rangeOfString:@"\n"];
    if (range.location != NSNotFound) {
        //设置字体和设置字体的范围
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8.3f] range:NSMakeRange(range.location, yearStr.length - range.location)];
    }
    _yearBuyButton.titleLabel.attributedText = attrStr;
    
//    NSMutableAttributedString *attrMonthStr = [[NSMutableAttributedString alloc]initWithString:monthStr];
//
//    NSRange monthRange = [monthStr rangeOfString:@"\n"];
//    if (monthRange.location != NSNotFound) {
//        //设置字体和设置字体的范围
//        UIColor *color = [UIColor whiteColor];
//        UIFont *font = [UIFont systemFontOfSize:8.3f];
//        NSDictionary *attrs = @{NSForegroundColorAttributeName : color,
//                                NSFontAttributeName : font};
//        [attrMonthStr addAttributes:attrs range:NSMakeRange(monthRange.location, monthStr.length - monthRange.location)];
//    }
//    _monthBuyButton.titleLabel.attributedText = attrMonthStr;
    
    
    [_yearBuyButton setTitle:yearStr forState:UIControlStateNormal];
    [_monthBuyButton setTitle:monthStr forState:UIControlStateNormal];
    
}

//根据产品信息发起请求，去苹果服务器请求商品
- (void)beginRequestWithProductID:(NSString *)productID
{
    NSLog(@"lxm beginRequestWithProductID");
    NSLog(@"lxm %@",productID);
    NSArray *productArr = [[NSArray alloc] initWithObjects:productID, nil];
    NSSet *productSet = [NSSet setWithArray:productArr];
    SKProductsRequest* productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];;
    productRequest.delegate = self;
    [productRequest start];
}

//当请求到可卖商品的结果会执行该方法
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *productArr = response.products;
    
    
    if (productArr.count == 0) {
        NSLog(@"lxm 购买失败，服务器没商品， productArr.count == 0 ");
        return;
    }
    
    for (SKProduct *product in productArr) {
        
        NSLog(@"lxm 商品描述 %@", [product description]);
        NSLog(@"lxm 商品标题 %@", [product localizedTitle]);
        NSLog(@"lxm 商品本地化描述 %@", [product localizedDescription]);
        NSLog(@"lxm 商品价格 %@", [product price]);
        NSLog(@"lxm 商品ID %@", [product productIdentifier]);
        
        if([product.productIdentifier isEqualToString:kMonthID]) {
            _monthProductInfo = product;
        }
        if([product.productIdentifier isEqualToString:kYearID]) {
           _yearProductInfo = product;
        }
    }
    [self showBuyButton];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"lxm productsRequest， error == %@ ", error);
    [self showTryAgain];
    if(error.code == -1001){
        self.alertView = [[CMCustomTipsAlert alloc] init];
        [self.alertView showAlertWithTitle:CMLocalizedString(@"slow_network", nil) confirmText:CMLocalizedString(@"slow_network_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
        @weakify(self);
        self.alertView.confirmBlock = ^{
            @stronglize(self);
            [self confirmButtonClick];
        };
    }
}

- (void)setUpUI{
    self.canSwipRightToPopViewController = false;
    
    [self.view addSubview:self.imageViewBg];
    [self.view addSubview:self.restoreButton];
    [self.view addSubview:self.termServices];
    [self.view addSubview:self.privacyPolicy];
    [self.view addSubview:self.textLabelTitle];
    [self.view addSubview:self.textLabelTitle1];
    [self.view addSubview:self.textLabel1];
    [self.view addSubview:self.textLabel2];
    [self.view addSubview:self.textLabel3];
    [self.view addSubview:self.textLabel4];
    [self.view addSubview:self.yearBuyButton];
    [self.view addSubview:self.monthBuyButton];
    [self.view addSubview:self.tryAgainButton];
    [self.view addSubview:self.imageViewDiscount];
    [self.view addSubview:self.textViewPrivacy];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"#0D112B"]];
  
    [self.imageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
    [self.restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-30);
        if([UIDevice isHeight568]) {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(15);
        } else {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(50);
        }
        
    }];
    
    [self.termServices mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(10);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-10);
    }];
    
    [self.privacyPolicy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_termServices.mas_right).mas_offset(5);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-10);
    }];
    
    
    [self.textLabelTitle1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textLabelTitle.mas_bottom).mas_offset(1);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.textLabelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        if([UIDevice isHeight568]) {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(40);
        } else {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(150);
        }
        make.left.mas_equalTo(_textLabelTitle1);
    }];
    
    [self.textLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        if([UIDevice isHeight568]) {
            make.top.mas_equalTo(_textLabelTitle1.mas_bottom).mas_offset(20);
        } else {
            make.top.mas_equalTo(_textLabelTitle1.mas_bottom).mas_offset(55);
        }
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.textLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textLabel1.mas_bottom).mas_offset(15);
        make.left.mas_equalTo(_textLabel1.mas_left);
    }];
    
    [self.textLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textLabel2.mas_bottom).mas_offset(15);
        make.left.mas_equalTo(_textLabel1.mas_left);
    }];
    
    [self.textLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textLabel3.mas_bottom).mas_offset(15);
        make.left.mas_equalTo(_textLabel1.mas_left);
    }];
    
    [self.tryAgainButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textLabel4.mas_bottom).offset(50);
//        make.bottom.mas_equalTo(_textViewPrivacy.mas_top);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(40);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
    }];
    
    [self.yearBuyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_monthBuyButton.mas_top).mas_offset(-10);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(40);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
    }];
    
    [self.imageViewDiscount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_yearBuyButton.mas_top).mas_offset(12);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(80);
        make.right.mas_equalTo(_yearBuyButton.mas_right);
    }];
    
    
    [self.monthBuyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_textViewPrivacy.mas_top).mas_offset(-10);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(40);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-40);
    }];
    
    [self.textViewPrivacy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_termServices.mas_top).mas_offset(-1);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).mas_offset(10);
        make.right.mas_equalTo(self.view.mas_right).mas_offset(-10);
//        make.height.mas_equalTo(180);
    }];
    
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (UILabel *)textLabelTitle
{
    if (!_textLabelTitle)
    {
        _textLabelTitle = [[UILabel alloc] init];
         _textLabelTitle.text = CMLocalizedString(@"UNlock", nil);
        _textLabelTitle.textColor = [UIColor whiteColor];
        _textLabelTitle.font =  [UIFont fontWithName:@"Montserrat-Bold" size:27.78];
    }
    
    return _textLabelTitle;
}

- (UILabel *)textLabelTitle1
{
    if (!_textLabelTitle1)
    {
        _textLabelTitle1 = [[UILabel alloc] init];
        [ _textLabelTitle1 setText:@"Cheetah Keyboard"];
        _textLabelTitle1.textColor = [UIColor whiteColor];
        _textLabelTitle1.font =  [UIFont fontWithName:@"Montserrat-Bold" size:27.78];
    }
    
    return _textLabelTitle1;
}


- (UILabel *)textLabel1
{
    if (!_textLabel1)
    {
        _textLabel1 = [[UILabel alloc] init];
        _textLabel1.textColor = [UIColor whiteColor];
        _textLabel1.font =  [UIFont fontWithName:@"Montserrat-Regular" size:17.5];
        _textLabel1.textAlignment = NSTextAlignmentCenter;
    }
    
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:CMLocalizedString(@"All_premium_themes", nil)];
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:@"icon_vipfunction"];
    attch.bounds = CGRectMake(0, 0, 15, 15);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attri insertAttributedString:string atIndex:0];
    //用label的attributedText属性来使用富文本
    _textLabel1.attributedText = attri;
    
    return _textLabel1;
}


- (UILabel *)textLabel2
{
    if (!_textLabel2)
    {
        _textLabel2 = [[UILabel alloc] init];
        _textLabel2.textColor = [UIColor whiteColor];
        _textLabel2.font =  [UIFont fontWithName:@"Montserrat-Regular" size:17.5];
        _textLabel2.textAlignment = NSTextAlignmentCenter;
    }
    
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:CMLocalizedString(@"All_DIY_themes", nil)];
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:@"icon_vipfunction"];
    attch.bounds = CGRectMake(0, 0, 15, 15);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attri insertAttributedString:string atIndex:0];
    //用label的attributedText属性来使用富文本
    _textLabel2.attributedText = attri;
    
    return _textLabel2;
}

- (UILabel *)textLabel3
{
    if (!_textLabel3)
    {
        _textLabel3 = [[UILabel alloc] init];
        _textLabel3.textColor = [UIColor whiteColor];
        _textLabel3.font =  [UIFont fontWithName:@"Montserrat-Regular" size:17.5];
        _textLabel3.textAlignment = NSTextAlignmentCenter;
    }
    
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:CMLocalizedString(@"All_AR-Emoji", nil)];
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:@"icon_vipfunction"];
    attch.bounds = CGRectMake(0, 0, 15, 15);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attri insertAttributedString:string atIndex:0];
    //用label的attributedText属性来使用富文本
    _textLabel3.attributedText = attri;
    
    return _textLabel3;
}

- (UILabel *)textLabel4
{
    if (!_textLabel4)
    {
        _textLabel4 = [[UILabel alloc] init];
        _textLabel4.textColor = [UIColor whiteColor];
        _textLabel4.font =  [UIFont fontWithName:@"Montserrat-Regular" size:17.5];
        _textLabel4.textAlignment = NSTextAlignmentCenter;
    }
    
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:CMLocalizedString(@"All_GIFs", nil)];
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = [UIImage imageNamed:@"icon_vipfunction"];
    attch.bounds = CGRectMake(0, 0, 15, 15);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在第一位
    [attri insertAttributedString:string atIndex:0];
    //用label的attributedText属性来使用富文本
    _textLabel4.attributedText = attri;
    
    return _textLabel4;
}

-(UIButton *) restoreButton
{
    if (!_restoreButton) {
        _restoreButton = [[UIButton alloc] init];
        [_restoreButton addTarget:self action:@selector(restorePurchase) forControlEvents:UIControlEventTouchUpInside];
        _restoreButton.hidden = NO;
        [_restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_restoreButton setTitle:CMLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
        [_restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _restoreButton;
}

-(UIButton *) termServices
{
    if (!_termServices) {
        _termServices = [[UIButton alloc] init];
        [_termServices addTarget:self action:@selector(termsServiceTap) forControlEvents:UIControlEventTouchUpInside];
        _termServices.hidden = NO;
        _termServices.titleLabel.font = [UIFont systemFontOfSize: 9];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy2", nil)]];
        NSRange titleRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0,[title length])];
        //设置下划线颜色...
        [title addAttribute:NSUnderlineColorAttributeName value:[UIColor whiteColor] range:(NSRange){0,[title length]}];
        [_termServices setAttributedTitle:title forState:UIControlStateNormal];
    }
    return _termServices;
}

-(UIButton *) privacyPolicy
{
    if (!_privacyPolicy) {
        _privacyPolicy = [[UIButton alloc] init];
        [_privacyPolicy addTarget:self action:@selector(privacyPolicyTap) forControlEvents:UIControlEventTouchUpInside];
        _privacyPolicy.hidden = NO;
        _privacyPolicy.titleLabel.font = [UIFont systemFontOfSize: 9];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy4", nil)]];
        NSRange titleRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]  range:NSMakeRange(0,[title length])];
        //设置下划线颜色...
        [title addAttribute:NSUnderlineColorAttributeName value:[UIColor whiteColor] range:(NSRange){0,[title length]}];
        [_privacyPolicy setAttributedTitle:title forState:UIControlStateNormal];
        
    }
    return _privacyPolicy;
}

- (UIButton *) yearBuyButton
{
    if (!_yearBuyButton) {
        _yearBuyButton = [[UIButton alloc] init];
        _yearBuyButton.tag = 0;
        [_yearBuyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#FCED56"]] forState:UIControlStateNormal];
        [_yearBuyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#FCED56"]] forState:UIControlStateHighlighted];

        [_yearBuyButton setTitleColor:[UIColor colorWithHexString:@"#09112B"] forState:UIControlStateNormal];
        _yearBuyButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Bold" size:14.5];
        [_yearBuyButton addTarget:self action:@selector(tapDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        _yearBuyButton.hidden = YES;
        [_yearBuyButton.layer setCornerRadius:20];
        _yearBuyButton.layer.masksToBounds = YES;
        _yearBuyButton.lineBreakMode = NSLineBreakByWordWrapping;
        _yearBuyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _yearBuyButton;
}

- (UIButton *) monthBuyButton
{
    if (!_monthBuyButton) {
        _monthBuyButton = [[UIButton alloc] init];
//        [_monthBuyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#FCED56"]] forState:UIControlStateNormal];
//        [_monthBuyButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#FCED56"]] forState:UIControlStateHighlighted];
//
        _monthBuyButton.titleLabel.textColor = [UIColor colorWithHexString:@"#09112B"];
        _monthBuyButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-Bold" size:14.5];
        _monthBuyButton.tag = 1;
        [_monthBuyButton addTarget:self action:@selector(tapDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        _monthBuyButton.hidden = YES;
        [_monthBuyButton.layer setCornerRadius:20];
        _monthBuyButton.layer.masksToBounds = YES;
        [_monthBuyButton.layer setBorderWidth:2.0];
        [_monthBuyButton.layer setBorderColor:[UIColor colorWithHexString:@"#FCED56"].CGColor];
        [_monthBuyButton setTitleColor:[UIColor colorWithHexString:@"#FCED56"] forState:UIControlStateNormal];
        _monthBuyButton.lineBreakMode = NSLineBreakByWordWrapping;
        _monthBuyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _monthBuyButton;
}

- (UIButton *) tryAgainButton
{
    if (!_tryAgainButton) {
        _tryAgainButton = [[UIButton alloc] init];
        [_tryAgainButton setTitle: CMLocalizedString(@"try_again", nil) forState:UIControlStateNormal];
        _tryAgainButton.titleLabel.textColor = [UIColor colorWithHexString:@"#54FFFC"];
        _tryAgainButton.titleLabel.font =  [UIFont fontWithName:@"Montserrat-SemiBold" size:21];
        [_tryAgainButton addTarget:self action:@selector(tapTryAgain) forControlEvents:UIControlEventTouchUpInside];
        _tryAgainButton.hidden = YES;
        [_tryAgainButton.layer setCornerRadius:25];
        _tryAgainButton.layer.masksToBounds = YES;
        [_tryAgainButton.layer setBorderWidth:2.0];
        [_tryAgainButton.layer setBorderColor:[UIColor colorWithHexString:@"#54FFFC"].CGColor];
        [_tryAgainButton setTitleColor:[UIColor colorWithHexString:@"#54FFFC"] forState:UIControlStateNormal];
        _tryAgainButton.lineBreakMode = NSLineBreakByWordWrapping;
        _tryAgainButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tryAgainButton;
}

- (UIImageView *) imageViewBg
{
    if (!_imageViewBg) {
        _imageViewBg = [[UIImageView alloc] init];
        [_imageViewBg setImage:[UIImage imageNamed:@"unlockpage_background"]];
        _imageViewBg.accessibilityElementsHidden = NO;
    }
    return _imageViewBg;
}

- (UILabel *) textViewPrivacy
{
    
    if (!_textViewPrivacy)
    {
        _textViewPrivacy = [[UILabel alloc] init];
        _textViewPrivacy.textColor = [UIColor whiteColor];
        _textViewPrivacy.font =  [UIFont fontWithName:@"Montserrat-Regular" size:9];
        _textViewPrivacy.textAlignment = NSTextAlignmentLeft;
        
        NSString *str1 = [NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy1", nil)];
        NSString *str2 = [NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy2", nil)];
        NSString *str3 = [NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy3", nil)];
        NSString *str4 = [NSString stringWithFormat:CMLocalizedString(@"iapp_year_privacy4", nil)];
        NSString *str = [NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,str4];
        _textViewPrivacy.numberOfLines = 0;
        [_textViewPrivacy sizeToFit];
        [_textViewPrivacy setText:str];
    }
    return _textViewPrivacy;

}


- (UIImageView *) imageViewDiscount
{
    if (!_imageViewDiscount) {
        _imageViewDiscount = [[UIImageView alloc] init];
        [_imageViewDiscount setImage:[UIImage imageNamed:@"icon_supervip_50off"]];
        _imageViewDiscount.hidden = YES;
    }
    return _imageViewDiscount;
}

- (void)restorePurchase
{
if ([CMOReachability status] == kNavNetWorkNotReachable){
    self.alertView = [[CMCustomTipsAlert alloc] init];
    [self.alertView showAlertWithTitle:CMLocalizedString(@"no_network", nil) confirmText:CMLocalizedString(@"no_network_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
    @weakify(self);
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        [self confirmButtonClick];
    };
} else {
     [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
}

- (void)termsServiceTap
{
    CMServicesPrivacyViewController * servicesVC = [[CMServicesPrivacyViewController alloc] init];
    servicesVC.servicesPrivacyUrlStr = servicesUrlStr;
    [self.navigationController pushViewController:servicesVC animated:YES];
}

- (void) privacyPolicyTap
{
    CMServicesPrivacyViewController * servicesVC = [[CMServicesPrivacyViewController alloc] init];
    servicesVC.servicesPrivacyUrlStr = policyUrlStr;
    [self.navigationController pushViewController:servicesVC animated:YES];
}

- (void) tapTryAgain
{
    if ([CMOReachability status] == kNavNetWorkNotReachable){
        self.alertView = [[CMCustomTipsAlert alloc] init];
        [self.alertView showAlertWithTitle:CMLocalizedString(@"no_network", nil) confirmText:CMLocalizedString(@"no_network_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
        @weakify(self);
        self.alertView.confirmBlock = ^{
            @stronglize(self);
            [self confirmButtonClick];
        };
    } else {
        [self requestPruduct];
    }
}

- (void) confirmButtonClick
{
    
}

// 点击购买按钮选择要购买的内容
- (void)tapDidTapped:(UIButton *)btn
{
    SKProduct* skproduct = [SKProduct new];
    switch (btn.tag) {
        case 0:
            NSLog(@"lxm 购买年");
            skproduct = _yearProductInfo;
            [CMHostInfoc reportCheetahkeyboard_iapp:@"4" sku:kYearID];
            break;
        case 1:
            NSLog(@"lxm 购买月");
            skproduct = _monthProductInfo;
            [CMHostInfoc reportCheetahkeyboard_iapp:@"2" sku:kMonthID];
            break;
        default:
            break;
    }

    NSLog(@"lxm onclick purchase");
 
    if ([CMOReachability status] == kNavNetWorkNotReachable){
        self.alertView = [[CMCustomTipsAlert alloc] init];
        [self.alertView showAlertWithTitle:CMLocalizedString(@"no_network", nil) confirmText:CMLocalizedString(@"no_network_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
        @weakify(self);
        self.alertView.confirmBlock = ^{
            @stronglize(self);
            [self confirmButtonClick];
        };
    }
    
    if (skproduct != nil) {
        NSLog(@"lxm 发送购买请求");
        SKPayment *payment = [SKPayment paymentWithProduct:skproduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        self.alertView = [[CMCustomTipsAlert alloc] init];
        [self.alertView showAlertWithTitle:CMLocalizedString(@"slow_network", nil) confirmText:CMLocalizedString(@"slow_network_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
        @weakify(self);
        self.alertView.confirmBlock = ^{
            @stronglize(self);
            [self confirmButtonClick];
        };
    }
}

//支付后的反馈信息
- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"lxm 支付成功了");
}



//下面就是查询购买结果
#pragma mark - SKPaymentTransactionObserver

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                NSLog(@"lxm 交易完成");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self completeTransactionWithTransaction:transaction];
                break;
            
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"lxm 商品正在购买中。。。");
                break;
            
            case SKPaymentTransactionStateRestored:
                NSLog(@"lxm 已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"lxm 购买失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self failedTransaction:transaction];
                break;
            
            default:
                break;
        }
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
     NSLog(@"lxm 恢复购买失败");
    self.alertView = [[CMCustomTipsAlert alloc] init];
    [self.alertView showAlertWithTitle:CMLocalizedString(@"restore_fail_title", nil) confirmText:CMLocalizedString(@"restore_fail_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
    @weakify(self);
    self.alertView.confirmBlock = ^{
        @stronglize(self);
        [self confirmButtonClick];
    };
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"lxm 恢复购买成功");
     [self restorePurchaseVerify];

}

- (NSMutableURLRequest*)verifyRequest{
    // 验证凭证， 获取到苹果返回的交易数据
    // appStoreReceipturl ios 7.0 增加的， 购买完成后，会将凭据存放在该地址
    NSURL *receiptURL  = [[NSBundle mainBundle] appStoreReceiptURL];
    NSLog(@"lxm receiptURL = %@", receiptURL);
    // 从沙盒种获取到购买凭证
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    /**
     BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     BASE64 是可以编码和解码的
     */
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDate *date = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger interval = [timeZone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    NSTimeInterval  today = [localeDate timeIntervalSince1970];
    int intervalInt = (int)today;
    
    NSString* pid = [CMAppConfig deviceIdentify];
    NSString* password =  [CMAppConfig inappPassword];
    
    NSString* forMd5Str = [NSString stringWithFormat:@"%d%@%@%@", intervalInt, pid, encodeStr,password];
    NSString *md5 = [forMd5Str sha1];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                encodeStr,@"receipt-data",
                                                                pid,@"pid",
                                                                [NSNumber numberWithInt:1],@"version",
                                                                [NSNumber numberWithInt:intervalInt],@"time",
                                                                md5,@"md5",
                                                                nil]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error: nil
                        ];
    
    NSURL *StoreURL=nil;
    StoreURL= [[NSURL alloc] initWithString: [CMAppConfig inappUrl]];
    
    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:StoreURL];
    [connectionRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [connectionRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [connectionRequest setHTTPMethod:@"POST"];
    [connectionRequest setTimeoutInterval:50.0];//120.0---50.0zl
    [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [connectionRequest setHTTPBody:jsonData];
    return connectionRequest;
}

//完成购买
- (void)restorePurchaseVerify
{
    NSMutableURLRequest* connectionRequest = [self verifyRequest];
    //开始请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:connectionRequest returningResponse:nil error:&error];
    if (error) {
        NSLog(@"lxm 验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    
    if(responseData){
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"lxm 请求成功后的数据:%@",dic);
        NSNumber *status=dic[@"status"];
        
        if (status.intValue == 0){
            NSLog(@"lxm 从服务端验证成功");
            
            NSDictionary *verifyResult = dic[@"verify_result"];
            NSNumber *subscribeStatus = verifyResult[@"subscribe_status"];
            
            if(subscribeStatus.intValue == 3 || subscribeStatus.intValue == 2){
                //关闭内购页面进入主题中心
                NSLog(@"lxm   完成购买 设置完成购买标记");
                [self.navigationController popViewControllerAnimated:YES];
                [kCMGroupDataManager setLastVerifyRIAPPDate:[NSDate date]];
                [kCMGroupDataManager setHasPurchasedIAP:YES];
            } else {
                [kCMGroupDataManager setHasPurchasedIAP:NO];
                self.alertView = [[CMCustomTipsAlert alloc] init];
                [self.alertView showAlertWithTitle:CMLocalizedString(@"restore_fail_title", nil) confirmText:CMLocalizedString(@"restore_fail_content", nil) buttonText:CMLocalizedString(@"OK", nil)];
                @weakify(self);
                self.alertView.confirmBlock = ^{
                    @stronglize(self);
                    [self confirmButtonClick];
                };
            }
        }
    }
}


//完成购买
- (void)completeTransactionWithTransaction:(SKPaymentTransaction *)transaction
{
    NSString * str=[[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSLog(@"lxm transaction = %@", str);
    
    NSMutableURLRequest* connectionRequest = [self verifyRequest];
    
    //开始请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:connectionRequest returningResponse:nil error:&error];
    if (error) {
        NSLog(@"lxm 验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    
    if(responseData){
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"lxm 请求成功后的数据:%@",dic);
        NSNumber *status=dic[@"status"];
        NSString *product = transaction.payment.productIdentifier;
        NSLog(@"lxm transaction.payment.productIdentifier++++ %@",product);
        
        if (status.intValue == 0){
            NSLog(@"lxm 从服务端验证成功");
            
            NSDictionary *verifyResult = dic[@"verify_result"];
            NSNumber *subscribeStatus = verifyResult[@"subscribe_status"];
            
            if(subscribeStatus.intValue == 3 || subscribeStatus.intValue == 2){
                //购买成功y上报埋点
                if ([product length] > 0)
                {
                    NSArray *tt = [product componentsSeparatedByString:@"."];
                    NSString *bookid = [tt lastObject];
                    if([bookid length] > 0){
                        [CMHostInfoc reportCheetahkeyboard_iapp:@"3" sku:bookid];
                    }
                }
                //关闭内购页面进入主题中心
                NSLog(@"lxm   完成购买 设置完成购买标记");
                [self.navigationController popViewControllerAnimated:YES];
                [kCMGroupDataManager setLastVerifyRIAPPDate:[NSDate date]];
                [kCMGroupDataManager setHasPurchasedIAP:YES];
            } else {
                [kCMGroupDataManager setHasPurchasedIAP:NO];
            }
        }
    }
}

//购买失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if([kCMGroupDataManager hasPurchasedIAP]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"lxm 购买失败");
    }else {
        NSLog(@"lxm 用户取消交易");
       }
}

    
@end



//
//  ViewController.m
//  TestApplePay
//
//  Created by FQL on 2018/11/15.
//  Copyright © 2018 FQL. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    //系统自带的Apple Pay 按键
    PKPaymentButton *payBtn = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    payBtn.frame = CGRectMake(100, 200, 100, 40);
    [payBtn addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
    
    
}



-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        return;
    }
    NSLog(@"+++ ApplePay");
    
//    [self pay];
    
}


- (void)pay {
    //判断是否支持Apple Pay
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        return;
    }
    // 创建商品 价格等
    NSDecimalNumber *firstAmount = [NSDecimalNumber decimalNumberWithString:@"1.11"];
    NSDecimalNumber *secondAmount = [NSDecimalNumber decimalNumberWithString:@"2.22"];
    NSDecimalNumber *thirdAmount = [NSDecimalNumber decimalNumberWithString:@"3.33"];
    
    NSDecimalNumber *amountSum = [NSDecimalNumber zero];
    amountSum = [amountSum decimalNumberByAdding:firstAmount];
    amountSum = [amountSum decimalNumberByAdding:secondAmount];
    amountSum = [amountSum decimalNumberByAdding:thirdAmount];
    

    PKPaymentSummaryItem *firstItem = [PKPaymentSummaryItem summaryItemWithLabel:@"FirstItem" amount:firstAmount];
    PKPaymentSummaryItem *secondItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Free" amount:secondAmount];
    PKPaymentSummaryItem *thirdItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Goods Pricce" amount:thirdAmount];
    
    PKPaymentSummaryItem *itemsSum = [PKPaymentSummaryItem summaryItemWithLabel:@"Total Money" amount:amountSum];
    
    
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    // 设置商户ID（merchant IDs）
    request.merchantIdentifier = @"merchant.com.zpj.ApplePayTest";
    // 设置国家代码(中国大陆)
    request.countryCode = @"CN";
//    request.supportedCountries  所有支持的国家代码
    
    // 设置支付货币(人民币)
    request.currencyCode = @"CNY";
    
    // 设置商户的支付标准(3DS支付方式必须支持，其他方式可选)
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.paymentSummaryItems = @[firstItem, secondItem, thirdItem, itemsSum];
    
    //选择卡片类型
    request.supportedNetworks = @[@"iD", @"MasterCard"];
    
    /**
     *  以上参数都是必须的
     *  以下参数不是必须的
     */
    
    // 设置账单、收据内容
    if (@available(iOS 11.0, *)) {
        //这里必须新添么？？
        request.requiredBillingContactFields = [NSSet setWithArray:@[PKContactFieldName, PKContactFieldPhoneNumber]];
    }else {
        request.requiredBillingAddressFields = PKAddressFieldAll;
    }


    // 设置送货内容
    if (@available(iOS 11.0, *)) {
        request.requiredShippingContactFields = [NSSet setWithArray:@[PKContactFieldEmailAddress, PKContactFieldPostalAddress]];
    }else {
        request.requiredShippingAddressFields = PKAddressFieldAll;
    }

    // 设置物流方式
    PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"阿敏" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
    method.identifier = @"阿敏物流";
    method.detail = @"12小时到达";
    PKShippingMethod *method2 = [PKShippingMethod summaryItemWithLabel:@"EMS" amount:[NSDecimalNumber decimalNumberWithString:@"6.00"] type:PKPaymentSummaryItemTypeFinal];
    method2.identifier = @"EMS Shipping";
    method2.detail = @"EveryWhere can go";
    request.shippingMethods = @[method, method2];
    
    
    
    
    PKPaymentAuthorizationViewController *paymentVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    paymentVC.delegate = self;
    
    if (paymentVC == nil) return;
    
    [self presentViewController:paymentVC animated:YES completion:nil];

}

#pragma mark - <PKPaymentAuthorizationViewControllerDelegate>
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    /**
     *  在这里支付信息应发送给服务器/第三方的SDK（银联SDK/易宝支付SDK/易智付SDK等）
     *  再根据服务器返回的支付成功与否进行不同处理
     *  这里直接返回支付成功
     */
    completion(PKPaymentAuthorizationStatusSuccess);
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    // 点击支付/取消按钮隐藏界面
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end

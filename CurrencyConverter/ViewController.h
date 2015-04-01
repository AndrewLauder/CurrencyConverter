//
//  ViewController.h
//  CurrencyConverter
//
//  Created by Andrew Lauder on 3/31/15.
//  Copyright (c) 2015 Andrew Lauder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate,NSURLConnectionDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, retain) NSString *sourceCurrency;
@property (nonatomic) double sourceCurrencyRate;
@property (weak, nonatomic) IBOutlet UITextField *sourceCurrencyValue;
@property (weak, nonatomic) IBOutlet UIButton *sourceCurrencyButton;

@property (strong, retain) NSString *targetCurrency;
@property (nonatomic) double targetCurrencyRate;
@property (weak, nonatomic) IBOutlet UITextField *targetCurrencyValue;
@property (weak, nonatomic) IBOutlet UIButton *targetCurrencyButton;

@property (strong, retain) NSMutableData *responseData;

@property (weak, nonatomic) IBOutlet UILabel *exchangeRateLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *currencyPickerToolbar;

@property (strong, retain) NSMutableArray *currencyNames;
@property (strong, retain) NSMutableArray *currencyValues;

@property (nonatomic) BOOL sourceCurrencySelected;

- (IBAction)changeSourceCurrency:(id)sender;
- (IBAction)changeTargetCurrency:(id)sender;
- (IBAction)getCurrencyRates:(id)sender;

@end


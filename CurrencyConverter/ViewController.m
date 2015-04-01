//
//  ViewController.m
//  CurrencyConverter
//
//  Created by Andrew Lauder on 3/31/15.
//  Copyright (c) 2015 Andrew Lauder. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _currencyNames = [[NSMutableArray alloc] init];
    _currencyValues = [[NSMutableArray alloc] init];
    [[self.sourceCurrencyButton layer] setBorderWidth:1.0f];
    [[self.sourceCurrencyButton layer] setBorderColor:[UIColor blueColor].CGColor];
    [self.sourceCurrencyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [[self.targetCurrencyButton layer] setBorderWidth:1.0f];
    [[self.targetCurrencyButton layer] setBorderColor:[UIColor blueColor].CGColor];
    [self.targetCurrencyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self getCurrencyRates];
    
    [self hidePicker];
    
    [_currencyPicker setDataSource:self];
    [_currencyPicker setDelegate:self];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    _sourceCurrencyValue.inputAccessoryView = numberToolbar;
    _targetCurrencyValue.inputAccessoryView = numberToolbar;
    
    [_sourceCurrencyValue setDelegate:self];
    [_targetCurrencyValue setDelegate:self];
}

- (void)cancelNumberPad
{
    [_sourceCurrencyValue endEditing:YES];
    [_targetCurrencyValue endEditing:YES];
}

- (void)doneWithNumberPad
{
    [_sourceCurrencyValue endEditing:YES];
    [_targetCurrencyValue endEditing:YES];
    if (_sourceCurrencySelected)
        [self computeTargetValue];
    else
        [self computeSourceValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSourceCurrency:(id)sender {
    NSLog(@"changeSourceCurrency");
    _sourceCurrencySelected = YES;
    [self showPicker];
}

- (IBAction)changeTargetCurrency:(id)sender {
    NSLog(@"changeTargetCurrency");
    _sourceCurrencySelected = NO;
    [self showPicker];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _sourceCurrencyValue)
        _sourceCurrencySelected = YES;
    else
        _sourceCurrencySelected = NO;

    return YES;
}

- (void)showPicker
{
    [_currencyPicker setHidden:NO];
}

- (void)hidePicker
{
    [_currencyPicker setHidden:YES];
}

- (void)computeSourceValue
{
    // Source = targetValue * targetRate * sourceRate
    double sourceValue = [[_targetCurrencyValue text] doubleValue] * _targetCurrencyRate * _sourceCurrencyRate;
    NSLog(@"_sourceCurrencyRate: %f", _sourceCurrencyRate);
    NSLog(@"_targetCurrencyRate: %f", _targetCurrencyRate);
    NSLog(@"_targetCurrencyValue: %@", _targetCurrencyValue.text);
    NSLog(@"computeSourceValue = %f", sourceValue);
    
    [_sourceCurrencyValue setText:[[NSNumber numberWithDouble:sourceValue] stringValue]];
}

- (void)computeTargetValue
{
    // Source = targetValue * targetRate * sourceRate
    double targetValue = [[_sourceCurrencyValue text] doubleValue] * _targetCurrencyRate * _sourceCurrencyRate;
    NSLog(@"_sourceCurrencyRate: %f", _sourceCurrencyRate);
    NSLog(@"_targetCurrencyRate: %f", _targetCurrencyRate);
    NSLog(@"_sourceCurrencyValue: %@", _targetCurrencyValue.text);
    NSLog(@"computeTargetValue = %f", targetValue);
    
    [_targetCurrencyValue setText:[[NSNumber numberWithDouble:targetValue] stringValue]];
}

#pragma mark -
#pragma mark NSURLConnection

- (IBAction)getCurrencyRates:(id)sender
{
    [self getCurrencyRates];
}

- (void)getCurrencyRates
{
    [_sourceCurrencyButton setTitle:@"Source Currency" forState:UIControlStateNormal];
    _sourceCurrencyValue.text = @"0.0";
    [_targetCurrencyButton setTitle:@"Target Currency" forState:UIControlStateNormal];
    _targetCurrencyValue.text = @"0.0";
    [_currencyNames removeAllObjects];
    [_currencyValues removeAllObjects];
    _responseData = [[NSMutableData alloc] init];
    NSString *url = @"https://openexchangerates.org/api/latest.json?app_id=899cbcdee19746b8876ed1d19c2ce31e";
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    [con start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    for (id key in [dic objectForKey:@"rates"]) {
        NSString *value = [[dic objectForKey:@"rates"] objectForKey:key];
        [_currencyNames addObject:key];
        [_currencyValues addObject:value];
    }

    NSLocale* locale = [NSLocale currentLocale];
    NSString* currencyName = [locale displayNameForKey:NSLocaleCurrencyCode
                                                 value:@"USD"];
    [_sourceCurrencyValue setText:@"1.0"];
    [_sourceCurrencyButton setTitle:currencyName forState:UIControlStateNormal];
    _sourceCurrencyRate = 1.0;

    currencyName = [locale displayNameForKey:NSLocaleCurrencyCode
                                       value:@"EUR"];
    [_targetCurrencyButton setTitle:currencyName forState:UIControlStateNormal];
    
    int currIndex = [_currencyNames indexOfObject:@"EUR"];
    NSNumber *currencyValue = [NSNumber numberWithDouble:[[_currencyValues objectAtIndex:currIndex] doubleValue]];
    [_targetCurrencyValue setText:[currencyValue stringValue]];
    _targetCurrencyRate = [currencyValue doubleValue];
    
    [_currencyPicker reloadAllComponents];
    
    [_exchangeRateLabel setText:[NSString stringWithFormat:@"%@ %@ = %@ %@",
                                @"1.0",
                                @"US Dollar",
                                [currencyValue stringValue],
                                 currencyName]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark UIPickerView

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _currencyNames.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLocale* locale = [NSLocale currentLocale];
    NSString* currencyName = [locale displayNameForKey:NSLocaleCurrencyCode
                                                 value:_currencyNames[row]];

    return currencyName;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLocale* locale = [NSLocale currentLocale];
    NSString* currencyName = [locale displayNameForKey:NSLocaleCurrencyCode
                                                 value:_currencyNames[row]];

    NSLog(@"didSelectRow: %@, %d, %d", currencyName, row, component);
    if (_sourceCurrencySelected)
    {
        _sourceCurrency = _currencyNames[row];
        [_sourceCurrencyButton setTitle:currencyName forState:UIControlStateNormal];
        _sourceCurrencyRate = [_currencyValues[row] doubleValue];
        [self computeSourceValue];
        [_exchangeRateLabel setText:[NSString stringWithFormat:@"%@ %@ = %@ %@",
                                     _sourceCurrencyValue.text,
                                     currencyName,
                                     _targetCurrencyValue.text,
                                     _targetCurrencyButton.titleLabel.text]];
    }
    else
    {
        _targetCurrency = _currencyNames[row];
        [_targetCurrencyButton setTitle:currencyName forState:UIControlStateNormal];
        _targetCurrencyRate = [_currencyValues[row] doubleValue];
        [self computeTargetValue];
        [_exchangeRateLabel setText:[NSString stringWithFormat:@"%@ %@ = %@ %@",
                                     _sourceCurrencyValue.text,
                                     _sourceCurrencyButton.titleLabel.text,
                                     _targetCurrencyValue.text,
                                     currencyName]];
    }
    [_currencyPicker setHidden:YES];
    
}

@end

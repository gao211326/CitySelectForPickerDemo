//
//  ShowPickerView.m
//  BaishitongClient
//
//  Created by 高磊 on 15/8/11.
//  Copyright (c) 2015年 高磊. All rights reserved.
//

#import "ShowPickerView.h"
#import "CityModel.h"
#import "DistrictModel.h"
#import "ProvinceModel.h"


//省为第一个
#define PROVINCE_COMPONENT  0
//市为第二个
#define CITY_COMPONENT      1
//区县第三个
#define DISTRICT_COMPONENT  2

#define UICOLOR_FROM_RGB_ALPHA(r,g,b,al)                [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:al]

#define UICOLOR_FROM_RGB_OxFF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define CURRFRAM_WIDTH                                  self.frame.size.width
#define CURRFRAM_HEIGTH                                 self.frame.size.height

@interface ShowPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>

//暗色背景
@property (nonatomic,strong) UIView *bgView;
//头部view 加有取消和确定按钮
@property (nonatomic,strong) UIView *headView;
//取消按钮
@property (nonatomic,strong) UIButton *cancelButton;
//确定按钮
@property (nonatomic,strong) UIButton *doneButton;

//选择器
@property (nonatomic ,strong) UIPickerView *cityPicker;

//省的数据源
@property (nonatomic,strong) NSMutableArray *provinceDatas;
//市的数据源
@property (nonatomic,strong) NSMutableArray *cityDatas;
//区的数据源
@property (nonatomic,strong) NSMutableArray *districtDatas;

//选择的地点拼接
@property (nonatomic,copy) NSString *chooseArea;
//选择对应的id
@property (nonatomic,copy) NSString *chooseId;

@end

@implementation ShowPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //初始化本地数据
        [self loadData];
        
        
        self.chooseArea = @"";
        self.chooseId = @"";
        
        self.backgroundColor = UICOLOR_FROM_RGB_ALPHA(0, 0, 0, 0.2);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel:)];
        tapGesture.delegate = (id)self;
        [self addGestureRecognizer:tapGesture];
        
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.headView];
        [self.headView addSubview:self.cancelButton];
        [self.headView addSubview:self.doneButton];
        [self.bgView addSubview:self.cityPicker];
    }
    return self;
}


- (void)loadData
{
    //默认数据加载 分别取第一个数据
    
    self.provinceDatas = [ProvinceModel provinceModels];
    
    ProvinceModel *provinceModel = self.provinceDatas[0];
    [self.cityDatas addObjectsFromArray:provinceModel.data];
    
    CityModel *cityModel = self.cityDatas[0];
    
    [self.districtDatas addObjectsFromArray:cityModel.data];
}


#pragma mark == event response
- (void)cancelButtonClick:(UIButton *)sender
{
    if (self.superview)
    {
        [self removeFromSuperview];
    }
}

- (void)doneButtonClick:(UIButton *)sender
{
    //获取所选中的index
    NSInteger provinceIndex = [self.cityPicker selectedRowInComponent: PROVINCE_COMPONENT];
    NSInteger cityIndex = [self.cityPicker selectedRowInComponent: CITY_COMPONENT];
    NSInteger districtIndex = [self.cityPicker selectedRowInComponent: DISTRICT_COMPONENT];
    
    ProvinceModel *provinceModel = [self.provinceDatas objectAtIndex:provinceIndex];
    CityModel *cityModel = [self.cityDatas objectAtIndex:cityIndex];
    
    DistrictModel *districtModel = nil;
    if (self.districtDatas.count > districtIndex)
    {
        districtModel = [self.districtDatas objectAtIndex:districtIndex];
    }
    
    //获取所选取的地区名字 和 id
    NSString *provinceStr = provinceModel.name;
    NSString *cityStr = cityModel.name;
    NSString *districtStr = districtModel.name;
    
    NSString *provinceId = provinceModel.s_id;
    NSString *cityId = cityModel.s_id;
    NSString *districtId = districtModel.s_id;
    
    if ([provinceStr isEqualToString: cityStr] && [cityStr isEqualToString: districtStr]) {
        cityStr = @"";
        districtStr = @"";
    }
    else if ([provinceStr isEqualToString: cityStr])
    {
        cityStr = @"";
        
        if (districtStr.length <= 0)
        {
            districtStr = @"";
        }
    }
    else if ([cityStr isEqualToString: districtStr])
    {
        districtStr = @"";
    }
    
    _chooseArea = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStr,districtStr];
    
    
    //取的是最后一个id  即有区就选区的id  有市则区取市的id
    
    if (districtId)
    {
        _chooseId = districtId;
    }
    else if (cityId)
    {
        _chooseId = cityId;
    }
    else if (provinceId)
    {
        _chooseId = provinceId;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showPickerViewDone:chooseId:)])
    {
        [self.delegate showPickerViewDone:_chooseArea chooseId:_chooseId];
    }
    if (self.superview)
    {
        [self removeFromSuperview];
    }
}

//手势点击
- (void)tappedCancel:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:self];
    //点击区域判断
    if (touchPoint.y > CURRFRAM_HEIGTH - 220)
    {
        return;
    }
    
    if (self.superview)
    {
        [self removeFromSuperview];
    }
}

#pragma mark == public method
- (void)showPicker
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

- (void)hiddenPicker
{
    if (self.superview)
    {
        [self removeFromSuperview];
    }
}


#pragma mark == UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//避免手势和按钮 等事件冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]] ||
        [touch.view isKindOfClass:[UIPickerView class]])
    {
        return NO;
    }
    return YES;
}


#pragma mark == UIPickerViewDataSource
//返回显示的列数 默认为3
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

//返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == PROVINCE_COMPONENT) {
        return [self.provinceDatas count];
    }
    else if (component == CITY_COMPONENT) {
        return [self.cityDatas count];
    }
    else {
        return [self.districtDatas count];
    }
}


#pragma mark == UIPickerViewDelegate
//设置当前行的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == PROVINCE_COMPONENT) {
        
        ProvinceModel *proviceModel = self.provinceDatas[row];
        
        return proviceModel.name;
    }
    else if (component == CITY_COMPONENT) {
        
        CityModel *cityModel = self.cityDatas[row];
        
        return cityModel.name;
    }
    else {
        DistrictModel *districtModel = self.districtDatas[row];
        
        return districtModel.name;
    }
}
//选择的行数
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == PROVINCE_COMPONENT) {
        
        [self.cityDatas removeAllObjects];
        
        //市
        ProvinceModel *provinceModel = self.provinceDatas[row];
        [self.cityDatas addObjectsFromArray:provinceModel.data];
        
        
        [self.districtDatas removeAllObjects];
        
        CityModel *cityModel = self.cityDatas[0];
        [self.districtDatas addObjectsFromArray:cityModel.data];
        
        //选择省后 市 、区县 分别滚动选择第一个
        [pickerView selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
        [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [pickerView reloadComponent: CITY_COMPONENT];
        [pickerView reloadComponent: DISTRICT_COMPONENT];
    }
    else if (component == CITY_COMPONENT){
        
        [self.districtDatas removeAllObjects];
        
        CityModel *cityModel = self.cityDatas[row];
        [self.districtDatas addObjectsFromArray:cityModel.data];
        
        [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [pickerView reloadComponent: DISTRICT_COMPONENT];
    }
}
//每行显示的文字样式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    if (component == PROVINCE_COMPONENT) {
        ProvinceModel *provinceModel = self.provinceDatas[row];
        titleLabel.text = provinceModel.name;
    }
    else if (component == CITY_COMPONENT) {
        CityModel *cityModel = self.cityDatas[row];
        titleLabel.text = cityModel.name;
    }
    else {
        DistrictModel *districtModel = self.districtDatas[row];
        titleLabel.text = districtModel.name;
    }
    return titleLabel;
}


#pragma mark == 懒加载

- (UIView *)bgView
{
    if (nil == _bgView)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, CURRFRAM_HEIGTH - 220, CURRFRAM_WIDTH, 220)];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIView *)headView
{
    if (nil == _headView)
    {
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CURRFRAM_WIDTH, 40)];
        _headView.backgroundColor = UICOLOR_FROM_RGB_OxFF(0xfed604);
    }
    return _headView;
}

- (UIButton *)cancelButton
{
    if (nil == _cancelButton)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setFrame:CGRectMake(0, 0, 60, 40)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UICOLOR_FROM_RGB_OxFF(0x6d4113) forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)doneButton
{
    if (nil == _doneButton)
    {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setFrame:CGRectMake(CGRectGetWidth(_headView.frame) - 60, 0, 60, 40)];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [_doneButton setTitleColor:UICOLOR_FROM_RGB_OxFF(0x6d4113) forState:UIControlStateNormal];
        [_doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_doneButton addTarget:self action:@selector(doneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIPickerView *)cityPicker
{
    if (nil == _cityPicker)
    {
        _cityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_headView.frame)  , CURRFRAM_WIDTH, CGRectGetHeight(self.bgView.frame) - CGRectGetMaxY(_headView.frame))];
        _cityPicker.delegate = self;
        _cityPicker.dataSource = self;
        _cityPicker.showsSelectionIndicator = YES;
        _cityPicker.backgroundColor = [UIColor whiteColor];
    }
    return _cityPicker;
}

- (NSMutableArray *)provinceDatas
{
    if (nil == _provinceDatas)
    {
        _provinceDatas = [[NSMutableArray alloc] init];
    }
    return _provinceDatas;
}

- (NSMutableArray *)cityDatas
{
    if (nil == _cityDatas)
    {
        _cityDatas = [[NSMutableArray alloc] init];
    }
    return _cityDatas;
}

- (NSMutableArray *)districtDatas
{
    if (nil == _districtDatas)
    {
        _districtDatas = [[NSMutableArray alloc] init];
    }
    return _districtDatas;
}

@end

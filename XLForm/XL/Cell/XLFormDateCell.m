//
//  XLFormDateCell.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Created by Martin Barreto on 31/3/14.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "XLForm.h"
#import "XLFormRowDescriptor.h"
#import "XLFormDateCell.h"


@interface XLFormDateCell()

@property (nonatomic) UIDatePicker *datePicker;

@end

@implementation XLFormDateCell
{
    UIColor * _beforeChangeColor;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.formDatePickerMode = XLFormDateDatePickerModeGetFromRowDescriptor;
    }
    return self;
}

- (UIView *)inputView
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime]){
        return self.datePicker;
    }
    return [super inputView];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canResignFirstResponder
{
    return YES;
}

-(BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    self.detailTextLabel.textColor = _beforeChangeColor;
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            XLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
            [formSection removeFormRow:nextFormRow];
        }
    }
    return [super resignFirstResponder];
}

#pragma mark - XLFormDescriptorCell

-(void)configure
{
    [super configure];
}

-(void)update
{
    [super update];
    
    self.accessoryType = self.rowDescriptor.disabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    [self.textLabel setText:self.rowDescriptor.title];
    self.textLabel.textColor  = self.rowDescriptor.disabled ? [UIColor grayColor] : [UIColor blackColor];
    self.selectionStyle = self.rowDescriptor.disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required ? @"*" : @""];
    self.detailTextLabel.text = [self valueDisplayText];
    UIFont * labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    UIFontDescriptor * fontDesc = [labelFont fontDescriptor];
    UIFontDescriptor * fontBoldDesc = [fontDesc fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    self.textLabel.font = [UIFont fontWithDescriptor:fontBoldDesc size:0];
    self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
    {
        NSIndexPath * selectedRowPath = [controller.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [controller.form formRowAtIndex:nextRowPath];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            [self resignFirstResponder];
        }
        else{
            [self becomeFirstResponder];
            _beforeChangeColor = self.detailTextLabel.textColor;
            self.detailTextLabel.textColor = self.formViewController.view.tintColor;
            XLFormSectionDescriptor * formSection = [controller.form.formSections objectAtIndex:nextRowPath.section];
            XLFormRowDescriptor * datePickerRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDatePicker];
            XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[datePickerRowDescriptor cellForFormController:controller];
            [self setModeToDatePicker:datePickerCell.datePicker];
            if (self.rowDescriptor.value){
                [datePickerCell.datePicker setDate:self.rowDescriptor.value];
            }
            [datePickerCell.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
            [formSection addFormRow:datePickerRowDescriptor afterRow:self.rowDescriptor];
        }
        [controller.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime])
    {
        [self becomeFirstResponder];
        [controller.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

-(BOOL)formDescriptorCellBecomeFirstResponder
{
    return YES;
}

#pragma mark - helpers

-(NSString *)valueDisplayText
{
    return self.rowDescriptor.value ? [self formattedDate:self.rowDescriptor.value] : self.rowDescriptor.noValueDisplayText;
}


- (NSString *)formattedDate:(NSDate *)date
{
    if (self.dateFormatter){
        return [self.dateFormatter stringFromDate:date];
    }
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    else if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline]){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

-(void)setModeToDatePicker:(UIDatePicker *)datePicker
{
    if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeDate){
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if ((([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime]) && self.formDatePickerMode == XLFormDateDatePickerModeGetFromRowDescriptor) || self.formDatePickerMode == XLFormDateDatePickerModeTime){
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
}

#pragma mark - Properties

-(UIDatePicker *)datePicker
{
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] init];
    [self setModeToDatePicker:_datePicker];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _datePicker;
}


#pragma mark - Target Action

- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    self.detailTextLabel.text = [self formattedDate:sender.date];
    self.rowDescriptor.value = sender.date;
    [self setNeedsLayout];
    
}

-(void)setFormDatePickerMode:(XLFormDateDatePickerMode)formDatePickerMode
{
    _formDatePickerMode = formDatePickerMode;
    if ([self isFirstResponder] ){
        if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTimeInline] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTimeInline])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
            XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
            if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
                XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[nextFormRow cellForFormController:self.formViewController];
                [self setModeToDatePicker:datePickerCell.datePicker];
            }
        }
    }
}

@end

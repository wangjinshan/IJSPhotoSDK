//
//  IJSRegexCategory.h
//  IJSFramework
//
//  Created by shange on 2017/4/16.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  正则表达式判断手机号邮箱等等
 */
@interface IJSFRegexCategory : NSString

/**
 *  正则表达式判断手机号,邮箱等等
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isMobileNumberJudgeObjc:(NSString *)objcName;
/**
 *  判断手机号是否有效
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isValidMobileNumberJudgeObjc:(NSString *)objcName;
/**
 *  判断邮箱
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isEmailAddressJudgeObjc:(NSString *)objcName;
/**
 *  判断身份证
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)simpleVerifyIdentityCardNumJudgeObjc:(NSString *)objcName;
/**
 *  判断车牌号
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */

- (BOOL)isCarNumberJudgeObjc:(NSString *)objcName;
/**
 *  判断mac地址
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isMacAddressJudgeObjc:(NSString *)objcName;
/**
 *  判断URL
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isValidUrlJudgeObjc:(NSString *)objcName;

/**
 *  判断数字，字母，下划线，-，.，中文组成的一个字串
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isValidChineseJudgeObjc:(NSString *)objcName;
/**
 *  判断邮政编码
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isValidPostalcodeJudgeObjc:(NSString *)objcName;
/**
 *  判断TaxNo
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isValidTaxNoJudgeObjc:(NSString *)objcName;
/**
 *  精确的身份证号码有效性检测
 *
 *  @param value 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;
/**
 *  判断银行卡有效性
 *
 *  @param backNumber 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)bankCardluhmCheck:(NSString *)backNumber;
/**
 *  判断IP
 *
 *  @param IP 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isIPAddressWithIP:(NSString *)IP;
/**
 *  判断负浮点数
 *
 *  @param number 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isNegativeFloat:(id)number;
/**
 *  判断正浮点数
 *
 *  @param number 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isPositiveFloat:(id)number;
/**
 *  判断非正数
 *
 *  @param number 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isNoPositiveFloat:(id)number;
/**
    *  判断非负数
    *
    *  @param number 用户输入的参数
    *
    *  @return 满足是1 不满足是0
    */
- (BOOL)isNoNegativeFloat:(id)number;
/**
 *  判断格式: 年-月-日
 *
 *  @param Date 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isSpecificDate:(id)Date;
/**
 *  判断腾讯QQ
 *
 *  @param QQ 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isTencentQQ:(id)QQ;
/**
 *  判断空白行
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */
- (BOOL)isBlankLine:(id)objcName;
/**
 *  判断待定
 *
 *  @param objcName 用户输入的参数
 *
 *  @return 满足是1 不满足是0
 */


@end

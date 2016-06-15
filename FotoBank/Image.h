//
//  Image.h
//  FotoBank
//
//  Created by DetroitLabs on 6/15/16.
//  Copyright © 2016 Srinivas Bodhanampati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Image : NSObject
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *caption;
@end

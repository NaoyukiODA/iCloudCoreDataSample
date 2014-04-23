//
//  ViewController.h
//  iCloudCoreDataSample
//
//  Created by Oda Naoyuki on 2014/04/23.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *bookNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (IBAction)pushSaveButton:(id)sender;
- (IBAction)pushFindButton:(id)sender;
- (IBAction)pushDeleteButton:(id)sender;
- (IBAction)countModelNum:(id)sender;


@end

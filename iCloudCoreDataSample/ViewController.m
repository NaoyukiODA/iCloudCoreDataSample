//
//  ViewController.m
//  iCloudCoreDataSample
//
//  Created by Oda Naoyuki on 2014/04/23.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushSaveButton:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *moContext = appDelegate.managedObjectContext;
    NSManagedObject *newBook;
    
    newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Books"
                                            inManagedObjectContext:moContext];
    [newBook setValue:self.bookNameTextField.text forKey:@"bookName"];
    [newBook setValue:self.authorNameTextField.text forKey:@"authorName"];
    
    self.bookNameTextField.text = @"";
    self.authorNameTextField.text = @"";
    
    NSError *error;
    
    [moContext save:&error];
    
}

- (IBAction)pushFindButton:(id)sender {
}

- (IBAction)pushDeleteButton:(id)sender {
}

- (IBAction)countModelNum:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *moContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Books"
                                                         inManagedObjectContext:moContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error;
    
    NSArray *allEntities = [moContext executeFetchRequest:fetchRequest error:&error];
    
    self.countLabel.text = [NSString stringWithFormat:@"%d", allEntities.count];
}
@end

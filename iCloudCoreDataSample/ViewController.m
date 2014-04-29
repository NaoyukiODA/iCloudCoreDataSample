//
//  ViewController.m
//  iCloudCoreDataSample
//
//  Created by Oda Naoyuki on 2014/04/23.
//  Copyright (c) 2014年 Oda Naoyuki. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "DataStore.h"

@interface ViewController ()

@property (retain, nonatomic) NSArray *entities;
@property (retain, nonatomic) NSSet *entitiesSet;
@property int index;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _index = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushSaveButton:(id)sender {
    DataStore *dataStore = [DataStore sharedInstance];
    
    NSManagedObjectContext *moContext = dataStore.managedObjectContext;
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
    DataStore *dataStore = [DataStore sharedInstance];
    
    NSManagedObjectContext *moContext = dataStore.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Books"
                                                         inManagedObjectContext:moContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"authorName contains %@", self.authorNameTextField.text];
    [fetchRequest setPredicate:pred];
    
    
    NSError *error = nil;
    _entities = [moContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject* obj in _entities) {
        NSString *bookName = [obj valueForKey:@"bookName"];
        NSString *authorName = [obj valueForKey:@"authorName"];
        NSLog(@" bookName = %@", bookName);
        NSLog(@" authorName = %@", authorName);
        NSLog(@" ManagedObject ID = %@", [obj objectID]);
        NSLog(@" object class = %@", NSStringFromClass([obj class]));
    }
    
    [self dispBookDataAtIndex:0];
}

- (IBAction)pushDeleteButton:(id)sender {
    DataStore *dataStore = [DataStore sharedInstance];
    
    NSManagedObjectContext *moContext = dataStore.managedObjectContext;
    
    NSError *error;
    [moContext deleteObject:_entities[_index]];
    [moContext save:&error];
}

- (IBAction)pushReadButton:(id)sender {
    DataStore *dataStore = [DataStore sharedInstance];
    
    NSManagedObjectContext *moContext = dataStore.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Books"
                                                         inManagedObjectContext:moContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    
    _entities = [moContext executeFetchRequest:fetchRequest error:&error];
    
    if(_entities != nil)
    {
        for (NSManagedObject* obj in _entities) {
            NSString *bookName = [obj valueForKey:@"bookName"];
            NSString *authorName = [obj valueForKey:@"authorName"];
            NSLog(@" bookName = %@", bookName);
            NSLog(@" authorName = %@", authorName);
            NSLog(@" ManagedObject ID = %@", [obj objectID]);
            NSLog(@" object class = %@", NSStringFromClass([obj class]));
        }

        self.countLabel.text = [NSString stringWithFormat:@"%lu entities", (unsigned long)_entities.count];
        [self dispBookDataAtIndex:_index];
    }
    NSLog(@"NSSet \n %@", [[dataStore.managedObjectContext registeredObjects] description]);
}

- (IBAction)pushPrevButton:(id)sender {
    if(_index > 0 && _entities != nil)
    {
        _index = _index - 1;
        [self dispBookDataAtIndex:_index];
    }
}

- (IBAction)pushNextButton:(id)sender {
    if(_entities != nil && _index < _entities.count - 1)
    {
        _index = _index + 1;
        [self dispBookDataAtIndex:_index];
    }
}

-(void)dispBookDataAtIndex:(int)index
{
    self.bookNameTextField.text = [_entities[_index] valueForKey:@"bookName"];
    self.authorNameTextField.text = [_entities[_index] valueForKey:@"authorName"];
}

@end

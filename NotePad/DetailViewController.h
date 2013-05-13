//
//  DetailViewController.h
//  NotePad
//
//  Created by Thomas Traylor on 5/9/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

//
//  DetailViewController.m
//  NotePad
//
//  Created by Thomas Traylor on 5/9/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//

#import "DetailViewController.h"
#import "Note+Create.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (void)configureView;
- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;

@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;
@synthesize note = _note;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Setter

- (void)setNote:(Note *)note
{
    if (_note != note)
    {
        _note = note;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"[%@ %@] context: %p", NSStringFromClass([self class]), NSStringFromSelector(_cmd), managedObjectContext);
    
    if(_managedObjectContext != managedObjectContext)
    {
        _managedObjectContext = managedObjectContext;
        
    }
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    // get the size of the keyboard so we can move the textview up to keep the
    // keyboard from hidding the test input.
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    CGRect rect = self.view.frame;
    rect.size.height -= kbSize.height;

}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - View

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.note)
    {
        if(self.note.text)
        {
            NSRange range = NSMakeRange(0, 10);
            NSString *title = [NSString stringWithFormat:@"%@...",[self.note.text substringWithRange:range]];
            
            self.navigationItem.title = title;
            self.textView.text = self.note.text;
            
        }
        else
        {
            self.navigationItem.title = @"";
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.textView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];

    [self configureView];
    [self registerForKeyboardNotifications];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITextViewDelegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if([self.textView.text length] < 10)
    {
        NSRange range;
        range = NSMakeRange(0, [self.textView.text length]);
        self.navigationItem.title = [NSString stringWithString:[self.textView.text substringWithRange:range]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"[%@ %@] text size: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [self.textView.text length]);
    NSLog(@"[%@ %@] context: %p", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.managedObjectContext);
    NSLog(@"[%@ %@] note: %p", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.note);
    
    if(self.managedObjectContext && self.note == nil &&  [self.textView.text length] > 0)
    {
        NSLog(@"[%@ %@] adding a new note", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        self.note = [Note noteWithText:self.textView.text inManagedObjectContext:self.managedObjectContext];
    }
    else
    {
        NSLog(@"[%@ %@] updating a new note", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        self.note.text = self.textView.text;
        self.note.timeStamp = [NSDate date];
    }
    
    [self.note.managedObjectContext save:nil];
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return YES;
}

#pragma mark - Done Button Pressed

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    //Keyboard dismiss
    [self.view endEditing:YES];
}


@end

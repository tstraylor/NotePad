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
        //_managedObjectContext = nil;
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
    
    _note = nil;
    self.textView.text = nil;
    self.navigationItem.title = @"";
    
    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
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
    // keyboard from hiding the test input.
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect rect = self.textView.frame;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        rect.size.height -= kbSize.height;
    }
    else if(UIInterfaceOrientationIsLandscape(orientation))
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        rect.size.height -= kbSize.width;
    }
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
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.note)
    {
        if(self.note.text)
        {
            NSRange cr = [self.note.text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
            if(cr.length != NSNotFound)
            {
                if(cr.location > 12)
                {
                    NSUInteger len = MIN([self.note.text length], 12);
                    NSRange range = NSMakeRange(0, len);
                    self.navigationItem.title = [NSString stringWithFormat:@"%@...",[self.note.text substringWithRange:range]];
                }
                else
                {
                    NSRange range = NSMakeRange(0, cr.location);
                    self.navigationItem.title = [self.note.text substringWithRange:range];
            
                }
            }
            else
            {
                NSUInteger len = MIN([self.note.text length], 12);
                NSRange range = NSMakeRange(0, len);
                self.navigationItem.title = [NSString stringWithFormat:@"%@...",[self.note.text substringWithRange:range]];
            }
        
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
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addANote:)];
    add.enabled = YES;
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    
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
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    barButtonItem.title = NSLocalizedString(@"Notes", @"Notes");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(doneButtonPressed:)];
    done.enabled = YES;
    [self.navigationItem setRightBarButtonItem:done animated:YES];

    //self.navigationItem.rightBarButtonItem = self.barButton;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if([self.textView.text length] < 12)
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
        
        if(![self.note.text isEqualToString:self.textView.text])
        {
            NSLog(@"[%@ %@] updating a new note", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            self.note.text = self.textView.text;
            self.note.timeStamp = [NSDate date];
        }
    }
    
    [self.note.managedObjectContext save:nil];
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return YES;
}

#pragma mark - UIBarButtonItem Action

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    //Keyboard dismiss
    [self.view endEditing:YES];
}

- (IBAction)addANote:(UIBarButtonItem *)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@end

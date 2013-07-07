//
//  DetailViewController.m
//  NotePad
//
//  Created by Thomas Traylor on 5/9/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
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

#import "DetailViewController.h"
#import "Note+Create.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIFont *noteFont;

- (void)configureView;
- (NSString *)makeTitle:(NSString*)text;

@end

@implementation DetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;
@synthesize note = _note;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize noteFont = _noteFont;

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
    
    if(self.splitViewController)
    {
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addANote:)];
        add.enabled = YES;
        [self.navigationItem setRightBarButtonItem:add animated:YES];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
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
    NSString *fontString = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontValue"];
    if([fontString isEqualToString:@"Marker Felt"])
    {
        self.noteFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:17.0];
    }
    else if([fontString isEqualToString:@"Noteworthy"])
    {
        self.noteFont = [UIFont fontWithName:@"Noteworthy-Light" size:17.0];
    }
    else
    {
        self.noteFont = [UIFont systemFontOfSize:17.0];
    }
    
    if (self.note)
    {
        if(self.note.text)
        {
            self.navigationItem.title = [self makeTitle:self.note.text];
            self.textView.text = self.note.text;
            self.textView.font = self.noteFont;
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

    self.view.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(222.0/255.0) blue:(2.0/255.0) alpha:1.0];
    
    NSString *fontString = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontValue"];
    if([fontString isEqualToString:@"Marker Felt"])
    {
        self.noteFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:17.0];
    }
    else if([fontString isEqualToString:@"Noteworthy"])
    {
        self.noteFont = [UIFont fontWithName:@"Noteworthy-Light" size:17.0];
    }
    else
    {
        self.noteFont = [UIFont systemFontOfSize:17.0];
    }

    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addANote:)];
    add.enabled = YES;
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    
    self.textView.delegate = self;
    self.textView.font = self.noteFont;
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

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    barButtonItem.title = NSLocalizedString(@"Notes", @"Notes");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc
          popoverController:(UIPopoverController *)pc
  willPresentViewController:(UIViewController *)aViewController
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
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"[%@ %@] text len: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [self.textView.text length]);

    // we want our title to be less then 12 characters.
    if([self.textView.text length] < 12)
    {
        NSLog(@"[%@ %@] text: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.textView.text);
        self.navigationItem.title = [self makeTitle:self.textView.text];
    }

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(self.managedObjectContext && self.note == nil &&  [self.textView.text length] > 0)
    {
        NSLog(@"[%@ %@] adding a new note", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        self.note = [Note noteWithText:self.textView.text inManagedObjectContext:self.managedObjectContext];
    }
    else
    {
        // we only want to update the note in the DB if there were changes to it.
        if(![self.note.text isEqualToString:self.textView.text])
        {
            NSLog(@"[%@ %@] updating a new note", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            self.note.text = self.textView.text;
            self.note.timeStamp = [NSDate date];
        }
    }
    
    [self.note.managedObjectContext save:nil];
    
    // now the we finished editing the note, switch the bar button back to "Add"
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addANote:)];
    add.enabled = YES;
    [self.navigationItem setRightBarButtonItem:add animated:YES];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.managedObjectContext = self.note.managedObjectContext;
}

#pragma mark - Title Method

// create the title for the note
- (NSString *)makeTitle:(NSString *)text
{
    NSString *title;
    NSRange cr = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if(cr.length != NSNotFound)
    {
        if(cr.location > 12)
        {
            NSUInteger len = MIN([text length], 12);
            NSRange range = NSMakeRange(0, len);
            title = [NSString stringWithFormat:@"%@...",[text substringWithRange:range]];
        }
        else
        {
            NSRange range = NSMakeRange(0, cr.location);
            title = [text substringWithRange:range];
        }
    }
    else
    {
        NSUInteger len = MIN([text length], 12);
        NSRange range = NSMakeRange(0, len);
        title = [NSString stringWithFormat:@"%@...",[text substringWithRange:range]];
    }
    
    return title;
}

@end

//
//  Note.h
//  NotePad
//
//  Created by Thomas Traylor on 5/10/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * text;

@end

//
//  PhotoCollectionViewController.m
//  FotoBank
//
//  Created by Srinivas Bodhanampati on 6/15/16.
//  Copyright © 2016 Srinivas Bodhanampati. All rights reserved.
//

#import "PhotoCollectionViewController.h"
#import "Firebase/Firebase.h"

@interface PhotoCollectionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) FIRStorage *firebaseStorage;
@property(strong, nonatomic) FIRStorageReference *fbStorageRef;
@property(strong, nonatomic) NSURL *downloadURL;

@end

@implementation PhotoCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    _firebaseStorage = [FIRStorage storage];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    _fbStorageRef = [_firebaseStorage referenceForURL:@"gs://project-7554510663044291640.appspot.com"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)cameraButtonSelected:(UIBarButtonItem *)sender {
    
    [self presentCamera];
}
- (void)hackyUpload{
    
    FIRStorageReference *imagesRef = [_fbStorageRef child:@"images/new.jpg"];
    
    NSURL *baseURL = [NSURL URLWithString:@"file:///Users/DetroitLabs/Documents/delta/classwork/FotoBank/FotoBank/Assets.xcassets/catgram.imageset/9903c7c14add3fd0758b7b5b80c24d48101f296f13ce34736799a82c71f61bc2.jpg"];
    NSLog(@"fileUrlwith path = %@", baseURL);
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    
    metadata.contentType = @"image/jpeg";
    //timestamp create
    NSDate *timestamp = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm-dd-yyyy  hh:ss"];
    NSString *stringFromDate = [formatter stringFromDate:timestamp];
    
    metadata.customMetadata = @{@"caption":@"LOOK AT THE CAT",@"time created":stringFromDate};
    // Upload file and metadata to the object 'images/mountains.jpg'
    FIRStorageUploadTask *uploadTask = [imagesRef putFile:baseURL metadata:metadata];
    
    // Listen for state changes, errors, and completion of the upload.
    [uploadTask observeStatus:FIRStorageTaskStatusResume handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload resumed, also fires when the upload starts
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusPause handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload paused
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload reported progress
        double percentComplete = 100.0 * (snapshot.progress.completedUnitCount) / (snapshot.progress.totalUnitCount);
    }];
    
    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
        // Upload completed successfully
        NSLog(@"Upload finished");
    }];
    
    // Errors only occur in the "Failure" case
    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error != nil) {
            switch (snapshot.error.code) {
                case FIRStorageErrorCodeObjectNotFound:
                    // File doesn't exist
                    break;
                    
                case FIRStorageErrorCodeUnauthorized:
                    // User doesn't have permission to access file
                    break;
                    
                case FIRStorageErrorCodeCancelled:
                    // User canceled the upload
                    break;
                    
                case FIRStorageErrorCodeUnknown:
                    // Unknown error occurred, inspect the server response
                    break;
            }
        }
    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)presentCamera {
#if TARGET_IPHONE_SIMULATOR
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:@"Camera is not available on simulator" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self hackyUpload];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
#elif TARGET_OS_IPHONE
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:_imagePicker animated:true completion:nil];
#endif
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    
    //upload image to firebase function called and passed the NSData we get back from taking photo with camera.
    [self uploadImageToFirebase:imageData];

    [self dismissViewControllerAnimated:true completion:nil];
    
}

//Function that takes an NSData object and then stores that in Firebase's Storage.
-(void)uploadImageToFirebase:(NSData *)imageData {
    FIRStorageReference *imagesRef = [_fbStorageRef child:@"images/newImage.jpg"];
    FIRStorageUploadTask *uploadTask = [imagesRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            NSLog(@"ERROR: %@", error.description);
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            _downloadURL = metadata.downloadURL;
        }
    }];
    [uploadTask resume];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    return cell;
}



#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

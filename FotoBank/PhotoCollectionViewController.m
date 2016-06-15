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

-(void)presentCamera {
#if TARGET_IPHONE_SIMULATOR
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:@"Camera is not available on simulator" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        /*
         
         do firebase actions with dummy data
         
         */
        
        [self dismissViewControllerAnimated:YES completion:nil];
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

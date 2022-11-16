## Image Thresholding.

#### Image processing using Assembly

The simplest thresholding methods replace each pixel in an image with a black pixel if the image intesity is less than a fixed value called the threshold, or a white pixel if the pixel intensity is greater than that threshold.

### Preview
##### Original Image

![Original Image](https://github.com/ryanviana/thresholding-in-assembly/blob/main/images/road100x100bin.jpg "Original Image").

##### The binary image resulting from a thresholding of the original image.

![Processed Image](https://github.com/ryanviana/thresholding-in-assembly/blob/main/images/road-100x100-limiar-version.jpgg "Processed Image").

### How to Run

##### Using MARS for Windows
 
1. Using MARS, open the prog.asm file.
2. Assemble the code using the Run button.
3. Again using the run button, click on the "Go" option.
4. Enter the threshold value using the I/O. There, you should enter an integer value from 0 to 256.
5. Check the created file in the _binaryFileName_ path.


##### How to change the image to be processed
To change the image to be used in the thresholding process you must set its path using the _fileName_ variable in the data section. In the same way, you must set the destiny path of the limiar version of the image using the _binaryFileName_, also in the data section.

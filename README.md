# Real time video processing

The idea was to create a real time video processing engine. The input would come from a camera and the output would be displayed via HDMI. Unfortunately I can't make the camera work, the input is some fixed drawings.

Read more at [albanesi.dev/videoprocessing](https://albanesi.dev/videoprocessing)

## Demo

In the gif, you can see the RGB input being transformed into a grayscale video. You can then see the result of the convolution with a sobel filter (with and without the grayscale video).

![demo](docs/result.gif)

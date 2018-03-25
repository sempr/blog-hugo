---
title: "Pillow给图片打水印透明度叠加问题"
date: 2017-06-18T16:12:16+08:00
---

博主在给图片打透明水印的时候，发现了一个很诡异的现象，明明透明度的设置是0.8，但处理完的图片的透明度和实际上css在网页上渲染出来的透明度用肉眼就能看得出来是完全不一样的两个透明度，一直很疑惑，后来看代码并且查看Pillow文档才发现了其中的玄机。

参看[Image.paste教程链接](http://pillow.readthedocs.io/en/4.1.x/reference/Image.html#PIL.Image.Image.paste)

其中是这么写的

```
Image.paste(im, box=None, mask=None)
Pastes another image into this image. The box argument is either a 2-tuple giving the upper left corner, a 4-tuple defining the left, upper, right, and lower pixel coordinate, or None (same as (0, 0)). If a 4-tuple is given, the size of the pasted image must match the size of the region.

If the modes don’t match, the pasted image is converted to the mode of this image (see the convert() method for details).
Instead of an image, the source can be a integer or tuple containing pixel values. The method then fills the region with the given color. When creating RGB images, you can also use color strings as supported by the ImageColor module.

If a mask is given, this method updates only the regions indicated by the mask. You can use either “1”, “L” or “RGBA” images (in the latter case, the alpha band is used as mask). Where the mask is 255, the given image is copied as is. Where the mask is 0, the current value is preserved. Intermediate values will mix the two images together, including their alpha channels if they have them.
```

重点其实是在这个mask参数的作用上，而我之前的代码是这样写的

```
image0.paste(image1, box=box, mask=image1)
```

而`image1`在往图上贴之前做过了透明度的处理，它的透明度是0.8，而同时mask也使用了这张图片，它的透明度也是0.8，这就直接导致了贴的时候，被贴图片的透明参数被mask又叠加了一遍，最终成了0.64的透明度，怪不得比实际上的透明度要淡那么多

那么既然知道了这个情况，那么解决方案也非常简单
```
image1_reduced = reduce_opacity(image1_original, 0.8)
image0.paste(image1_reduced, box=box, mask=image1_original)

```
像上面这样做 就可以把问题解决了

有些人会问，如果我把mask置空会怎么样，这个我也尝试过，如果被贴的图片本身有透明度信息的话，那部分区域会直接变成透明的，甚至把它下面的区域也透明掉 这个效果就没法接受了
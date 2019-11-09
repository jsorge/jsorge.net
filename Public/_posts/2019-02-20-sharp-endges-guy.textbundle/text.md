I never thought that I'd become "sharp edges guy" but the last couple of days at work I've run into doozies.

1. The `AVCaptureMetadataOutput.rectOfInterest` rectangle has to be transformed into the coordinate space of the output itself - meaning that you can't give it a `CGRect` from your view and have it work. Instead it must be converted to the coordinate space using `AVCaptureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect:)`.
2. When adding a custom view to a `UIBarButtonItem` you need to have that view handle the tap on the item itself. Assigning a `UIImageView`, for example, negates the bar button item's `target` and `action` properties for some reason. Of course it's not documented.

I wonder what I'll run into tomorrow 🙂

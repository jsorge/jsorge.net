Note to self: when animating `NSLayoutConstraint` properties, remember to call `layoutIfNeeded()` before the animation block _and inside_ the animation block. Otherwise the animation won't work.

Hopefully this saves future me some time.

#  Simple Video Viewer
Pet project for working with IP cameras.
To begin (and maybe finally) my APP works only with jpeg, with updates by timer

What is all this for.
I was looking for a free or inexpensive app for viewing cameras with minimal functionality:
- Lightweight. The application should open as quickly as possible, because the main task is to see what is happening around house in real time
- Without ads/logos/buttons and other menus. Only a grid of cameras
- The first picture from the camera should appear with minimal delay.

What I came to in the end.
Most applications are either proprietary or try to be multifunctional and with maximum support for all vendors. With autosearch (by the way, it works very poorly) and support record view.
Most app have a bunch of "designer" designs that require selecting camera
And most importantly, they all support the h265 codec, in which the i-frame "floats" and the picture does not appear immediately. Yes, a smooth video is cool, but I don't need it, updating 1 time/sec is more than enough.

In the end, I came to the conclusion that the easiest way is to get information with good old jpeg, it shows as quickly as possible and app doesnt need to pull third-party libraries to support rtsp with heavy codecs.

   

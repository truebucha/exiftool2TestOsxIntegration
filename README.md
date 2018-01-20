# exiftool2TestOsxIntegration

Test integration of exiftool library to Mac OSx application using c++ wrapper.
Source perl http://owl.phy.queensu.ca/~phil/exiftool/
The source of exiftool cpp library downloaded from http://owl.phy.queensu.ca/~phil/cpp_exiftool/

The main reason of this project was determination of xCode project settings to build with exiftool c++ daemon.
the test project reads exif data from bundled image using bridge ObjC++ file between c++ exiftool daemon library and other ObjC code. for swift projects you could add TextExiv file to your bridging-header to use it in swift also.

# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Qslim < Formula
  desc "Port of Michael Garland's QSlim to compile on Mac OS X"
  homepage "https://github.com/alecjacobson/qslim"
  url "https://github.com/alecjacobson/qslim/archive/refs/heads/master.zip"
  version "2.1"
  sha256 "40c1cdd91dacab60cd11c159973c095b4cf67c9886b71bfe5d983f3c3457306d"
  license "NOASSERTION"
  head "https://github.com/alecjacobson/qslim.git"

  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"

  patch :DATA

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    ENV.append "CXXFLAGS", "-framework OpenGL"

    cd "libgfx" do
      system "./configure", *std_configure_args, "--with-libtiff-lzw"
      cd "src" do
        system "make"
        system "#{ENV.cxx} -dynamiclib -install_name #{lib}/libgfx.2.dylib " \
               "-compatibility_version 2 -current_version 2.1 " \
               "-o libgfx.2.dylib -lpng -ljpeg -ltiff -framework OpenGL *.o"
        ln_s "libgfx.2.dylib", "libgfx.dylib"
      end
    end

    cd "mixkit" do
      system "./configure", *std_configure_args
      cd "src" do
        system "make", "GUI_SRCS="
        system "#{ENV.cxx} -dynamiclib -install_name #{lib}/libmix.2.dylib " \
               "-compatibility_version 2 -current_version 2.1 " \
               "-o libmix.2.dylib -framework OpenGL *.o ../../libgfx/src/libgfx.dylib"
        ln_s "libmix.2.dylib", "libmix.dylib"
      end
    end

    cd "tools/qslim" do
      system 'make qslim LDFLAGS="-L../../libgfx/src -L../../mixkit/src"'
    end

    (include/"gfx").install Dir["libgfx/include/gfx/*.h"]
    (include/"mixkit").install Dir["mixkit/src/*.h"]
    lib.install Dir["libgfx/src/libgfx*.dylib"]
    lib.install Dir["mixkit/src/libmix*.dylib"]
    bin.install Dir["tools/qslim/qslim"]
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test qslim`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
--- qslim-master/libgfx/src/raster-png.cxx.orig	2017-12-13 08:51:20.000000000 -0500
+++ qslim-master/libgfx/src/raster-png.cxx	2021-06-17 13:46:45.000000000 -0400
@@ -13,9 +13,7 @@
 #include <gfx/gfx.h>
 #include <gfx/raster.h>
 
-// Alec
-//#ifdef HAVE_LIBPNG
-#if false
+#ifdef HAVE_LIBPNG
 
 #include <png.h>
 
@@ -41,7 +39,7 @@ ByteRaster *read_png_image(const char *f
    // Because we didn't set up any error handlers, we need to be
    // prepared to handle longjmps out of the library on error
    // conditions.
-   if( setjmp(png_ptr->jmpbuf) )
+   if (setjmp(png_jmpbuf(png_ptr)))
    {
       png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
       fclose(fp);
@@ -131,7 +129,7 @@ bool write_png_image(const char *file_na
       return false;
    }
 
-   if( setjmp(png_ptr->jmpbuf) )
+   if (setjmp(png_jmpbuf(png_ptr)))
    {
       fclose(fp);
       png_destroy_write_struct(&png_ptr,  (png_infopp)NULL);
--- qslim-master/tools/qslim/Makefile.orig	2021-06-18 05:07:32.000000000 -0400
+++ qslim-master/tools/qslim/Makefile	2021-06-18 05:08:24.000000000 -0400
@@ -8,12 +8,10 @@ QVIS_OBJS = $(QVIS_SRCS:.cxx=.o)
 all: qslim qvis
 
 qslim : $(OBJS) ../../mixkit/src/libmix.a
-	$(CXX) -o qslim $(OBJS) $(LDFLAGS) $(LIBMIX) -lm -lfltk_gl
-# Alec ^
+	$(CXX) -o qslim $(OBJS) $(LDFLAGS) $(LIBMIX)
 
 qvis : $(QVIS_OBJS) ../../mixkit/src/libmix.a
 	$(CXX) -o qvis $(QVIS_OBJS) $(LDFLAGS) $(LIBMIX) $(GUI_LIBS) -lm -lfltk_gl
-# Alec ^
 	$(FLTKCONFIG) --post qvis
 
 clean:

class Libsx < Formula
  desc "X library to simplify making Xaw applications"
  homepage "ftp://ftp.ac-grenoble.fr/ge/Xlibraries"
  url "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libsx/2.08-5build1/libsx_2.08.orig.tar.xz"
  sha256 "178f4a111b7e4cf03771a5b3b4a87e0cb3bdf681bcfaef0019109ebf05baa964"
  license "GPL"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libx11"
  depends_on "libxaw3dxft"

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/libsx-rgb.diff"
    sha256 "7bcdbab14148106039fe89e40952459262991df4a8976cbfda261f4138e4c435"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/libsx-maxpathlen.diff"
    sha256 "5026ba9f69d5fe4f10e096a84a09e9b8fddeced67303ce2eaca4cbf411ca828e"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/fortify.patch"
    sha256 "86d790646f6586d609881709d169892d98ef095e117404df83e0d7bebfaef044"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/clang-fix.patch"
    sha256 "aacb58bacdbb86e7b69366d6ce0a80d21a68d9b3e83415952d7e9da3ee9f60f1"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/build-warnings.patch"
    sha256 "5ebc7c214f245405abb0403cd3f1ccab2cc20c8cd1372f316abfbb389d849b06"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/libsx/std23.patch"
    sha256 "639279907f10c9d6c9200caacc5dac02c352b832097c2a5dd9428120ee4d3878"
  end

  patch :DATA

  def install
    system "mv", "src/libsx.h", "src/libsx.h.in"
    system "autoreconf -fvi"
    system "./configure", *std_configure_args, "--disable-static"
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test libmatheval`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
diff -up libsx-2.08/configure.ac.orig libsx-2.08/configure.ac
--- libsx-2.08/configure.ac.orig	2025-03-12 10:33:08.745787474 -0400
+++ libsx-2.08/configure.ac	2025-03-12 10:34:29.254375391 -0400
@@ -8,7 +8,7 @@ AC_REVISION([$Id: configure.ac,v 1.8 200
 AC_CONFIG_HEADER([config.h])
 
 # soname version for libtool
-LIBSX_VERSION='0:0:0'
+LIBSX_VERSION='2:8:0'
 AC_SUBST(LIBSX_VERSION)
 
 # Checks for programs.
@@ -50,6 +50,7 @@ AC_CHECK_DECLS([strcasecmp, lstat, strdu
 AC_CONFIG_FILES([Makefile
 		 src/Makefile
 		 src/dialogs/Makefile
+                src/libsx.h
 		 freq/Makefile
 		 libsx.pc
 		])
diff -up libsx-2.08/src/Makefile.am.orig libsx-2.08/src/Makefile.am
--- libsx-2.08/src/Makefile.am.orig	2025-03-12 10:16:36.951101056 -0400
+++ libsx-2.08/src/Makefile.am	2025-03-12 10:31:27.310653068 -0400
@@ -8,13 +8,5 @@ libsx_la_SOURCES=button.c check_mark.h c
   font.c freq.c grabpix.c libsx.c libsx_private.h list.c\
   menu.c misc.c popups.c resize.c scrollbar.c string_entry.c toggle.c\
   version.c xstuff.h
-libsx_la_LDFLAGS = -version-info $(LIBSX_VERSION)
-
-CLEANFILES = libsx.a
-
-EXTRA_DIST = Makefile.no_auto
 
-all-local: libsx.a
-
-libsx.a: .libs/libsx.a
-	$(LN_S) $< libsx.a
+libsx_la_LDFLAGS = -version-info $(LIBSX_VERSION)
diff -up libsx-2.08/src/libsx.h.orig libsx-2.08/src/libsx.h
--- libsx-2.08/src/libsx.h.orig	2025-03-12 11:28:30.445683726 -0400
+++ libsx-2.08/src/libsx.h	2025-03-12 11:38:48.222483873 -0400
@@ -17,7 +17,7 @@

 #include <X11/Intrinsic.h>

-#define SX_SHAREDIR "/usr/share/libsx"
+#define SX_SHAREDIR "@prefix@/share/@PACKAGE@"

 /*
  * Predefined Args

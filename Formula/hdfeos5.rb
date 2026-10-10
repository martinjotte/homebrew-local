class Hdfeos5 < Formula
  desc "HDF-EOS library built on HDF5"
  homepage "https://hdfeos.org/software/library.php"
  url "https://git.earthdata.nasa.gov/projects/DAS/repos/hdfeos5/raw/hdf-eos5-2.0-src.tar.gz?at=refs%2Fheads%2FHDFEOS5_2.0"
  version "2.0"
  sha256 "d7c34770f0fe09fe5d255d73fd61aadd38278f423b925d1a5800e86aff17c82f"
  license "public-domain"

  depends_on "hdf5"
  depends_on "libaec"
  depends_on "gcc"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff"
    sha256 "83af02f2aa2b746bb7225872cab29a253264be49db0ecebb12f841562d9a2923"
  end

  patch :DATA

  def install
    ENV["FC"] = "gfortran"
    ENV["FCFLAGS"] = "-fallow-argument-mismatch"
    ENV["CPPFLAGS"] = "-Dunix -Df2cFortran -DMACINTEL"
    system "sed", "-i", "-e", "s|stddef|stdlib|", "configure"
    system "./configure", *std_configure_args, "--disable-silent-rules", "--with-szlib=#{Formula["libaec"].opt_prefix}", "--enable-shared", "--disable-static"
    system "make", "install", "libhe5_hdfeos_la_LIBADD=../gctp/src/libGctp.la" # if this fails, try separate make/make install steps
    include.install Dir["include/*.inc"]
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test hdfeos5`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

__END__
diff -up hdf-eos5-2.0/gctp/src/br_gctp.c.fort hdf-eos5-2.0/gctp/src/br_gctp.c
--- hdf-eos5-2.0/gctp/src/br_gctp.c.fort	2023-07-15 21:23:59.360193602 -0400
+++ hdf-eos5-2.0/gctp/src/br_gctp.c	2023-07-15 21:35:50.416733418 -0400
@@ -1,9 +1,13 @@
 
 #ifdef unix
+
+int gctp(double*, long*, long*, double*, long*, long*, long*, char*, long*, char*,
+         double*, long*, long*, double*, long*, long*, char*, char*, long*);
+
 /*  Fortran bridge routine for the UNIX */
 
 void gctp_(incoor,insys,inzone,inparm,inunit,indatum,ipr,efile,jpr,pfile,
-               outcoor, outsys,outzone,outparm,outunit,fn27,fn83,iflg)
+           outcoor,outsys,outzone,outparm,outunit,outdatum,fn27,fn83,iflg)
 
 double *incoor;
 long *insys;
@@ -20,12 +24,15 @@ long *outsys;
 long *outzone;
 double *outparm;
 long *outunit;
+long *outdatum;
+char *fn27;
+char *fn83;
 long *iflg;
 
 {
-gctp(incoor,insys,inzone,inparm,inunit,indatum,ipr,efile,jpr,pfile,outcoor,
-     outsys,outzone,outparm,outunit,fn27,fn83,iflg);
-
-return;
+  int i = gctp(incoor,insys,inzone,inparm,inunit,indatum,ipr,efile,jpr,pfile,
+               outcoor,outsys,outzone,outparm,outunit,outdatum,fn27,fn83,iflg);
+  
+  return;
 }
 #endif

class Gv < Formula
  desc "View and navigate through PostScript and PDF documents"
  homepage "https://www.gnu.org/s/gv/"
  url "https://ftpmirror.gnu.org/gnu/gv/gv-3.7.4.tar.gz"
  sha256 "2162b3b3a95481d3855b3c4e28f974617eef67824523e56e20b56f12fe201a61"

  depends_on "pkg-config" => :build
  depends_on "ghostscript"
  depends_on "libx11"

  skip_clean "share/gv/safe-gs-workdir"

  patch :DATA

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-SIGCHLD-fallback", 
                          "--disable-backing-pixmap", 
                          "--disable-scrollbar-code",
                          "--with-default-papersize=letter",
                          "--disable-setenv-code",
                          "ac_cv_lib_fl_yywrap=no"
    system "make", "install", "LC_ALL=C"
  end

  test do
    system "#{bin}/gv", "--version"
  end
end

__END__
diff -up gv-3.7.3/src/Makefile.in.x11alpha gv-3.7.3/src/Makefile.in
--- gv-3.7.3/src/Makefile.in.x11alpha	2012-10-11 21:42:28.000000000 -0400
+++ gv-3.7.3/src/Makefile.in	2012-10-11 21:45:19.000000000 -0400
@@ -1133,7 +1133,7 @@ gv_intern_res_unix.dat :
 	@echo "GV.gsCmdScanPDF:	gs -dNODISPLAY -dQUIET -sPDFname=%s -sDSCname=%s %s pdf2dsc.ps -c quit" >> gv_intern_res_unix.dat
 	@echo "GV.gsCmdConvPDF:	gs -dNOPAUSE -dQUIET -dBATCH -sDEVICE=pswrite -sOutputFile=%s -f %s -c save pop quit" >> gv_intern_res_unix.dat
 	@echo "GV.gsX11Device:		-sDEVICE=x11" >> gv_intern_res_unix.dat
-	@echo "GV.gsX11AlphaDevice:	-sDEVICE=x11 -dTextAlphaBits=4 -dGraphicsAlphaBits=2 -dMaxBitmap=10000000 -dNOPLATFONTS" >> gv_intern_res_unix.dat
+	@echo "GV.gsX11AlphaDevice:	-sDEVICE=x11alpha -dMaxBitmap=10000000 -dNOPLATFONTS" >> gv_intern_res_unix.dat
 	@echo "GV.gsSafeDir:		True" >> gv_intern_res_unix.dat
 	@echo "GV.gsSafer:		True" >> gv_intern_res_unix.dat
 	@echo "GV.gsQuiet:		True" >> gv_intern_res_unix.dat
 

class Vis5dx < Formula
  desc "Improved vis5d"
  homepage "http://sourceforge.net/projects/vis5d/"
  url "https://github.com/pseudotensor/Vis5dPlus/archive/refs/heads/master.zip"
  version "1.3.2"
  sha256 "d6197f427c224eb53f010d3fe0f4a7297933870adf751c111b51876e7572bf35"
  license "Permissive"

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-clang.patch"
    sha256 "1add8e0e5189b45f62fa4ddb08692d6a860c914ff77593898b478cc36214bd29"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-contourlabel.patch"
    sha256 "03a40d6ee1aae3fbfd0f4c95ebaecc8d6a08535bc754dde0c08a6bfb5388623b"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-darwinthreads.patch"
    sha256 "2b38bf5e6b294b4f4433ffd08ae981eba83269667d3dd07903f697bcd3500161"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-fortran.patch"
    sha256 "cb12cf5f1d2fed4abd75dd64339d7a6f74ee9d580cf141d4569ceb3dfbad74b0"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-iso_precision.patch"
    sha256 "b9016ae508432d3f923426fa7b690dd426d7a92fb0e4fe120f1956b67d759280"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-km.patch"
    sha256 "ac89414e8e58845df83ffc5b602a21677aa7213c17170b3d99ecab49a824e543"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-mix_to_qslim.patch"
    sha256 "58ec35c4e98d91001bb1f3fed90e24961d21dd152fd0b61d7a0dd5d3a6ec1c40"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-pkg_config.patch"
    sha256 "7820cb68df85606ecce1b41210edea54629cca71fcdf250503d972977b97d85a"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-round.patch"
    sha256 "1df110846fd636de49e54f9d374ceb0aba880076532ff55afb59731e86747d06"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-scale.patch"
    sha256 "2fa1956b799bd75769b31ebce540b8c26012f3e3591faa74c12ef4d600ba5d54"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-script.patch"
    sha256 "a5532bc4a90806c8672264f90a639582c953ab20532933b365a4b6335d459544"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-string.patch"
    sha256 "485c6494df06d24faa480f2f6ffcde4efdf67ccccaa6ed3de88180c4eef34f55"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-topo.patch"
    sha256 "81dc77196fed9adcb038501a320925c9f2e798519d5d58c9a4a513ccdebccdc3"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-topobottom.patch"
    sha256 "5ac30d567b1ee008815bf708421fda5cc6a346c73975a3ab1272e62fda628d8e"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-traject.patch"
    sha256 "99efe28646bc4aa904a6e4220562240647437d226c22e93931af4f3157fe0b6d"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-clang-fixes.patch"
    sha256 "c6dfc0d4221c7682634324f90b91f60521e10e16d8f73d40b938ec0d68553eb9"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-topo_undefs.patch"
    sha256 "983f549d12bdd97ce01f2bb8cc393c8f8fdb7caff211303bd29afcdeb4686279"
  end

  resource "gtk" do
    url "file:///Users/otte/Library/homebrew/vis5d/gtk.m4"
    sha256 "b984e4f01ecdc7b2cbae6e69ae061c269094bab1331eb557d9881858e504b122"
  end

  resource "gtkgl" do
    url "file:///Users/otte/Library/homebrew/vis5d/gtkgl.m4"
    sha256 "eb874618df6e3508a619090e5ed9ce5ebb7f039ff2b6ef3ab13650462366a5b2"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/vis5d/vis5d-lui5.patch"
    sha256 "57b655586d37534bf9a97b26c54980db1b5e871900b6a6e5b6b28aeef7a88909"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "gettext"
  depends_on "gcc"
  depends_on "libx11"
  depends_on "netcdf"
  depends_on "libpng"
# depends_on "imagemagick-full"
  depends_on "tcl-tk"
  depends_on "qslim"

  def install
    `find . -name CVS -exec rm -fr '{}' \+`

    (buildpath/"m4").install resource("gtk")
    (buildpath/"m4").install resource("gtkgl")

    ENV.append "CFLAGS", "-Wno-error=implicit-function-declaration"
    ENV.append "CFLAGS", "-Wno-error=implicit-int"
    ENV.append "CFLAGS", "-Wno-error=int-conversion"
    ENV.append "CFLAGS", "-Wno-error=incompatible-function-pointer-types"

    system "autoreconf -fvi"
    system "./configure", *std_configure_args, "--disable-silent-rules", "--disable-static", 
           "--with-netcdf", "--enable-threads", "--with-mixkit=/usr/local/lib/libmix.dylib", 
           "FC=gfortran", "FFLAGS=-O3 -march=native -fallow-invalid-boz -fallow-argument-mismatch -fno-range-check", "ac_cv_prog_cc_c23=no"
    system "make", "install", "V=1" # if this fails, try separate make/make install steps

    pkgshare.install "convert"
    pkgshare.install "scripts"
    pkgshare.install "userfuncs"
    (pkgshare/"util").install Dir["util/*.c"]
    (pkgshare/"util").install Dir["util/*.f"]
    (pkgshare/"util").install "util/Makefile"
    pkgshare.install "contrib"
    (pkgshare/"example").install "hole.v5d"
    (include/"vis5d+").install "src/vis5d.h"
    doc.install "doc/vis5d.pdf"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test vis5d+`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

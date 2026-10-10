class Grads2 < Formula
  desc "Tool for plotting gridded data sets"
  homepage "http://cola.gmu.edu/grads"
  url "https://github.com/j-m-adams/GrADS/archive/refs/tags/v2.2.3.tar.gz"
  sha256 "2cbb67284fe64763c589ecaf08d5bd31144554dfd82a1fccf71e1cc424695a9e"
  license "GPLv2"
  version "2.2.3"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/grads/grads-2.2.0-gsgui.patch"
    sha256 "abddd38c712a921c91f67c155befa94b6a0a9ff774f93fe82658bc406e7a8bdc"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/grads/grads-2.2.0-paths.patch"
    sha256 "18cc57bd3889f8ea7f8ebbd2c3dd6c57baa83781c89fe13dc8f9c282a9b3471f"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/grads/grads-2.2.0-undefined.patch"
    sha256 "94ec797748ba6dcececbba55f9d18bbb903e9038888e9e31078c1cbfa0e7e3d1"
  end

  patch :p0 do
    url "file:///Users/otte/Library/homebrew/grads/grads-2.2.1-new_g2c.patch"
    sha256 "fdf286496d46b86483b8c93f0312273bc49c2ade9fe20e56eab9ed1d3a8ef741"
  end

  patch :p0 do
    url "file:///Users/otte/Library/homebrew/grads/grads-2.2.1-solib.patch"
    sha256 "d9fac3cc2d404642b425103e85740211b93a95c2dbb4e54426c8cba33f4fd876"
  end

  depends_on "pkgconf" => :build
  depends_on "readline"
  depends_on "g2clib"
  depends_on "jasper"
  depends_on "hdf5"
  depends_on "netcdf"
  depends_on "libgeotiff"
  depends_on "libtiff"
  depends_on "shapelib"
  depends_on "libsx"
  depends_on "libx11"
  depends_on "udunits"
  depends_on "libpng"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "cairo"
  depends_on "gd"


  resource "scripts" do
    url "file:///Users/otte/Library/homebrew/grads/scripts.tgz"
    sha256 "3efb4c18fcd549da5e89977763d267aa651e927c8d8a4891bdb9bfa67135d218"
  end

  resource "examples" do
    url "file:///Users/otte/Library/homebrew/grads/example.tar.gz"
    sha256 "1d744696d3f5722b755786da7bc1b87c2217734a2848643dce20660ebe7a5723"
  end

  resource "gadoc" do
    url "file:///Users/otte/Library/homebrew/grads/gadoc151.pdf"
    sha256 "37d18f9b5b6d098c3432a623b04122c90813a076d8c6fdad67b84d9ef5eff592"
  end

  resource "udpt" do
    url "file:///Users/otte/Library/homebrew/grads/udpt"
    sha256 "f868f392968bcb03c1335eb4159d03d4c72a1294c8aec1399bc13cfc86dbf380"
  end

  resource "panels" do
    url "file:///Users/otte/Library/homebrew/grads/panels.gs"
    sha256 "ce676570c47da3b19a5446e1ca6c37db43ea16409f1ab264860a6ae4a2b15495"
  end
    
  def install
    inreplace "configure", "png15", "png"

    ENV.append "CFLAGS", "-O3 -march=native -fveclib=Accelerate -DH5_USE_110_API"
    ENV.append "CXXFLAGS", "-O3 -march=native -fveclib=Accelerate -DH5_USE_110_API"
    ENV.append "LDFLAGS", "-framework Accelerate -Wl,-dead_strip_dylibs"

    system "pkg-config", "--exists", "--print-errors", "--debug", "cairo"

    system "./configure", *std_configure_args, "--with-x",
           "--with-geotiff=#{formula_opt_prefix("readline")}", 
           "--with-shp=#{formula_opt_prefix("shapelib")}",
           "--with-udunits2=#{formula_opt_prefix("udunits2")}",
           "LIBS=-L#{formula_opt_lib("libx11")}", 
           "CPPFLAGS=-I#{formula_opt_include("cairo")}/cairo -I#{formula_opt_include("freetype")}/freetype2 -I#{formula_opt_include("libx11")}"
    system 'make install SUPPLIBS=/usr/local gui_libs="-lsx -lXext -lXaw -lXpm -lXmu -lXt" LIBS=-ludunits2'

    pkgshare.install Dir["data/*"]
    pkgshare.install resource("udpt")
    (pkgshare/"scripts").install resource("scripts")
    (pkgshare/"scripts").install resource("panels")

    doc.install resource("examples")
    doc.install resource("gadoc")
    doc.install Dir["doc/*.pdf"]

    (lib/"grads").install Dir["#{lib}/*.so"]
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

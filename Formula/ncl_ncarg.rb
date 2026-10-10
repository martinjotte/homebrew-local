class NclNcarg < Formula
  desc "NCAR Command Language and NCAR Graphics"
  homepage "http://www.ncl.ucar.edu"
  version "6.6.2"
  url "file:///Users/otte/Library/homebrew/ncl/ncl_ncarg-6.6.2.tar.gz"
# url "https://www.earthsystemgrid.org/dataset/ncl.662.src/file/ncl_ncarg-6.6.2.tar.gz"
  sha256 "403fbb4bda631b8de2573c926ee7f4adcf6a6c735570c7fa2f7c154e221de9aa"
  license "BSD"

  depends_on "libx11"
  depends_on "libxaw3dxft"
  depends_on "cairo"
  depends_on "freetype"
  depends_on "g2clib"
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "hdfeos5"
  depends_on "netcdf"
  depends_on "libpng"
  depends_on "jpeg-turbo"
  depends_on "udunits"
  depends_on "vis5d+"
  depends_on "openblas"
  depends_on "proj"
  depends_on "gcc"
  depends_on "imake"  => :build
  depends_on "makedepend"  => :build
  depends_on "flex"  => :build

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncarg-4.4.1-deps.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.1.0-blas.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.0.0-build_n_scripts.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.1.0-includes.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.2.1-udunits.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-ncarg_darwin.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncarg_dont_search_install.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-ncl_darwin.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.1.0-use_build-dylibs.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.0.0-uoffset.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.4.0-ifort_strings.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.4.0-ifort_strings2.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-use_gcc_cpp_for_ymake.diff"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_ncarg-6.4.0-strlen.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.4.0-dup_ngpath.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-parbuild.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.0.0-no_install_dep.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-5.1.0-netcdff.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-gfort_flagged.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-xlfixes.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-boz.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-format.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_darwin_config_gfortran.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_no_udunits1.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_sed.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/wmap_noundef.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-proj8.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-cgm_seek.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-more_undefs.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-no-implicit-int.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-no-nc_set_log_level.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-hdf_4.3.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-fastswap.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-gbytes.patch"
  end

# patch do
#   url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-ctrans_darwin_hack.patch"
# end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-idt_features.patch"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-ymake.patch"
    sha256 "50b492801af7c8f6d6f3dd2ff1ac407bb9b2e9100ab812c1c2707022ecd133b1"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_ncarg-6.6.2-gcc_flagged.patch"
    sha256 "2a0b3dccbcc7389c29a4120436f3ad4d1b358badc481483483ef2da3563d186f"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_ncarg-6.6.2-gcc_flagged2.patch"
    sha256 "cb6c208122109e912352fc3b74ad136220655e4b99ca7dccb98091ceef25e99e"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/ncl/ncl_ncarg-6.6.2-gcc_flagged3.patch"
    sha256 "891201de604308d5d9fca88eea6ed5f887d6e8c2747c1b1806943a66040c12d3"
  end

  resource "Site.local" do
    url "file:///Users/otte/Library/homebrew/ncl/Site.local"
  end

  resource "Triangle" do
#   url "http://www.netlib.org/voronoi/triangle.zip"
    url "file:///Users/otte/Library/homebrew/ncl/triangle.zip"
  end

  resource "FixTriangle" do
    url "file:///Users/otte/Library/homebrew/ncl/ncl-6.6.2-fixtri.patch"
  end

  def install
    ENV.append "CFLAGS", "-fveclib=Darwin_libsystem_m -DH5_USE_110_API -I#{formula_opt_include("freetype")}/freetype2"

    (buildpath/"config").install resource("Site.local")
    system "sed -i -e 's;@prefix@;#{prefix};' config/Site.local"
    system "sed -i -e 's;@mandir@;#{man};' config/Site.local"

    (buildpath/"triangle").install resource("Triangle")
    (buildpath/"triangle").install resource("FixTriangle")
    mv "triangle/triangle.c", "ni/src/lib/hlu/"
    mv "triangle/triangle.h", "ni/src/lib/hlu/"
    system "patch", "-p1", "-i", "triangle/ncl-6.6.2-fixtri.patch"

    rm_rf "external/blas"
    rm_rf "external/lapack"

    system "touch -f ncarview/src/bin/ictrans/Copyright"

    ENV["LIBRARY_PATH"] = "/usr/local/lib"

    system "./config/ymkmf"
    system "make", "All", "COPT=#{ENV.cflags} -O3 -march=native -lsvml", "FOPT=-O3 -march=native -funsafe-math-optimizations -mveclibabi=svml -lsvml"

    ENV["NCARG"] = buildpath
    system "make", "install"

    rm_rf lib/"ncarg/udunits"
    rm_rf lib/"ncarg/grib2_codetables.previous"
    rm_rf lib/"libnclapi.dylib"

    rm_f Dir["#{lib}/*.a"]
    ln_sf "libncl.dylib", "#{lib}/libnclapi.dylib"

    inreplace Dir["#{bin}/{ncargcc,ncargf77,ncargf90,nhlcc,nhlf77,nhlf90}"] do |s|
      s.gsub!(/loadflags *=.*/, 'loadflags = "-Wl,-ld_classic -Wl,-commons -Wl,use_dylibs"')
    end

    inreplace Dir["#{bin}/{ncargcc,ncargf77,ncargf90}"] do |s|
      s.gsub!(/libextra *=.*/, 'libextra = ""')
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test ncl`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end

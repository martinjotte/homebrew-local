class Wgrib2 < Formula
  desc "Manipulate, inventory and decode GRIB2 files"
  homepage "http://www.cpc.ncep.noaa.gov/products/wesley/"
  url "https://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2_nolib.tgz.v3.1.3"
  sha256 "79ee6e3aa15f90cc1a03ece9ba8ade7ded11017ede09ff658ea7b3b3e077801c"
  license "Public domain"
  version "3.1.3"

  depends_on "libaec"
  depends_on "libomp"
  depends_on "netcdf"
  depends_on "jasper"
  depends_on "libpng"

  patch :p0 do
    url "file:///Users/otte/Library/homebrew/wgrib2/wgrib2-3.1.1-newjasper.patch"
    sha256 "8b69598a4f1660b87b2b05ba6e3ce8fedf8f1f3487d8db296f0e7395ed7195e0"
  end

  patch :p0 do
    url "file:///Users/otte/Library/homebrew/wgrib2/wgrib2-3.1.3-jasper3.patch"
    sha256 "b98c2bcb9ebb7ebdf0acbdaa5cc58c737d6ae8d3f003aca39450dac23e2850f8"
  end

  resource "config_h" do
    url "file:///Users/otte/Library/homebrew/wgrib2/config.h"
    sha256 "02a8b983eab82e25d59d023a2d543453f86d9b09afe79829473467525f9380a5"
  end

  resource "gctpc" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/grib2/gctpc20a.tgz"
    sha256 "49d00aa93806efabdc309e22e3d6f62fe76701080eeda83a032244eeebda7342"
  end

  resource "g2ctl" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/g2ctl/g2ctl"
  end

  resource "tricks" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/tricks.wgrib2"
  end

  def install
    (buildpath/"wgrib2").install resource("config_h")
    (buildpath/"gctpc").install resource("gctpc")

    inreplace Dir["wgrib2/{Config.c,Ncpu.c,Timer.c,openmp_util.c,simple_pk.c,unpk_0.c,unpk_complex.c,wgrib2.h}"], "USE_OPENMP", "_OPENMP"

    cd "gctpc/source" do
      system "make", "CFLAGS=-O3 -march=native -Wno-error=implicit-int"
    end

    cd "wgrib2" do
      system "touch", "fnlist.c", "fnlist.h"
      system "make", "CFLAGS=-I../gctpc/source -O3 -march=native -Xpreprocessor -fopenmp -fveclib=Accelerate", 
             "LDFLAGS=-L../gctpc/source -lgeo -ljasper -lpng -lnetcdf -lz -laec -lomp -framework Accelerate"
      bin.install "wgrib2"
      doc.install Dir["*.txt"]
    end

    bin.install resource("g2ctl")
    doc.install resource("tricks")
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

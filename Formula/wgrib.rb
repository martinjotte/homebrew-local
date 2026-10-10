class Wgrib < Formula
  desc "Manipulate, inventory and decode GRIB files"
  homepage "http://www.cpc.ncep.noaa.gov/products/wesley/"
  url "https://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar.v1.8.5"
  sha256 "f1746afdb7d627f546a333f7a548694003bbc042202fdffb646a5e584ad38884"
  license "Public domain"
  version "1.8.5"

  patch :p0 do
    url "file:///Users/otte/Library/homebrew/wgrib/wgrib-stdout_from_rams.patch"
    sha256 "29cd5e13ab5c889d6a7e934b85b1ef7afb6a61ac628f6f5d9a5ae0a94863738a"
  end

  resource "grib2ctl" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib.scripts/grib2ctl.pl"
  end

  resource "doc1" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib.scripts/grib2grads.txt"
  end

  resource "doc2" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib.scripts/grib2ctl.txt"
  end

  resource "doc3" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/grib2ieee.txt"
  end

  resource "doc4" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/readme"
  end

  resource "doc5" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/tricks.wgrib"
  end

  resource "doc6" do
    url "http://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/usertables.txt"
  end

  def install
    inreplace "makefile", "-O2", "$(CFLAGS)"
    ENV.append "CFLAGS", "-O3 -march=native"
    system 'make'
    bin.install "wgrib"
    doc.install "Changes"

    bin.install resource("grib2ctl")
    inreplace "#{bin}/grib2ctl.pl", "/usr/local/lib/grads", "/usr/local/share/grads2"
    File.rename "#{bin}/grib2ctl.pl", "#{bin}/grib2ctl"

    doc.install resource("doc1")
    doc.install resource("doc2")
    doc.install resource("doc3")
    doc.install resource("doc4")
    doc.install resource("doc5")
    doc.install resource("doc6")
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

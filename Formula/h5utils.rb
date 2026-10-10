class H5utils < Formula
  desc "Utilities to work with scientific data in HDF5"
  homepage "https://github.com/NanoComp/h5utils"
  url "https://github.com/NanoComp/h5utils/releases/download/1.13.3/h5utils-1.13.3.tar.gz"
  sha256 "ae96b2f2c6d1782ae51773efd5bed47c3ccadc74ef471b1a25f91b1d90d539ee"

  depends_on "hdf5"
  depends_on "libpng"
  depends_on "hdf4"
  depends_on "vis5d+"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-octave"
    system "make", "install"
  end

  test do
    system bin/"h5fromtxt", "-h"
  end
end

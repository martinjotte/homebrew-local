class Gnudatalanguage < Formula
  desc "Free and open-source IDL/PV-WAVE compiler"
  homepage "https://gnudatalanguage.github.io"
  url "https://github.com/gnudatalanguage/gdl/releases/download/v1.1.3/gdl-v1.1.3.tar.gz"
  sha256 "7f2b39cec13d7589e7d810ca2197ffb080f80d3de0de440a8cba26e21cadf8a1"

  depends_on "cmake" => :build
  depends_on "cairo"
  depends_on "eigen"
  depends_on "fftw"
  depends_on "freetype"
  depends_on "imagemagick-full"
  depends_on "gsl"
  depends_on "libpng"
  depends_on "netcdf"
  depends_on "hdf5"
  depends_on "readline"
  depends_on "udunits"
  depends_on "wxwidgets"
  depends_on "libgeotiff"
  depends_on "libtiff"
  depends_on "proj"
  depends_on "eccodes"
  depends_on "glpk"
  depends_on "shapelib"
  depends_on "jpeg-turbo"
  depends_on "libomp"
  depends_on "qhull"
  depends_on "ncurses"

  depends_on "python@3.15"
  depends_on "hdf4"
  uses_from_macos "expat"

  patch do
    url "https://github.com/gnudatalanguage/gdl/commit/ef2d0aecabcd41cad9156316a8b43a50fbda926a.patch?full_index=1"
  end

  patch do
    url "https://github.com/gnudatalanguage/gdl/commit/cafb0dd26dbf9764ce44ccc3da207ac1198b10c5.patch?full_index=1"
    sha256 "d2184a243bc4a6409b5bf8597d7a7b92e6896768acbbdc4d7604f36e9b5706ec"
  end

  patch do
    url "https://github.com/gnudatalanguage/gdl/commit/681d0983704d4558e320d158f618381694601998.patch?full_index=1"
    sha256 "e89bf1f0b5773440b5bfde8b4cc40dacf6c1c85eadc9557ea7f1abbd7c291212"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/gdl/gdl-1.1.3-pthick.patch"
    sha256 "5edacf26e06e800598cc8b1e0718157ed574dbd4006488fb74b61712a3e8721e"
  end

  patch do
    url "file:///Users/otte/Library/homebrew/gdl/gdl-1.1.3-hdf4.patch"
    sha256 "c1352d28e14c94d955331506ca77902fa6ddd69b1c0145aa2004ff12362e4646"
  end

  patch do
    url "https://github.com/gnudatalanguage/gdl/pull/2226.patch?full_index=1"
  end

  def install
    ENV.append "LDFLAGS", "-L#{Formula["libomp"].opt_lib} -lomp"

    mkdir "build" do
      args = std_cmake_args
      args << "-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DNDEBUG"
      args << "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      args << "-DCMAKE_DISABLE_FIND_PACKAGE_MPI=TRUE"
      args << "-DX11=OFF"
      args << "-DGRAPHICSMAGICK=OFF"
      args << "-DPLD_xwin=OFF"
      args << "-DMPI=OFF"
      args << "-DREADLINEDIR=#{formula_opt_prefix("readline")}"
      args << "-DOpenMP_CXX_FLAGS=-Xpreprocessor -fopenmp -I#{formula_opt_include("libomp")}"
      system "cmake", "..", *args
      system "make"

      # The following tests FAILED:
      #    80 - test_execute.pro (Failed)
      #    84 - test_fft_leak.pro (Failed)
      #   108 - test_image_statistics.pro (Failed)
      #   128 - test_obj_isa.pro (Failed)
      # Reported 3 Feb 2017 https://sourceforge.net/p/gnudatalanguage/bugs/716/
      # system "make", "check"

      system "make", "install"
    end
  end

  test do
    system "#{bin}/gdl", "--version"
  end
end

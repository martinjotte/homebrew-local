class Hdf4 < Formula
  desc "HDF version 4"
  homepage "https://www.hdfgroup.org"
  url "https://github.com/HDFGroup/hdf4/releases/download/hdf4.4.0/hdf4.4.0.tar.gz"
  sha256 "f69afb6362529c606f05fb4c95279316497c68bea9ed7794683b31544163e286"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "jpeg-turbo"
  depends_on "libaec"
  depends_on "gcc"

  # redefine library name to "df" from "hdf".  this seems to be an artifact
  # of using cmake that needs to be corrected for compatibility with
  # anything depending on hdf4.
  patch :DATA

  def install
    ENV["FC"] = "gfortran"

    args = std_cmake_args
    args.concat [
      "-DBUILD_SHARED_LIBS=ON",
      "-DBUILD_STATIC_LIBS=OFF",
      "-DBUILD_TESTING=OFF",
      "-DHDF4_BUILD_TOOLS=ON",
      "-DHDF4_BUILD_UTILS=ON",
      "-DHDF4_BUILD_FORTRAN=ON",
      "-DHDF4_BUILD_WITH_INSTALL_NAME=ON",
      "-DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON",
      "-DHDF4_ENABLE_NETCDF=OFF", # Conflict. Just install NetCDF for this.
      "-DHDF4_ENABLE_SZIP_ENCODING=ON",
      "-DHDF4_ENABLE_SZIP_SUPPORT=ON",
      "-DHDF4_ENABLE_Z_LIB_SUPPORT=ON"
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    mkdir_p lib/"cmake"
    mv prefix/"cmake", lib/"cmake/hdf4"

    mv prefix/"share", prefix/"hdf4"
    mkdir_p share
    mv prefix/"hdf4", share/"hdf4"
  end

  def caveats
    <<~EOS
      HDF4 has been superseeded by HDF5.  However, the API changed
      substantially and some programs still require the HDF4 libraries in order
      to function.
    EOS
  end
end

__END__
diff -up hdf4.4.0/CMakeLists.txt.orig hdf4.4.0/CMakeLists.txt
--- hdf4.4.0/CMakeLists.txt.orig	2026-10-01 13:24:26.601588541 -0400
+++ hdf4.4.0/CMakeLists.txt	2026-10-01 13:24:28.691398569 -0400
@@ -170,7 +170,7 @@ mark_as_advanced (HDF4_NO_PACKAGES)
 # for targets, BASE_CORE
 # filename are made of PREFIX_BASE_INFIX_CORE_SUFFIX
 #-----------------------------------------------------------------------------
-set (HDF4_LIB_BASE              "hdf")
+set (HDF4_LIB_BASE              "df")
 set (HDF4_LIB_SYM_BASE          "df")
 set (HDF4_MFLIB_BASE            "mfhdf")
 

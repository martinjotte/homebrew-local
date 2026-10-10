class G2clib < Formula
  desc "GRIB2 encoder/decoder"
  homepage "https://github.com/NOAA-EMC/NCEPLIBS-g2c"
  url "https://github.com/NOAA-EMC/NCEPLIBS-g2c/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "8520a24c066500cfd0d07a05c6b7b0cb92383d1a4737cf6e79d9f4919c8e79ab"
  license "Permissive"

  depends_on "jasper"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "cmake" => :build

  patch do
    url "file:///Users/otte/Library/homebrew/g2clib/g2clib-allow_neg_lon.patch"
    sha256 "9124ad8d51df90b6bbb00bfcc4632fdc02bd851a122f1a4b370d32f4ab557c50"
  end

  patch :DATA

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_STATIC_LIBS=OFF
      -DUSE_AEC=ON 
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
 
    lib.install_symlink shared_library("libg2c") => shared_library("libgrib2c")
    include.install "src/grib2_int.h"
  end

  test do
    chdir "build" do
      system "make", "test"
    end
  end

end

__END__
diff -up NCEPLIBS-g2c-2.3.0/src/CMakeLists.txt.orig NCEPLIBS-g2c-2.3.0/src/CMakeLists.txt
--- NCEPLIBS-g2c-2.3.0/src/CMakeLists.txt.orig	2025-11-04 15:08:49.000000000 -0500
+++ NCEPLIBS-g2c-2.3.0/src/CMakeLists.txt	2026-02-24 18:02:24.342421154 -0500
@@ -46,7 +46,8 @@ if(BUILD_SHARED_LIBS)
   add_library(${lib_name}_shared SHARED $<TARGET_OBJECTS:${lib_name}_objlib>)
   set_target_properties(${lib_name}_shared PROPERTIES OUTPUT_NAME ${lib_name})
   set_target_properties(${lib_name}_shared PROPERTIES EXPORT_NAME ${lib_name})
-  set_target_properties(${lib_name}_shared PROPERTIES SOVERSION 0)
+  set_target_properties(${lib_name}_shared PROPERTIES VERSION 2.3.0)
+  set_target_properties(${lib_name}_shared PROPERTIES SOVERSION 1)
   list(APPEND LIB_TARGETS ${lib_name}_shared)
 endif()
 

class Bacio < Formula
  desc "NCEP model I/O library"
  homepage "https://github.com/NOAA-EMC/NCEPLIBS-bacio"
  url "https://github.com/NOAA-EMC/NCEPLIBS-bacio/archive/refs/tags/v2.5.0.tar.gz"
  sha256 "540a0ed73941d70dbf5d7b21d5d0a441e76fad2bfe37dfdfea0db3e98fc0fbfb"
  license "Permissive"

  depends_on "gcc"
  depends_on "cmake" => :build

  patch :DATA

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DBUILD_SHARED_LIBS=ON" << ".."
      ENV["FC"] = "gfortran"
      ENV["FFLAGS"] = "-O3 -march=native"
      system "cmake", *args
      system "make", "install"
      include.install Dir["src/*templates.h"]
    end
  end

  test do
    chdir "build" do
      system "make", "test"
    end
  end

end

__END__

diff -up NCEPLIBS-bacio-2.5.0/src/CMakeLists.txt.orig NCEPLIBS-bacio-2.5.0/src/CMakeLists.txt
--- NCEPLIBS-bacio-2.5.0/src/CMakeLists.txt.orig	2022-01-14 14:21:43.000000000 -0500
+++ NCEPLIBS-bacio-2.5.0/src/CMakeLists.txt	2022-01-14 14:37:22.000000000 -0500
@@ -47,7 +47,7 @@ set_target_properties(${lib_name}_f PROP
 
 add_library(${lib_name}_c OBJECT ${c_src})
 
-add_library(${lib_name} STATIC $<TARGET_OBJECTS:${lib_name}_f>
+add_library(${lib_name} $<TARGET_OBJECTS:${lib_name}_f>
   $<TARGET_OBJECTS:${lib_name}_c>)
 target_include_directories(${lib_name} INTERFACE
   $<BUILD_INTERFACE:${module_dir}>
@@ -55,6 +55,9 @@ target_include_directories(${lib_name} I
 list(APPEND LIB_TARGETS ${lib_name})
 install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})
 
+set_target_properties(${lib_name} PROPERTIES VERSION 2.5.0)
+set_target_properties(${lib_name} PROPERTIES SOVERSION 2 )
+
 install(
   TARGETS ${LIB_TARGETS}
   EXPORT ${PROJECT_NAME}Exports

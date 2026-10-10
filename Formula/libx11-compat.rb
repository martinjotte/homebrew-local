class Libx11Compat < Formula
  desc "Xlib layered on top of SDL2/SDL3"
  homepage "https://github.com/sysprog21/libx11-compat/"
  license "MIT"
  url "https://github.com/sysprog21/libx11-compat.git", branch: "main"
  version "1.0"

  depends_on "sdl3"
  depends_on "sdl3_ttf"
  depends_on "pixman"

  patch do
    url "file:///Users/otte/Library/homebrew/libx11-compat/libx11-compat-darwin.patch"
    sha256 "a3defa2ae3405f6a5858d108d416641730dbd78256a0c695498c607a2e4ba48d"
  end

  resource "Xpoll.h" do
    url "file:///Users/otte/Library/homebrew/libx11-compat/Xpoll.h"
    sha256 "c2376cc5eacb6f23a10fb57439b2381fb95dfec9b078127d1d3568150bb47c62"
  end

  keg_only "conflicts with libx11"

  def install
    ENV.deparallelize  # if your formula fails when building in parallel

    (buildpath/"include/X11").install resource("Xpoll.h")
    system "make", "prefix=#{HOMEBREW_PREFIX}/opt/libx11-compat", "V=1"

    lib.install Dir["build/*.dylib"]

    lib.install_symlink shared_library("libICE-compat") => shared_library("libICE")
    lib.install_symlink shared_library("libSM-compat") => shared_library("libSM")
    lib.install_symlink shared_library("libX11-compat") => shared_library("libX11")
    lib.install_symlink shared_library("libXaw-compat") => shared_library("libXaw")
    lib.install_symlink shared_library("libXaw-compat") => shared_library("libXaw7")
    lib.install_symlink shared_library("libXext-compat") => shared_library("libXext")
    lib.install_symlink shared_library("libXft-compat") => shared_library("libXft")
    lib.install_symlink shared_library("libXinerama-compat") => shared_library("libXinerama")
    lib.install_symlink shared_library("libXmu-compat") => shared_library("libXmu")
    lib.install_symlink shared_library("libXpm-compat") => shared_library("libXpm")
    lib.install_symlink shared_library("libXt-compat") => shared_library("libXt")

    include.install "include/X11"
    include.install "include/fontconfig"
    (include/"X11").install Dir["build/upstream/include/X11/{*.h,PM,Xaw,dri,fonts}"]
    (include/"X11/Xmu").install Dir["build/upstream/include/X11/Xmu/*"]
    (include/"X11/extensions").install Dir["build/upstream/include/X11/extensions/*"]

    (lib/"pkgconfig").install Dir["build/pkgconfig/*"]
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

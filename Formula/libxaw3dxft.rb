class Libxaw3dxft < Formula
  desc "X.Org: 3D Athena widget set based on the Xt library with FreeType support"
  homepage "https://github.com/DaveFlater/libXaw3dXft"
  url "https://github.com/DaveFlater/libXaw3dXft/releases/download/v1.6.4/libxaw3dxft-1.6.4.tar.xz"
  sha256 "283d2d1c9332ae2c51b54228eb82b89737b1c94d9cf5d0bd15cc26863a5feff6"
  license "MIT"

  depends_on "pkgconf" => :build
  depends_on "util-macros" => :build
  depends_on "libx11"
  depends_on "freetype"
  depends_on "fontconfig"

  patch do
    url "https://github.com/DaveFlater/libXaw3dXft/commit/5c37eae41fe976d4c2f33e238100cad4e37fffc4.patch?full_index=1"
    sha256 "6faa9cc45e95d9f3b22a09513c5bdf290e53d1384eb3b5503adf74677eefac8e"
  end

  def install
    args = %W[
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-silent-rules
      --disable-static
      --enable-gray-stipples
      --enable-arrow-scrollbars
      --enable-multiplane-bitmaps
      --enable-internationalization
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <X11/Xaw3d/Label.h>
      int main() { printf("%d", sizeof(LabelWidget)); }
    C
    system ENV.cc, "test.c", "-o", "test"
    output = shell_output("./test").chomp
    assert_match "8", output
  end
end

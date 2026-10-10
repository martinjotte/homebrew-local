class SshfsMac < Formula
  desc "File system client based on SSH File Transfer Protocol"
  homepage "https://github.com/libfuse/sshfs"
  url "https://github.com/libfuse/sshfs/archive/refs/heads/master.tar.gz"
  sha256 "50ca492044e6a749cdf3db41692a0c567e74f5b25fd07386a6c0e0e77465ad45"
  license any_of: ["LGPL-2.1-only", "GPL-2.0-only"]
  version "3.7.3"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "docutils" => :build
  depends_on "glib"
  depends_on "libfuse3"

  patch :DATA

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system bin/"sshfs", "--version"
  end
end

__END__
diff -up sshfs-master/utils/install_helper.sh.orig sshfs-master/utils/install_helper.sh
--- sshfs-master/utils/install_helper.sh.orig	2025-03-14 14:51:48.567403074 -0400
+++ sshfs-master/utils/install_helper.sh	2025-03-14 14:52:27.219774798 -0400
@@ -10,10 +10,10 @@ bindir="$2"
 sbindir="$1"
 prefix="${MESON_INSTALL_DESTDIR_PREFIX}"

-mkdir -p "${prefix}/${sbindir}"
+#mkdir -p "${prefix}/${sbindir}"

-ln -svf --relative "${prefix}/${bindir}/sshfs" \
-   "${prefix}/${sbindir}/mount.sshfs"
+#ln -svf --relative "${prefix}/${bindir}/sshfs" \
+#   "${prefix}/${sbindir}/mount.sshfs"

-ln -svf --relative "${prefix}/${bindir}/sshfs" \
-   "${prefix}/${sbindir}/mount.fuse.sshfs"
+#ln -svf --relative "${prefix}/${bindir}/sshfs" \
+#   "${prefix}/${sbindir}/mount.fuse.sshfs"

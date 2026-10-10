class Applesauce < Formula
  desc "Transparent compression for Apple File System Compression"
  homepage "https://github.com/Dr-Emann/applesauce"
  url "https://github.com/Dr-Emann/applesauce/releases/download/applesauce-cli-v0.5.30/source.tar.gz"
  sha256 "c315164c2dad86c0708577e377e58c25aca9ebbf23f2fafe1c0ebb229054d8ae"
  license "GPL=3.0"

  depends_on "rust" => :build
  depends_on "cmake" => :build

  def install
    system "cargo", "build", "--release"
    bin.install "target/release/applesauce"
  end

end

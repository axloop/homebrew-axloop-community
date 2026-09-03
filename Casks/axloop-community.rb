cask "axloop-community" do
  version "0.1.0"
  sha256 "27e993467ee3b57c891c416ab5963032020b38218f2c57d890f094f791ca2043"

  url "https://github.com/axloop/axloop-community/releases/download/v0.1.0/axloop-community-darwin-arm64-3a7bfeeb.tar.gz"
  name "AxLoop Community"
  desc "Community edition of AxLoop"
  homepage "https://github.com/axloop/axloop-community"

  depends_on arch: :arm64

  binary "bin/axloop-community"
end

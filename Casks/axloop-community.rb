cask "axloop-community" do
  version "0.2.0"
  sha256 "10d11fcb6cf0a22abacdb6a1425dff8ca180a7a6fd86b5496abdd6ea1b911648"

  url "https://github.com/axloop/axloop-community/releases/download/v0.2.0/axloop-community-darwin-arm64-2fcd9d7.tar.gz"
  name "AxLoop Community"
  desc "Community edition of AxLoop"
  homepage "https://github.com/axloop/axloop-community"

  depends_on arch: :arm64

  binary "bin/axloop-community"
  binary "bin/axloop-community", target: "axloop-crawler"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]
  end
end

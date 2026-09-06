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

  caveats <<~EOS
    Open AxLoop Community:
      axloop-crawler open

    In the browser, click "Run first scan". Keep Terminal running while using
    the interface; press Ctrl-C when finished. Reopen with the same command.
    Your scan history stays on this Mac. No hosted account is required.

    This is an Apple Silicon Mac preview. Clean-machine acceptance is pending.
  EOS

  postflight_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{staged_path}}"]
  end
end

cask "annotate" do
  version "0.2.0"
  sha256 "edb26c3d7bd976ec3f4395b39978bc6de18508182da822268b00bfe560bdb586"

  url "https://github.com/kairyu/annotate/releases/download/v#{version}/Annotate-v#{version}.zip",
      verified: "github.com/kairyu/annotate/"
  name "Annotate"
  desc "Lets an AI agent draw hand-drawn annotations on your screen"
  homepage "https://github.com/kairyu/annotate"

  livecheck do
    url "https://github.com/kairyu/annotate.git"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  # The deployment target. A bare symbol means "this or newer" to Homebrew.
  depends_on macos: :sonoma

  app "Annotate.app"

  uninstall quit: "me.kairyu.annotate"

  zap trash: [
    "~/Library/Application Support/Annotate",
    "~/Library/Preferences/me.kairyu.annotate.plist",
  ]

  caveats <<~EOS
    Annotate needs the Accessibility permission to locate controls on screen.
    macOS asks on first launch; it is under System Settings > Privacy & Security.

    The MCP server ships inside the app. Point your agent at:
      #{appdir}/Annotate.app/Contents/MacOS/annotate-mcp
  EOS
end

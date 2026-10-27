cask "anyway-connect" do
  version "1.0.1"
  sha256 "da77214024d1805248483142c919adf7e868fd7183a9831e02d79c62c7b23fd3"

  url "https://github.com/kairyu/anyway-connect/releases/download/v#{version}/AnywayConnect-v#{version}.zip",
      verified: "github.com/kairyu/anyway-connect/"
  name "AnywayConnect"
  desc "Menu bar client for OpenConnect-compatible SSL VPNs"
  homepage "https://github.com/kairyu/anyway-connect"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app drives an external openconnect binary; without one it launches but cannot
  # connect. vpnc-script comes from the same formula, along with thirteen transitive
  # dependencies of its own — gnutls, p11-kit, ca-certificates and so on — which is why
  # those appear in the dependency tree without being named here.
  #
  # xmlstarlet is needed by openconnect's *own* libexec/openconnect/csd-post.sh, which
  # this app runs for gateways that demand a posture check. The openconnect formula does
  # not declare it, so without this the script prints "xmlstarlet not found in path; CSD
  # token extraction may not work" to stderr and the connect fails for reasons the user
  # never sees. It is a leaf formula with no dependencies, so declaring it is cheap
  # insurance against an obscure failure on the one code path that needs it.
  depends_on formula: "openconnect"
  depends_on formula: "xmlstarlet"
  depends_on macos: :ventura

  app "AnywayConnect.app"

  # Order and alphabetisation are what `brew style` enforces: launchctl before quit,
  # deletions last and sorted. The daemon is unregistered before the app is asked to
  # quit, and the root-owned paths are removed with it — dragging the app to the Trash
  # would leave a registered root daemon and a sudoers rule behind.
  uninstall launchctl: "me.kairyu.anywayconnect.privhelper",
            quit:      "me.kairyu.anywayconnect",
            delete:    [
              "/etc/sudoers.d/anyway-connect",
              "/usr/local/libexec/anyway-connect",
              "/usr/local/sbin/anyway-root-helper.sh",
            ]

  zap trash: [
    "~/.config/anyway-connect",
    "~/Library/Preferences/me.kairyu.anywayconnect.plist",
  ]

  caveats <<~EOS
    AnywayConnect needs root to create the tunnel interface and edit the routing
    table. Open Settings > General > Privileged helper > Install and approve the
    background item when macOS asks. Until then, each connect prompts for sudo.

    To remove the privileged helper before uninstalling, use Remove in that same
    pane — it unregisters the daemon the way macOS expects.
  EOS
end

-- WirePlumber ALSA configuration
-- Set default audio profile for laptop speakers (AMD Ryzen HD Audio)
-- Copy this file to: ~/.config/wireplumber/main.lua.d/51-alsa-config.lua

alsa_monitor.rules = {
  {
    matches = {
      {
        { "node.name", "matches", "alsa_output.pci-0000_06_00.6.*" },
      },
    },
    apply_properties = {
      ["node.default"] = true,
    },
  },
  {
    matches = {
      {
        { "device.name", "matches", "alsa_card.pci-0000_06_00.6" },
      },
    },
    apply_properties = {
      ["api.alsa.profile"] = "output:analog-stereo+input:analog-stereo",
    },
  },
}

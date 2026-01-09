# Dotfiles

These are my dotfiles.

## Compatibility

Works with neovim 0.11

## Getting Neovim running on a new Mac

- Install the [Homebrew](https://brew.sh) package manager.
- Neovim's colorschemes rely on 24 bit color working in the terminal.
  - Default MacOS terminal doesn't do 24 bit color.  Download
    [iTerm2](https://iterm2.com/downloads.html) and use it instead of default Terminal
  - Diagnosis: run [24-bit-color.sh](https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh)
    and if 24 bit color works you will see 8 bands of continuously graduated color
- Some of neovim's fancy visual effects in neovim rely on specific fonts.
  - Download and install JetBrains Mono Nerd Font from
    [Nerd Fonts](https://www.nerdfonts.com/font-downloads) which contains
    combined fonts including both JetBrains Mono and FontAwesome glyphs.
  - Configure iTerm2 to use "JetBrains Mono Nerd Font Mono" "Regular" "13"
    as the default profile's text font.
  - Configure iTerm2 to use "JetBrains Mono Nerd Font Mono" "Regular" "18"
    as the default profile's "Non-ASCII Font".  Note this is the same
    font but in a larger size to compensate for the icons being too small.
- Install the following Homebrew packages:
  - `nvim`
  - `pyright`
  - `jdtls`

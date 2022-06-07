FROM docker.io/library/archlinux

# Install paru build dependencies.
RUN pacman --sync --needed --refresh --noconfirm \
      base-devel \
      cargo \
      git \
      sudo

# Create a build user to build paru and install packages.
RUN sed --in-place '/NOPASSWD/s/^# //' /etc/sudoers
RUN useradd --create-home --groups wheel build
USER build
WORKDIR /home/build

# Download the paru source, build it, and install it.
RUN git clone https://aur.archlinux.org/paru.git \
 && cd paru \
 && makepkg --syncdeps --install --noconfirm \
 && cd ../ \
 && rm --recursive --force paru

# Install all of the packages for the development environment.
RUN paru --sync --needed --noconfirm \
      bat \
      buildah \
      direnv \
      docker-compose \
      entr \
      exa \
      fd \
      gnu-free-fonts \
      htop \
      kitty \
      lazygit \
      mako \
      moreutils \
      neovim \
      novnc \
      nvm \
      otf-font-awesome \
      pipewire-jack \
      podman \
      podman-dnsname \
      polkit \
      procs \
      qt5-wayland \
      qutebrowser \
      ripgrep \
      sd \
      skopeo \
      starship \
      stow \
      sway \
      sway-launcher-desktop \
      tmux \
      tokei \
      ttc-iosevka \
      ttf-nerd-fonts-symbols \
      waybar \
      wayvnc \
      wireplumber \
      wl-clipboard \
      zoxide \
      zsh

USER root
WORKDIR /
ENV XDG_RUNTIME_DIR=/tmp/xdg \
    SWAYSOCK=/tmp/sway.sock \
    WLR_BACKENDS=headless \
    WLR_LIBINPUT_NO_DEVICES=1 \
    LIBGL_ALWAYS_SOFTWARE=1 \
    XDG_CURRENT_DESKTOP=sway \
    QT_QPA_PLATFORM=wayland \
    RESOLUTION=1920x1080
RUN ln --symbolic /usr/share/webapps/novnc/vnc.html /usr/share/webapps/novnc/index.html
COPY vnc /etc/sway/config.d/

# Remove the build user since it is no longer needed.
RUN userdel --remove build

# Create the developer user. Do this last so the build arg doesn't affect caching for all of the the
# above. Do as little as possible beyond this point.
ARG DEV_USERNAME=dev
RUN useradd --create-home --groups wheel ${DEV_USERNAME} \
 && chsh --shell "$(which zsh)" ${DEV_USERNAME} \
 && touch /etc/subuid /etc/subgid \
 && usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ${DEV_USERNAME}
USER ${DEV_USERNAME}
WORKDIR /home/${DEV_USERNAME}

# Ensure the XDG runtime directory exists and has proper ownership for the developer user.
RUN sudo install -d -g users -o ${DEV_USERNAME} -m 0700 /tmp/xdg

# Symlink all of the dotfiles into their needed locations.
COPY --chown=${DEV_USERNAME} dotfiles ./.dotfiles
RUN cd .dotfiles \
 && stow --verbose */

EXPOSE 6080
COPY entrypoint.bash /usr/local/bin
ENTRYPOINT ["entrypoint.bash"]

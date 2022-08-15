FROM lopsided/archlinux:devel as build

RUN sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 8/g' /etc/pacman.conf && \
    pacman -Sy --noconfirm && \
    sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    curl -fsSL https://blackarch.org/strap.sh | sh && \
    pacman -S yay --noconfirm && \
    groupadd users && groupadd wheel && \
    useradd -m -g users -G wheel -s /bin/bash builder

USER builder
WORKDIR /home/builder

RUN MAKEFLAGS="-j$(nproc)" yay -S --noconfirm x86_64-elf-binutils && \
    tar -czvf binutils.tgz \
        /usr/bin/x86_64-elf* /usr/lib/x86_64-elf

FROM scratch
COPY --from=build /home/builder/binutils.tgz .

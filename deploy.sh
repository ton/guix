#!/bin/sh
for i in $(seq -w 1 10);
do
	useradd -g guixbuild -G guixbuild           \
		-d /var/empty -s $(which nologin)   \
		-c "Guix build user $i" --system    \
		guixbuilder"$i";
done

# Install systemd service files and start guix daemon and gnu store mount.
cp ~root/.config/guix/current/lib/systemd/system/gnu-store.mount \
	~root/.config/guix/current/lib/systemd/system/guix-daemon.service \
	/etc/systemd/system/
systemctl enable --now gnu-store.mount guix-daemon

# Periodically run `guix gc`.
cp ~root/.config/guix/current/lib/systemd/system/guix-gc.service \
	~root/.config/guix/current/lib/systemd/system/guix-gc.timer \
	/etc/systemd/system/
systemctl enable --now guix-gc.timer

# Make `guix` available for all users.
mkdir -p /usr/local/bin
cd /usr/local/bin
ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix

# Make info pages for Guix available for all users.
mkdir -p /usr/local/share/info
cd /usr/local/share/info
for i in /var/guix/profiles/per-user/root/current-guix/share/info/* ; do
	ln -sf "$i";
done

# Authorize substitutes.
guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub
guix archive --authorize < ~root/.config/guix/current/share/guix/bordeaux.guix.gnu.org.pub

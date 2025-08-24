install:
	mkdir --parents "${HOME}/.local/share/jellyfin"
	cp --recursive ./container/compose.yaml "${HOME}/.local/share/jellyfin/"
	cp --recursive ./container/.env "${HOME}/.local/share/jellyfin/"
	cp --recursive ./systemd/jellyfin-server.service "${HOME}/.config/systemd/user/"

uninstall: disable
	rm -r "${HOME}/.config/systemd/user/jellyfin-server.service"
	rm -r "${HOME}/.local/share/jellyfin"

enable: install
	systemctl --user enable jellyfin-server.service

disable: stop
	systemctl --user disable jellyfin-server.service

start: enable
	systemctl --user start jellyfin-server.service

stop:
	systemctl --user stop jellyfin-server.service

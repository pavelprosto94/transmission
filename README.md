# Transmission

Transmission is a suite of BitTorrent clients. All of its functions are simple, intuitive interface combined with efficiency and a backend that supports multiple platforms.
- Add your torrent files and start downloading right now
- Control download speed and use network encryption
- Interface adapted for Ubuntu Touch

![screenshot_big.png](_resources/screenshot_big.png)

**This release does not support magnet links (only *.torrent file)**
**Known bugs (fix in future releases)**
- Due to sleep mode, torrent downloads can pause on their own (you have to manually pause and restart).
*This bug will be fixed after: I teach the app to detect the approximate download time. Then, the program will be able to restart the download on its own.*
- If your device does not have enough space, then the torrent is added, but it gives an error [Errno 28] No space left on device
*In the future, I will teach the program to determine the size of the loaded content and not add it if there is not enough space.*
*I also plan to add a selective file download mode if a torrent with many files is being downloaded.*

## Build
In the terminal, go to our directory with the project and enter the command:
    
    clickable
    
The project will compile and run on our phone

## License

Copyright (C) 2021  Pavel Prosto

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

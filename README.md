# yt-downloader

A YouTube video downloader GUI application built with Python, Tkinter, and yt-dlp. Download videos, playlists, and audio with quality selection and pause/resume functionality.

## Features

- 🎥 **Video Downloads**: Download YouTube videos in various qualities (Normal, 4K, 8K)
- 🎵 **Audio Extraction**: Convert videos to MP3 audio-only format
- 📋 **Batch Processing**: Download multiple URLs or entire playlists
- ⏸️ **Pause/Resume**: Control downloads with pause and resume functionality
- 🖥️ **Cross-Platform**: Works on Windows and Linux (Debian/Ubuntu/Kali)

## Installation

### Linux (Debian/Ubuntu/Kali)

Install with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/bhaskarvilles/yt-downloader/main/install_linux.sh | bash
```

Or install via APT (after adding the repository):

```bash
sudo apt-get install yt-downloader
```

### Windows

1. Download the latest `.exe` from [Releases](https://github.com/bhaskarvilles/yt-downloader/releases)
2. Run `yt-downloader.exe`

## Usage

After installation, run:

```bash
yt-downloader
```

### GUI Features

1. **Enter URLs**: Paste YouTube video or playlist URLs (one per line)
2. **Load Batch File**: Load multiple URLs from a text file
3. **Select Quality**: Choose Normal, 4K, or 8K quality
4. **Audio Only**: Check "MP3 Audio Only" to extract audio only
5. **Start Download**: Click "Start" to begin downloading
6. **Pause/Resume**: Use pause and resume buttons to control downloads

### Download Location

Downloads are saved to: `~/YouTube_Downloads/`

Files are organized by channel:
```
~/YouTube_Downloads/
  └── Channel Name/
      └── Video Title.mp4
```

## Requirements

- Python 3.x
- yt-dlp (installed automatically as a dependency)
- Tkinter (usually included with Python)

## Building from Source

### Linux

```bash
chmod +x build_deb.sh
./build_deb.sh
sudo dpkg -i yt-downloader_1.0.0_*.deb
```

### Windows

```bash
build_windows.bat
```

The executable will be in the `dist/` folder.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

[bhaskarvilles](https://github.com/bhaskarvilles)


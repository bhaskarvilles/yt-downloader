import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import subprocess, threading, queue, re
from pathlib import Path

DOWNLOAD_DIR = Path.home() / "YouTube_Downloads"
DOWNLOAD_DIR.mkdir(exist_ok=True)

process = None
paused = False
progress_queue = queue.Queue()

# ---------------- FORMAT LOGIC ---------------- #

def build_format(quality, audio_only):
    if audio_only:
        return "bestaudio/best"
    if quality == "4K":
        return "bv*[height>=2160]+ba/best"
    if quality == "8K":
        return "bv*[height>=4320]+ba/best"
    return "bv*+ba/best"

# ---------------- DOWNLOAD THREAD ---------------- #

def download_worker(urls, quality, audio_only):
    global process

    format_code = build_format(quality, audio_only)

    for url in urls:
        if paused:
            break

        cmd = [
            "yt-dlp",
            "--newline",
            "--continue",
            "-f", format_code,
            "-o", f"{DOWNLOAD_DIR}/%(channel)s/%(title)s.%(ext)s",
            "--restrict-filenames",
            "--embed-metadata",
            "--embed-thumbnail",
            url.strip()
        ]

        if audio_only:
            cmd += [
                "-x",
                "--audio-format", "mp3",
                "--audio-quality", "0"
            ]
        else:
            cmd += ["--merge-output-format", "mp4"]

        process = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        )

        for line in process.stdout:
            match = re.search(r"(\d+\.\d+)%", line)
            if match:
                progress_queue.put(float(match.group(1)))

        process.wait()

    progress_queue.put("DONE")

# ---------------- GUI ACTIONS ---------------- #

def start_download():
    global paused
    paused = False
    progress_bar["value"] = 0

    urls = text_box.get("1.0", tk.END).strip().splitlines()
    if not urls:
        messagebox.showerror("Error", "Enter at least one URL")
        return

    threading.Thread(
        target=download_worker,
        args=(urls, quality_var.get(), audio_var.get()),
        daemon=True
    ).start()

    root.after(100, update_progress)

def pause_download():
    global paused, process
    paused = True
    if process:
        process.terminate()
    status_label.config(text="Paused ⏸")

def resume_download():
    status_label.config(text="Resuming ▶")
    start_download()

def update_progress():
    try:
        while True:
            value = progress_queue.get_nowait()
            if value == "DONE":
                progress_bar["value"] = 100
                status_label.config(text="Completed ✅")
                return
            progress_bar["value"] = value
            status_label.config(text=f"Downloading… {value:.1f}%")
    except queue.Empty:
        pass
    root.after(100, update_progress)

def load_batch_file():
    path = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt")])
    if path:
        with open(path) as f:
            text_box.delete("1.0", tk.END)
            text_box.insert(tk.END, f.read())

# ---------------- GUI ---------------- #

root = tk.Tk()
root.title("YouTube Pro Downloader – GUI | 4K | MP3 | Pause")
root.geometry("750x560")

tk.Label(root, text="YouTube URLs (one per line / playlist):",
         font=("Arial", 12)).pack(pady=5)

text_box = tk.Text(root, height=10, width=90)
text_box.pack()

control_frame = tk.Frame(root)
control_frame.pack(pady=10)

tk.Button(control_frame, text="Load Batch File",
          command=load_batch_file, width=20).grid(row=0, column=0, padx=5)

tk.Button(control_frame, text="Start",
          command=start_download, width=15).grid(row=0, column=1, padx=5)

tk.Button(control_frame, text="Pause",
          command=pause_download, width=15).grid(row=0, column=2, padx=5)

tk.Button(control_frame, text="Resume",
          command=resume_download, width=15).grid(row=0, column=3, padx=5)

quality_var = tk.StringVar(value="Normal")
audio_var = tk.BooleanVar(value=False)

quality_frame = tk.LabelFrame(root, text="Quality Mode")
quality_frame.pack(pady=8)

tk.Radiobutton(quality_frame, text="Normal (Best)",
               variable=quality_var, value="Normal").pack(anchor="w")
tk.Radiobutton(quality_frame, text="Force 4K (2160p+)",
               variable=quality_var, value="4K").pack(anchor="w")
tk.Radiobutton(quality_frame, text="Force 8K (4320p+)",
               variable=quality_var, value="8K").pack(anchor="w")

tk.Checkbutton(root, text="MP3 Audio Only",
               variable=audio_var).pack()

progress_bar = ttk.Progressbar(root, length=650, mode="determinate")
progress_bar.pack(pady=15)

status_label = tk.Label(root, text="Idle", fg="gray")
status_label.pack()

tk.Label(root,
         text=f"Downloads saved to: {DOWNLOAD_DIR}",
         fg="gray").pack(pady=5)

root.mainloop()

#!/usr/bin/env python3
import customtkinter as ctk
from PIL import Image, ImageTk
import os
import subprocess
from pathlib import Path
import configparser

# Set appearance
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class DockApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Custom Dock")
        
        # Dock state
        self.is_hidden = False
        self.apps_list = []
        
        # Configure window
        self.root.overrideredirect(True)
        self.root.attributes('-topmost', True)
        
        # Positioning - top left
        self.screen_width = self.root.winfo_screenwidth()
        self.screen_height = self.root.winfo_screenheight()
        self.dock_height = min(600, self.screen_height - 100)  # Adaptive height
        self.dock_width = 200  # Initial width, will be updated
        self.visible_x = 0
        self.visible_y = 0
        self.hidden_x = -self.dock_width + 5
        self.hidden_y = 0
        
        self.root.geometry(f"{self.dock_width}x{self.dock_height}+{self.visible_x}+{self.visible_y}")
        
        # Main frame
        self.main_frame = ctk.CTkFrame(self.root, corner_radius=0, fg_color="#1a1d23")
        self.main_frame.pack(fill="both", expand=True)
        
        # Top bar
        self.top_bar = ctk.CTkFrame(self.main_frame, height=30, corner_radius=0, 
                                    fg_color="#2e3440")
        self.top_bar.pack(fill="x", side="top")
        self.top_bar.pack_propagate(False)
        
        # Drag handle
        self.drag_label = ctk.CTkLabel(self.top_bar, text="⋮⋮⋮", 
                                       text_color="#4c566a", cursor="fleur")
        self.drag_label.pack(side="left", padx=10)
        self.drag_label.bind('<Button-1>', self.start_move)
        self.drag_label.bind('<B1-Motion>', self.do_move)
        
        # Title
        ctk.CTkLabel(self.top_bar, text="Custom Dock", 
                    text_color="#88c0d0", font=("Arial", 11, "bold")).pack(side="left", padx=5)
        
        # Spacer
        ctk.CTkFrame(self.top_bar, fg_color="transparent").pack(side="left", fill="both", expand=True)
        
        # Hide button
        self.hide_btn = ctk.CTkButton(self.top_bar, text="◀", width=40, height=26,
                                     command=self.toggle_dock, corner_radius=5,
                                     fg_color="#5e81ac", hover_color="#81a1c1")
        self.hide_btn.pack(side="right", padx=2)
        
        # Close button
        ctk.CTkButton(self.top_bar, text="×", width=40, height=26,
                     command=self.root.quit, corner_radius=5,
                     fg_color="#bf616a", hover_color="#d08770").pack(side="right", padx=2)
        
        # Scrollable frame for apps
        self.scroll_frame = ctk.CTkScrollableFrame(self.main_frame, orientation="vertical",
                                                   width=80, corner_radius=0,
                                                   fg_color="transparent",
                                                   scrollbar_button_color="#3b4252",
                                                   scrollbar_button_hover_color="#4c566a")
        self.scroll_frame.pack(fill="both", expand=True, padx=5, pady=(0, 5))
        
        # Cache
        self.icon_cache = {}
        self.button_images = []
        
        # Check xdotool
        self.has_xdotool = self.check_xdotool()
        
        # Load apps
        self.load_applications()
        
    def start_move(self, event):
        self.x = event.x
        self.y = event.y
        
    def do_move(self, event):
        if self.is_hidden:
            return
        deltax = event.x - self.x
        deltay = event.y - self.y
        x = self.root.winfo_x() + deltax
        y = self.root.winfo_y() + deltay
        self.root.geometry(f"+{x}+{y}")
        
    def toggle_dock(self):
        """Toggle dock visibility"""
        if self.is_hidden:
            self.root.geometry(f"{self.dock_width}x{self.dock_height}+{self.visible_x}+{self.visible_y}")
            self.hide_btn.configure(text="◀")
            self.is_hidden = False
        else:
            self.root.geometry(f"{self.dock_width}x{self.dock_height}+{self.hidden_x}+{self.hidden_y}")
            self.hide_btn.configure(text="▶")
            self.is_hidden = True
        
    def check_xdotool(self):
        """Check if xdotool is available"""
        try:
            subprocess.run(['xdotool', '--version'], 
                          capture_output=True, check=True)
            return True
        except:
            return False
    
    def get_window_ids_by_name(self, app_name):
        """Get window IDs for an application by name"""
        if not self.has_xdotool:
            return []
        
        try:
            result = subprocess.run(['xdotool', 'search', '--name', app_name],
                                  capture_output=True, text=True, timeout=1)
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split('\n')
            return []
        except:
            return []
    
    def toggle_window(self, window_id):
        """Minimize or restore a window"""
        if not self.has_xdotool:
            return
        
        try:
            state_result = subprocess.run(['xprop', '-id', window_id, '_NET_WM_STATE'],
                                        capture_output=True, text=True, timeout=1)
            
            is_hidden = 'HIDDEN' in state_result.stdout
            
            if is_hidden:
                subprocess.run(['xdotool', 'windowactivate', window_id],
                             capture_output=True, timeout=1)
            else:
                subprocess.run(['xdotool', 'windowminimize', window_id],
                             capture_output=True, timeout=1)
        except:
            pass
    
    def find_icon(self, icon_name):
        """Find icon file in standard locations"""
        if not icon_name:
            return None
        
        if os.path.isabs(icon_name) and os.path.exists(icon_name):
            return icon_name
        
        extensions = ['', '.png', '.svg', '.xpm', '.jpg', '.jpeg', '.gif']
        
        search_paths = []
        search_paths.append(Path("/usr/share/pixmaps"))
        
        icon_bases = [
            Path("/usr/share/icons"),
            Path.home() / ".local/share/icons",
            Path.home() / ".icons",
        ]
        
        themes = ['hicolor', 'gnome', 'Adwaita', 'Humanity', 'oxygen', 'breeze']
        sizes = ['48x48', '48', '64x64', '64', '128x128', '128', 'scalable']
        categories = ['apps', 'actions', 'categories', 'devices', 'places', 'status']
        
        for base in icon_bases:
            if base.exists():
                search_paths.append(base)
                for theme in themes:
                    theme_path = base / theme
                    if theme_path.exists():
                        search_paths.append(theme_path)
                        for size in sizes:
                            for cat in categories:
                                search_paths.append(theme_path / size / cat)
                                search_paths.append(theme_path / cat / size)
        
        for search_path in search_paths:
            if not search_path.exists():
                continue
            
            for ext in extensions:
                icon_file = search_path / f"{icon_name}{ext}"
                if icon_file.is_file():
                    return str(icon_file)
        
        for base_dir in [Path("/usr/share/pixmaps"), Path("/usr/share/icons")]:
            if base_dir.exists():
                for ext in extensions:
                    pattern = f"**/{icon_name}{ext}"
                    try:
                        matches = list(base_dir.glob(pattern))
                        if matches:
                            return str(matches[0])
                    except:
                        pass
        
        return None
    
    def create_dummy_icon(self, text, size=48):
        """Create a colored icon with text"""
        try:
            hash_val = sum(ord(c) for c in text)
            colors = ['#bf616a', '#d08770', '#ebcb8b', '#a3be8c', '#88c0d0', '#81a1c1', '#b48ead']
            color = colors[hash_val % len(colors)]
            
            img = Image.new('RGB', (size, size), color)
            photo = ImageTk.PhotoImage(img)
            return photo
        except:
            return None
    
    def load_icon(self, icon_name, size=48):
        """Load and resize icon"""
        if not icon_name:
            return None
            
        icon_path = self.find_icon(icon_name)
        
        if not icon_path:
            return None
        
        try:
            cache_key = f"{icon_path}_{size}"
            if cache_key in self.icon_cache:
                return self.icon_cache[cache_key]
            
            img = Image.open(icon_path)
            
            if img.mode in ('RGBA', 'LA', 'P'):
                background = Image.new('RGBA', img.size, (26, 29, 35, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, (0, 0), img)
                img = background.convert('RGB')
            else:
                img = img.convert('RGB')
            
            img = img.resize((size, size), Image.Resampling.LANCZOS)
            photo = ImageTk.PhotoImage(img)
            
            self.icon_cache[cache_key] = photo
            return photo
        except:
            return None
    
    def load_applications(self):
        apps = []
        
        desktop_paths = [
            Path.home() / "Desktop",
            Path.home() / ".local/share/applications",
            Path("/usr/share/applications")
        ]
        
        for path in desktop_paths:
            if path.exists():
                for desktop_file in path.glob("*.desktop"):
                    app_info = self.parse_desktop_file(desktop_file)
                    if app_info:
                        apps.append(app_info)
        
        seen = {}
        for app in apps:
            if app['name'] not in seen:
                seen[app['name']] = app
        
        for i, app in enumerate(list(seen.values())[:30]):
            self.create_app_button(app, i)
        
        # Update dock width based on content
        self.root.update_idletasks()
        # Width = icon (48) + padding + scrollbar + margins
        self.dock_width = 90  # Compact width for vertical layout
        self.hidden_x = -self.dock_width + 5
        self.root.geometry(f"{self.dock_width}x{self.dock_height}+{self.visible_x}+{self.visible_y}")
    
    def parse_desktop_file(self, filepath):
        """Parse .desktop file"""
        try:
            config = configparser.ConfigParser(interpolation=None)
            config.read(filepath, encoding='utf-8')
            
            if 'Desktop Entry' not in config:
                return None
            
            entry = config['Desktop Entry']
            
            if entry.get('NoDisplay', 'false').lower() == 'true':
                return None
            if entry.get('Hidden', 'false').lower() == 'true':
                return None
            
            name = entry.get('Name', filepath.stem)
            exec_cmd = entry.get('Exec', '')
            icon = entry.get('Icon', '')
            terminal = entry.get('Terminal', 'false').lower() == 'true'
            
            if not exec_cmd:
                return None
            
            exec_cmd = exec_cmd.replace('%f', '').replace('%F', '')
            exec_cmd = exec_cmd.replace('%u', '').replace('%U', '')
            exec_cmd = exec_cmd.replace('%i', '').replace('%c', name)
            exec_cmd = exec_cmd.strip()
            
            return {
                'name': name,
                'exec': exec_cmd,
                'icon': icon,
                'terminal': terminal,
                'path': str(filepath)
            }
        except:
            return None
    
    def create_app_button(self, app, index):
        """Create a button for an application"""
        icon_photo = self.load_icon(app['icon'], size=48)
        
        if not icon_photo:
            icon_photo = self.create_dummy_icon(app['name'], size=48)
        
        if icon_photo:
            self.button_images.append(icon_photo)
            
            # Button with image
            btn = ctk.CTkButton(self.scroll_frame, image=icon_photo, text="",
                               width=48, height=48,
                               command=lambda: self.handle_app_click(app),
                               fg_color="#2e3440", hover_color="#4c566a",
                               corner_radius=8)
            btn.image = icon_photo
            btn.pack(pady=3, padx=5)
        else:
            btn = ctk.CTkButton(self.scroll_frame, text=app['name'][:2],
                               width=48, height=48,
                               command=lambda: self.handle_app_click(app),
                               fg_color="#2e3440", hover_color="#4c566a",
                               corner_radius=8, font=("Arial", 10, "bold"))
            btn.pack(pady=3, padx=5)
    
    def handle_app_click(self, app):
        """Handle app click"""
        window_ids = self.get_window_ids_by_name(app['name'])
        
        if window_ids:
            self.toggle_window(window_ids[0])
        else:
            self.launch_app(app)
    
    def launch_app(self, app):
        """Launch an application"""
        try:
            cmd = app['exec']
            
            if app['terminal']:
                terminals = ['x-terminal-emulator', 'xterm', 'gnome-terminal', 'konsole', 'xfce4-terminal', 'lxterminal']
                for term in terminals:
                    try:
                        subprocess.Popen([term, '-e', cmd], 
                                       start_new_session=True,
                                       stdout=subprocess.DEVNULL,
                                       stderr=subprocess.DEVNULL)
                        return
                    except FileNotFoundError:
                        continue
                subprocess.Popen(cmd, shell=True, 
                               start_new_session=True,
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
            else:
                subprocess.Popen(cmd, shell=True, 
                               start_new_session=True,
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
        except:
            pass

def main():
    root = ctk.CTk()
    app = DockApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
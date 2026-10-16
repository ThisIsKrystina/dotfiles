#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0
# Action menu kitten for kitty
#
# For single user place as: ~/.config/kitty/action_menu.py
# Bind in kitty.conf:
#   mouse_map right press ungrabbed kitten action_menu.py
# Append --debug-action-menu for verbose stdout logging (optional).

import sys
from typing import List, Optional

from kittens.tui.handler import Handler, kitten_ui
from kittens.tui.operations import MouseTracking
from kittens.tui.loop import Loop, MouseButton, EventType
from kitty.fast_data_types import add_timer, wcswidth
from kitty.typing_compat import KeyEventType, BossType
#from kitty.clipboard import set_clipboard_string


# Menu entries: (icon, label, action)
MENU = [
    ("📋", "Copy Selection",        "copy_sel"),
    ("🔗", "Copy Link Address",     "copy_link"),
    ("📁", "Copy Path",             "copy_path"),
    ("📥", "Paste from Clipboard",  "paste_clip"),
    ("➕", "New tab",               "new_tab"),
    ("↔️", "Split horizontally",    "hsplit"),
    ("↕️", "Split vertically",      "vsplit"),
    ("❌", "Close Tab/Window",      "close"),
    ("🚫", "Cancel",                None),
]

# runtime flag controlled by CLI arg --debug-action-menu
DEBUG_ACTION_MENU = False

def safe_debug(msg: str, force_print: bool = False):
    """
    Wrapper that logs debug messages.
    - When DEBUG_ACTION_MENU is True, prints messages to stdout (prefixed).
    - If force_print is True, uses print instead of debug
    - Otherwise, attempt kitty debug() (which may be swallowed by some launchers).
    """
    global DEBUG_ACTION_MENU

    print(f"print[actionmenu]: {msg}, dbg_enabled: {DEBUG_ACTION_MENU}, forced: {force_print}", file=sys.stdout, flush=True)

    if DEBUG_ACTION_MENU:
        if force_print:
            print(f"print[actionmenu]: {msg}", file=sys.stdout, flush=True)
        else :
            debug(f"debug[actionmenu]: {msg}")

class ActionMenu(Handler):
    mouse_tracking = MouseTracking.full

    def initialize(self) -> None:
        self.choice = None
        self.cmd.clear_screen()
        self.cmd.set_cursor_visible(True)
        self.cmd.set_default_colors()

        # Build menu lines with greying
        inner_lines = []
        for i, (icon, label, action) in enumerate(MENU, 1):
            disabled = False

            line = f"{i}. {icon} {label}"
            inner_lines.append((line, disabled))

        max_len = max(wcswidth(s) for s, _ in inner_lines)
        self.box_width = max_len + 4

        top = "┌" + "─" * (self.box_width - 2) + "┐\r\n"
        bottom = "└" + "─" * (self.box_width - 2) + "┘\r\n"

        self.write(top)
        for line, disabled in inner_lines:
            pad = max_len - wcswidth(line)
            if disabled:
                prefix = "\x1b[38;5;240m"
                suffix = "\x1b[0m"
            else:
                prefix = suffix = ""
            self.write(f"│ {prefix}{line}{suffix}{' ' * pad} │\r\n")
        self.write(bottom)

        self.write("\r\nLeft-click or press number\r\n")
        self.write(    "to choose, or Esc to cancel.\r\n")

    def on_key(self, key_event: KeyEventType) -> None:
        safe_debug(f"on_key(): key={key_event.key!r} type={key_event.type} mods={key_event.mods}")
        k = str(key_event.key)

        SUPERSCRIPT = {
            "⁰": "0", "¹": "1", "²": "2", "³": "3", "⁴": "4",
            "⁵": "5", "⁶": "6", "⁷": "7", "⁸": "8", "⁹": "9",
        }
        if k in SUPERSCRIPT:
            k = SUPERSCRIPT[k]

        if k in ("ESCAPE", "escape"):
            self.quit_loop(0)
            return

        if k.isdigit():
            idx = int(k)
        elif k.startswith("KP") and k[2:].isdigit():
            idx = int(k[2:])
        elif k.startswith("raw_") and k[4:].isdigit():
            code = int(k[4:])
            if 49 <= code <= 57:
                idx = code - 48
            else:
                return
        else:
            return

        if 1 <= idx <= len(MENU):
            self.choice = idx - 1
            self.quit_loop(0)

    def on_mouse_event(self, event):
        if event.type is not EventType.MOVE:
            safe_debug(f"on_mouse_event(): type={event.type} buttons={event.buttons} "
                       f"cell=({event.cell_x},{event.cell_y}) pixel=({event.pixel_x},{event.pixel_y})")

        if event.type is not EventType.RELEASE:
            return
        if not (event.buttons & MouseButton.LEFT):
            return

        row = event.cell_y
        col = event.cell_x
        if row < 1 or row > len(MENU):
            return
        if col < 0 or col >= self.box_width:
            return

        self.choice = row - 1
        self.quit_loop(0)

    on_interrupt = on_eot = on_term = lambda self: self.quit_loop(0)


# ----------------------------------------------------------------------
# main()
# ----------------------------------------------------------------------

@kitten_ui(allow_remote_control=True)
def main(args):
    """
    args: list of CLI args passed by kitty when launching the kitten.
    Recognized option:
      --debug-action-menu    enable stdout debug messages for this kitten
    """
    global DEBUG_ACTION_MENU
    # parse simple flag
    try:
        if args and isinstance(args, (list, tuple)):
            if "--debug-action-menu" in args:
                DEBUG_ACTION_MENU = True
            else:
                print("print[actionmenu]: debug-action-menu not found", file=sys.stdout, flush=True)
    except Exception as e:
        print(f"print[actionmenu]: exception reading debug-action-menu : {e}", file=sys.stdout, flush=True)
        DEBUG_ACTION_MENU = False

    safe_debug("--- Kitten action_menu started ---")
    safe_debug(f"Args: {args}")
    print(f"Args: {args}", file=sys.stdout, flush=True)

    loop = Loop()
    handler = ActionMenu()
    loop.loop(handler)
    return handler.choice

# ----------------------------------------------------------------------
# Unified scheduler helper and handle_result()
# ----------------------------------------------------------------------

def schedule_remote(boss, wid, *, action_name: Optional[str] = None,
                    launch_location: Optional[str] = None, target_window_obj=None,
                    raw_args: Optional[List[str]] = None, combine_action: Optional[str] = None):
    """
    Schedule a remote-control call via add_timer.
    - If action_name is provided, calls: ("action", f"--match=id:{wid}", action_name)
    - If launch_location is provided, calls: ("launch", f"--match=id:{wid}", f"--location={launch_location}")
    - If raw_args is provided, calls: ("launch", f"--match=id:{wid}", *raw_args)
    - If combine_action is provided, calls boss.combine(combine_action, target_window_obj)
    - If target_window_obj is provided, the call will be invoked with that window object where applicable.
    """
    def _do(_timer_id=None):
        try:
            if combine_action:
                # run the action definition via boss.combine in the boss process,
                # targeting the provided window object if available.
                try:
                    boss.combine(combine_action, target_window_obj)
                    safe_debug(f"schedule_remote(): combined action: {combine_action}", force_print=True)
                except Exception as e:
                    safe_debug(f"schedule_remote(): combine error: {e}", force_print=True)
                return

            if action_name:
                tup = ("action", f"--match=id:{wid}", action_name)
                boss.call_remote_control(None, tup)
                safe_debug(f"schedule_remote(): called {tup}", force_print=True)
            elif launch_location:
                tup = ("launch", f"--match=id:{wid}", f"--location={launch_location}")
                boss.call_remote_control(None, tup)
                safe_debug(f"schedule_remote(): called {tup}", force_print=True)
            elif raw_args:
                tup = ("launch", f"--match=id:{wid}", *raw_args)
                # If a window object is provided, call with it so the kitten runs in that window's context
                if target_window_obj is not None:
                    boss.call_remote_control(target_window_obj, tup)
                else:
                    boss.call_remote_control(None, tup)
                safe_debug(f"schedule_remote(): called {tup}", force_print=True)
            elif target_window_obj is not None:
                tup = ("action", "new_tab")
                boss.call_remote_control(target_window_obj, tup)
                safe_debug(f"schedule_remote(): called {tup} on window object {getattr(target_window_obj, 'id', None)}", force_print=True)
            else:
                safe_debug("schedule_remote(): nothing to do (no action_name, no launch_location, no raw_args, no combine_action, no target_window_obj)", force_print=True)
        except Exception as e:
            safe_debug(f"schedule_remote(): error calling remote_control: {e}", force_print=True)
    add_timer(_do, 0, False)


def handle_result(args, answer, target_window_id, boss: BossType):
    # Force print fallback in handle_result so output is visible when kitty's stdout is captured.
    safe_debug(f"handle_result: answer={answer!r} target={target_window_id!r}", force_print=True)

    if answer is None:
        return

    choice = answer
    icon, label, action = MENU[choice]
    safe_debug(f"menu entry: {label} ({action})", force_print=True)

    w = boss.window_id_map.get(target_window_id)
    if not w:
        safe_debug("no window for id", force_print=True)
        return

    wid = w.id

    # --- Capture selection NOW (correct timing) ---
    try:
        sel_before = w.text_for_selection()
    except Exception:
        sel_before = None

    selection_nonempty = bool(sel_before)
    safe_debug(f"sel_before={sel_before!r} selection_nonempty={selection_nonempty!r}", force_print=True)

    # --- COPY SELECTION ---
    # if action == "copy_sel":
    #     if selection_nonempty:
    #         def _copy(_timer_id=None):
    #             try:
    #                 set_clipboard_string(sel_before)
    #                 boss.handle_clipboard_loss('clipboard', wid)
    #                 safe_debug(f"copy_sel: copied '{sel_before}'", force_print=True)
    #             except Exception as e:
    #                 safe_debug(f"copy_sel: error copying selection: {e}", force_print=True)
    #         add_timer(_copy, 0, False)
    #     else:
    #         safe_debug("copy_sel: no selection", force_print=True)
    #     return

    # --- COPY SELECTION ---
    if action == "copy_sel":
        # that is much simpler and works too
        schedule_remote(boss, wid, action_name="copy_to_clipboard")
        return

    # --- COPY LINK ADDRESS (hints kitten via boss.combine) ---
    if action == "copy_link":
        # Use boss.combine to dispatch the same action string that a keybinding or the
        # command-palette would use. This runs in the boss process and is targeted
        # at the specific window object so hints scans that window's visible buffer.
        combine_action = "kitten hints --program @ --type url"

        # pass the window object so combine dispatches in that window's context
        schedule_remote(boss, wid, combine_action=combine_action, target_window_obj=w)

        safe_debug("copy_link: scheduled hints kitten (url) via boss.combine", force_print=True)
        return

    # --- COPY PATH (hints kitten via boss.combine) ---
    if action == "copy_path":
        # Use boss.combine to dispatch hints in path mode and copy to clipboard.
        combine_action = "kitten hints --program @ --type path"

        # pass the window object so combine dispatches in that window's context
        schedule_remote(boss, wid, combine_action=combine_action, target_window_obj=w)

        safe_debug("copy_path: scheduled hints kitten (path) via boss.combine", force_print=True)
        return

    # --- PASTE FROM CLIPBOARD ---
    if action == "paste_clip":
        schedule_remote(boss, wid, action_name="paste_from_clipboard")
        return

    # --- NEW TAB ---
    if action == "new_tab":
        # preserve previous behavior of calling with window object
        schedule_remote(boss, wid, target_window_obj=w)
        return

    # --- SPLITS ---
    if action == "hsplit":
        schedule_remote(boss, wid, launch_location="hsplit")
        return

    if action == "vsplit":
        schedule_remote(boss, wid, launch_location="vsplit")
        return

    # --- CLOSE ---
    if action == "close":
        schedule_remote(boss, wid, action_name="close_window")
        return

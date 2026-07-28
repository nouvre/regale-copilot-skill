"""inchat_ui_helpers.py
Helpers for rendering a clean structured preview of a demo-definition and
for offering a simple inline-edit dry-run interface (console-based helper).

This is a lightweight reference module — in the real Copilot agent the
preview would be rendered as a chat card and inline edits would be driven
by structured follow-up prompts.
"""
from typing import List


def render_preview_text(demo):
    """Return a short, scannable preview string for the given DemoDef-like object."""
    lines = []
    lines.append(f"DEMO: {demo.title}")
    lines.append(f"Audience: {demo.audience}")
    lines.append("Scenes:")
    for i, s in enumerate(demo.scenes, start=1):
        lines.append(f" {i}. {s.id} — {s.type} — ~{s.approx_duration_s}s")
        lines.append(f"    URL: {s.surface_url}")
        short_narr = (s.narration[:140] + '...') if len(s.narration) > 140 else s.narration
        lines.append(f"    Narration: {short_narr}")
        if getattr(s, 'beats', None):
            for b_idx, b in enumerate(s.beats, start=1):
                lines.append(f"      - {b_idx}. {b.action} -> {b.target_selector}")
    return "\n".join(lines)


def console_inline_edit_demo(demo):
    """A tiny, console-based inline editor for dry-run use.
    Not used by the Copilot agent directly; provided so maintainers can
    simulate the in-chat edit flow locally.
    """
    print("Starting inline edit (console) — press Enter to keep current value")
    for s in demo.scenes:
        new_title = input(f"Scene title [{s.id}]: ")
        if new_title.strip():
            s.id = new_title.strip()
        new_dur = input(f"Duration in seconds [{s.approx_duration_s}]: ")
        if new_dur.strip():
            try:
                s.approx_duration_s = int(new_dur.strip())
            except ValueError:
                print("Invalid number — keeping existing duration")
        new_narr = input(f"Narration (first 80 chars) [{s.narration[:80]}...]: ")
        if new_narr.strip():
            s.narration = new_narr.strip()
    print("Inline edit complete.")
    return demo

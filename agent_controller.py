"""agent_controller.py
Lightweight state machine and command parser for the Regale demo agent.
This is a reference implementation for use by the Copilot agent developer.

Behavior:
- Recognizes the start token `/demo` to enter DEFINITION mode.
- While in DEFINITION mode, the controller forbids any MCP/tool calls until
  it receives the exact confirmation phrase `confirm build`.
- Provides helpers to apply simple inline edit commands to the in-memory
  demo-definition object.

This module is intentionally small and dependency-free so it can be
imported in test harnesses or used as a prompt-contract reference.
"""
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional
import re


@dataclass
class Beat:
    action: str
    target_selector: str


@dataclass
class Scene:
    id: str
    type: str
    approx_duration_s: int
    surface_url: str
    narration: str
    beats: List[Beat] = field(default_factory=list)
    presenter_notes: str = ""
    persona: Dict[str, Any] = field(default_factory=dict)


@dataclass
class DemoDef:
    title: str
    audience: str
    scenes: List[Scene] = field(default_factory=list)


class AgentController:
    def __init__(self):
        self.mode = 'idle'  # idle | definition | build
        self.demo: Optional[DemoDef] = None

    def start_demo(self, raw_text: str) -> str:
        """Start a demo only if raw_text begins with '/demo'. Returns status message."""
        if not raw_text.strip().lower().startswith('/demo'):
            return 'Error: To start, please use the /demo command followed by a short brief.'
        brief = raw_text.strip()[5:].strip()
        # Create a minimal demo object (in practice the agent would call the parser/NLP)
        self.demo = DemoDef(title=self._short_title(brief), audience='')
        # Populate with placeholders to be refined by the agent's NLP
        self.demo.audience = self._infer_audience(brief)
        self.demo.scenes = self._infer_scenes_from_brief(brief)
        self.mode = 'definition'
        return 'Entered DEFINITION mode. Generated a compact preview for review.'

    def _short_title(self, brief: str) -> str:
        # Very small heuristic title from brief
        head = brief.split('.')[0]
        title = head[:60].strip() if head else 'Demo'
        return title if title else 'Demo'

    def _infer_audience(self, brief: str) -> str:
        # crude audience inference
        m = re.search(r'audience[:\s]*([A-Za-z0-9 ]+)', brief, re.I)
        if m:
            return m.group(1).strip()
        # fallback keywords
        if 'executive' in brief.lower() or 'cfo' in brief.lower() or 'cio' in brief.lower():
            return 'Executive'
        return ''

    def _infer_scenes_from_brief(self, brief: str) -> List[Scene]:
        # Create a small 3-4 scene storyboard skeleton
        scenes = []
        scenes.append(Scene(id='scene-1', type='Hook', approx_duration_s=20,
                            surface_url='', narration='Hook: state the problem succinctly.', beats=[]))
        scenes.append(Scene(id='scene-2', type='Value', approx_duration_s=40,
                            surface_url='', narration='Value: show how the product fixes it.', beats=[]))
        scenes.append(Scene(id='scene-3', type='Use-case', approx_duration_s=40,
                            surface_url='', narration='Use case example and metric.', beats=[]))
        scenes.append(Scene(id='scene-4', type='CTA', approx_duration_s=20,
                            surface_url='', narration='Call to action and next steps.', beats=[]))
        return scenes

    def render_compact_preview(self) -> str:
        if not self.demo:
            return 'No demo loaded.'
        lines = [f"DEMO: {self.demo.title}", f"Audience: {self.demo.audience}", 'Scenes:']
        for i, s in enumerate(self.demo.scenes, start=1):
            short_narr = (s.narration[:100] + '...') if len(s.narration) > 100 else s.narration
            lines.append(f"{i}. {s.id} — {s.type} — ~{s.approx_duration_s}s")
            lines.append(f"   URL: {s.surface_url or '<not set>'}")
            lines.append(f"   Narration: {short_narr}")
            if s.beats:
                for b_idx, b in enumerate(s.beats, start=1):
                    lines.append(f"     - {b_idx}. {b.action} -> {b.target_selector}")
        return "\n".join(lines)

    def process_command(self, cmd: str) -> str:
        """Process a single inline command while in DEFINITION mode."""
        if self.mode != 'definition':
            return "Not in DEFINITION mode. Start a demo with '/demo <brief>'."
        cmd = cmd.strip()
        # confirm build
        if cmd.lower() == 'confirm build':
            # transition to build mode — caller must verify permissions and then execute
            self.mode = 'build'
            return 'Confirmed: transitioning to BUILD mode. The agent may now run precondition checks and start the build.'
        # edit duration
        m = re.match(r'^edit duration scene (\d+) (\d+)$', cmd, re.I)
        if m:
            idx = int(m.group(1)) - 1
            secs = int(m.group(2))
            if 0 <= idx < len(self.demo.scenes):
                self.demo.scenes[idx].approx_duration_s = secs
                return f"Scene {idx+1} duration set to {secs}s."
            return 'Scene index out of range.'
        # rename scene
        m = re.match(r'^rename scene (\d+) \"(.+)\"$', cmd, re.I)
        if m:
            idx = int(m.group(1)) - 1
            new_title = m.group(2).strip()
            if 0 <= idx < len(self.demo.scenes):
                self.demo.scenes[idx].id = new_title
                return f"Scene {idx+1} renamed to '{new_title}'."
            return 'Scene index out of range.'
        # edit narration
        m = re.match(r'^edit narration scene (\d+):\s*\"(.+)\"$', cmd, re.I)
        if m:
            idx = int(m.group(1)) - 1
            new_text = m.group(2).strip()
            if 0 <= idx < len(self.demo.scenes):
                self.demo.scenes[idx].narration = new_text
                return f"Scene {idx+1} narration updated."
            return 'Scene index out of range.'
        # add beat
        m = re.match(r'^add beat scene (\d+):\s*(.+)\s*->\s*(.+)$', cmd, re.I)
        if m:
            idx = int(m.group(1)) - 1
            action = m.group(2).strip()
            selector = m.group(3).strip()
            if 0 <= idx < len(self.demo.scenes):
                self.demo.scenes[idx].beats.append(Beat(action=action, target_selector=selector))
                return f"Added beat to scene {idx+1}: {action} -> {selector}"
            return 'Scene index out of range.'
        # remove beat
        m = re.match(r'^remove beat scene (\d+):\s*(\d+)$', cmd, re.I)
        if m:
            idx = int(m.group(1)) - 1
            bidx = int(m.group(2)) - 1
            if 0 <= idx < len(self.demo.scenes):
                beats = self.demo.scenes[idx].beats
                if 0 <= bidx < len(beats):
                    removed = beats.pop(bidx)
                    return f"Removed beat {bidx+1} from scene {idx+1}: {removed.action}"
                return 'Beat index out of range.'
            return 'Scene index out of range.'
        # reorder scene
        m = re.match(r'^reorder scene (\d+) (\d+)$', cmd, re.I)
        if m:
            a = int(m.group(1)) - 1
            b = int(m.group(2)) - 1
            if 0 <= a < len(self.demo.scenes) and 0 <= b < len(self.demo.scenes):
                sc = self.demo.scenes.pop(a)
                self.demo.scenes.insert(b, sc)
                return f"Moved scene {a+1} to position {b+1}."
            return 'Scene indices out of range.'
        return 'Unrecognized command. Supported commands: edit duration, rename scene, edit narration, add beat, remove beat, reorder scene, confirm build.'

    def can_execute_build(self) -> bool:
        """Return True only if the controller is in BUILD mode (confirmed)."""
        return self.mode == 'build'


# Small self-test when run directly
if __name__ == '__main__':
    c = AgentController()
    print(c.start_demo('/demo Pitch SharePoint to an executive. audience: CIO'))
    print(c.render_compact_preview())
    print(c.process_command('edit duration scene 2 30'))
    print(c.render_compact_preview())
    print(c.process_command('confirm build'))
    print('Can execute build?', c.can_execute_build())

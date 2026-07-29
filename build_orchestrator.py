#!/usr/bin/env python3
"""build_orchestrator.py (reference / dry-run)

Tool-discovery-driven orchestration for building a demo YAML into Regale Studio.
This file is intended as a reference specification and dry-run planner.

In VS Code Copilot agent mode, the agent (you, during chat) calls Regale MCP tools directly.
This script just prints the intended sequence of MCP calls without executing them.

Usage (dry-run / planning):
  python build_orchestrator.py demo.yaml

Output: prints the sequence of MCP tool calls the agent would make, including argument inspection.

"""
import sys
import yaml
import json
from dataclasses import dataclass
from typing import List, Dict, Any


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
    beats: List[Beat]
    presenter_notes: str
    persona: Dict[str, Any]  # {name, avatar_path}


@dataclass
class DemoDef:
    title: str
    audience: str
    scenes: List[Scene]


def load_demo_yaml(path: str) -> DemoDef:
    with open(path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    scenes = []
    for s in data.get('scenes', []):
        beats = [Beat(**b) for b in s.get('beats', [])]
        persona = s.get('persona', {'name': None, 'avatar_path': None})
        scene = Scene(
            id=s.get('id'),
            type=s.get('type'),
            approx_duration_s=s.get('approx_duration_s', 60),
            surface_url=s.get('surface_url', ''),
            narration=s.get('narration', ''),
            beats=beats,
            presenter_notes=s.get('presenter_notes', ''),
            persona=persona
        )
        scenes.append(scene)
    return DemoDef(title=data.get('title', ''), audience=data.get('audience', ''), scenes=scenes)


def plan_build(demo: DemoDef):
    """Print the sequence of MCP tool calls the agent will make."""
    print(f"\n{'='*70}")
    print(f"DEMO BUILD PLAN: {demo.title}")
    print(f"Audience: {demo.audience}")
    print(f"Scenes: {len(demo.scenes)}")
    print(f"{'='*70}\n")

    print("PRECONDITION CHECKS:")
    print("  1. regale_studio_uat-get_agent_permissions()")
    print("     → Check SaveProject, Publish enabled; warn user if not.\n")
    print("  2. regale_studio_uat-get_open_project()")
    print("     → Confirm project is open; get selectedSectionId.\n")
    print("  3. Discover capture mode:")
    print("     → Prefer regale_studio_uat-list_capture_targets(), set_capture_target(), start_capture() if available.")
    print("     → Use HTML Capturer only if screen/window capture is unavailable or user explicitly chooses it.\n")

    print("NATIVE SCREEN/WINDOW CAPTURE MODE (preferred if available):")
    print("  1. Derive products/surfaces from scenes and present a login/prep checklist.")
    print("  2. Ask user to open browser tabs/windows and sign in before capture begins.")
    print("  3. regale_studio_uat-list_capture_targets()")
    print("     → Present monitors, explicit browser/window targets if listed, and Active Window title/bounds.")
    print("  4. Prefer explicit browser/window target; otherwise use browser monitor. Avoid Active Window when Copilot is active.")
    print("  5. Ask user to choose target, then regale_studio_uat-set_capture_target(target=...).")
    print("  6. For monitor targets, use a delayed switch workflow before regale_studio_uat-start_capture().")
    print("  7. For each scene, prompt user to prepare the screen and call regale_studio_uat-start_capture().")
    print("  8. If capture returns zero frames or wrong surface, re-list targets and retry window/monitor capture.")
    print("  9. Add narration/notes/hotspots with available Regale page/object tools.\n")

    print(f"\nHTML CAPTURER EXPLICIT FALLBACK ({len(demo.scenes)} scenes):\n")
    print("  Use only if screen/window capture is unavailable or the user accepts signing into an isolated Capturer profile.\n")
    
    for idx, scene in enumerate(demo.scenes, start=1):
        print(f"\n  SCENE {idx}: {scene.id} ({scene.type})")
        print(f"  Duration: ~{scene.approx_duration_s}s | URL: {scene.surface_url}")
        
        print(f"  Steps:")
        print(f"    a. regale_studio_uat-navigate_capturer(url='{scene.surface_url}')")
        print(f"    b. regale_studio_uat-wait_for_capturer(timeoutMs=15000, quietMs=500)")
        
        if scene.persona.get('name'):
            print(f"    c. [Persona staging] {scene.persona.get('name')}")
            print(f"       - regale_studio_uat-list_elements(query='logo') or similar")
            print(f"       - regale_studio_uat-set_element_image(...) or set_element_text(...)")
        
        print(f"    d. regale_studio_uat-set_capture_size_mode(sizeMode='fixed', width=1920, height=1080)")
        print(f"    e. regale_studio_uat-pause_page_motion()")
        print(f"    f. regale_studio_uat-capture_html_page(freezePage=True)")
        print(f"       → Returns new page section/number")
        
        for beat_idx, beat in enumerate(scene.beats, start=1):
            print(f"    g.{beat_idx} [Beat {beat_idx}] {beat.action}")
            print(f"         - regale_studio_uat-query_dom(selector='{beat.target_selector}')")
            print(f"         - regale_studio_uat-list_elements(query=...) to find element")
            print(f"         - regale_studio_uat-instantiate_theme_shape(themeShapeId=..., section=?, page=?)")
            print(f"         - regale_studio_uat-anchor_shape(shapeId=..., selector='{beat.target_selector}')")
        
        print(f"    h. regale_studio_uat-set_text(target='page_description', section=?, page=?, text='{scene.narration[:50]}...')")
        print(f"    i. regale_studio_uat-set_text(target='page_notes', section=?, page=?, text='{scene.presenter_notes[:50]}...')")
        print(f"    j. regale_studio_uat-render_page(page=?, section=?, includeObjects=True)")
        print(f"       → Screenshot for verification")

    print(f"\n\nPOST-BUILD:")
    print(f"  - Check Publish permission; if enabled:")
    print(f"    regale_studio_uat-save_project(path=...) [if SaveProject enabled]")
    print(f"    regale_studio_uat-publish_project(...) [if Publish enabled]")
    print(f"\n{'='*70}\n")


def plan_build_from_object(demo: DemoDef):
    """Accept a DemoDef object (built internally by an agent) and print a short structured preview and plan."""
    # First print a structured preview
    print(f"\n{'='*60}")
    print(f"DEMO PREVIEW: {demo.title}")
    print(f"Audience: {demo.audience}")
    print(f"Scenes: {len(demo.scenes)}")
    print(f"{'='*60}\n")
    for idx, scene in enumerate(demo.scenes, start=1):
        print(f"{idx}. {scene.id} — {scene.type} — ~{scene.approx_duration_s}s")
        print(f"   URL: {scene.surface_url}")
        print(f"   Narration: {scene.narration[:100]}{'...' if len(scene.narration)>100 else ''}")
        if scene.beats:
            print(f"   Beats:")
            for bidx, b in enumerate(scene.beats, start=1):
                print(f"     {bidx}. {b.action} -> {b.target_selector}")
        print("")

    print("PLANNED MCP STEPS (summary):")
    print("  - precondition checks (permissions, open project, capturer)")
    print("  - per-scene: navigate, stage persona, pause motion, capture, place objects, write narration, render")
    print("  - post-build: save and/or publish if allowed")
    print(f"\n{'='*60}\n")


if __name__ == '__main__':
    # Backwards-compatible CLI: if a YAML path is provided, plan from YAML
    if len(sys.argv) == 2 and sys.argv[1].endswith('.yaml'):
        demo = load_demo_yaml(sys.argv[1])
        plan_build(demo)
        print("To execute: use the Copilot agent in VS Code (on the same PC as Regale Studio with the Capturer open).")
    else:
        print('No demo YAML provided on CLI. This script supports two modes:')
        print('  1) python build_orchestrator.py demo.yaml        (prints planned MCP calls)')
        print('  2) Import this module in an agent environment and call plan_build_from_object(demo) where demo is a DemoDef object.')
        sys.exit(0)

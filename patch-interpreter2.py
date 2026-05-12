#!/usr/bin/env python3
"""
Add `ansible_python_interpreter: /usr/bin/python3.6` to every task that uses
ansible.builtin.dnf, dnf, yum, or ansible.builtin.yum.

Usage:
    python3 patch_dnf_interpreter.py ansible/
"""
import sys
from pathlib import Path
from ruamel.yaml import YAML

DNF_MODULES = {"dnf", "yum", "ansible.builtin.dnf", "ansible.builtin.yum"}
INTERPRETER = "/usr/bin/python3.6"

yaml = YAML()
yaml.preserve_quotes = True
yaml.explicit_start = True          # keep the leading ---
yaml.indent(mapping=2, sequence=2, offset=0)   # match your project's style
yaml.width = 4096

def patch_task(task):
    if not isinstance(task, dict):
        return False
    if not any(m in task for m in DNF_MODULES):
        return False
    existing = task.get("vars") or {}
    if existing.get("ansible_python_interpreter") == INTERPRETER:
        return False
    existing["ansible_python_interpreter"] = INTERPRETER
    task["vars"] = existing
    return True

def walk(node, changed):
    if isinstance(node, list):
        for item in node:
            if isinstance(item, dict) and any(m in item for m in DNF_MODULES):
                if patch_task(item):
                    changed[0] += 1
            walk(item, changed)
    elif isinstance(node, dict):
        for v in node.values():
            walk(v, changed)

def process(path):
    text = path.read_text()
    try:
        data = yaml.load(text)
    except Exception as e:
        print(f"  ! skip (parse error): {e}")
        return 0
    if data is None:
        return 0
    changed = [0]
    walk(data, changed)
    if changed[0]:
        with path.open("w") as f:
            yaml.dump(data, f)
    return changed[0]

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    root = Path(sys.argv[1])
    targets = list(root.rglob("*.yml")) + list(root.rglob("*.yaml"))
    total = 0
    for p in sorted(targets):
        n = process(p)
        if n:
            print(f"  patched {n} task(s): {p}")
            total += n
    print(f"\nDone. {total} task(s) patched.")

if __name__ == "__main__":
    main()

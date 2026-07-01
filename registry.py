#!/usr/bin/env python3
"""
Generate registry.json from all challenge folders.

This script scans the current directory for folders containing
challenge.yaml, validates required fields, and produces a single
registry.json.

Assumptions:
- Each challenge lives in its own folder directly under the repo root
- Each folder contains: challenge.yaml, check.py, and optionally README.md
- The script is run from the repo root
"""

import json
import yaml
from pathlib import Path
from datetime import datetime, timezone
import sys
import uuid

# Folders to ignore when scanning for challenges
IGNORE_DIRS = {".git", ".github", "scripts", "assets", "__pycache__"}

# Required fields in challenge.yaml
REQUIRED_FIELDS = {
    "title",
    "description",
    "difficulty",
    "category",
    "tags",
    "image",
    "objectives",
}

# Difficulty levels (for validation)
VALID_DIFFICULTIES = ["BEGINNER", "INTERMEDIATE", "ADVANCED"]


def validate_challenge_config(config: dict, folder_name: str) -> tuple[bool, list[str]]:
    """
    Validate that the challenge.yaml has all required fields.

    Returns: (is_valid, list_of_errors)
    """
    errors = []

    # Check required fields
    for field in REQUIRED_FIELDS:
        if field not in config:
            errors.append(f"Missing required field: '{field}'")
        elif config[field] is None or config[field] == "":
            errors.append(f"Field '{field}' is empty")

    # Validate difficulty
    if "difficulty" in config:
        if config["difficulty"].upper() not in VALID_DIFFICULTIES:
            errors.append(
                f"Invalid difficulty '{config['difficulty']}'. "
                f"Must be one of: {', '.join(VALID_DIFFICULTIES)}"
            )

    # Validate tags (must be a list)
    if "tags" in config and not isinstance(config["tags"], list):
        errors.append("'tags' must be a list")

    # Validate objectives (must be a list)
    if "objectives" in config and not isinstance(config["objectives"], list):
        errors.append("'objectives' must be a list")

    return len(errors) == 0, errors


def scan_challenges():
    """Scan all folders in the current directory for challenge.yaml."""
    root_dir = Path(".")
    challenges = []

    for folder in root_dir.iterdir():
        # Skip files and ignored directories
        if not folder.is_dir():
            continue
        if folder.name in IGNORE_DIRS:
            continue
        if folder.name.startswith("."):
            continue

        # Look for challenge.yaml
        yaml_path = folder / "challenge.yaml"
        if not yaml_path.exists():
            print(f"Skipping {folder.name}. If it is an actual challenge, then make sure it has a challenge.yml file.")
            continue

        # Read metadata
        try:
            with open(yaml_path, "r") as f:
                config = yaml.safe_load(f)
        except Exception as e:
            print(f"⚠️  Error reading {yaml_path}: {e}")
            continue

        # Validate required fields
        is_valid, errors = validate_challenge_config(config, folder.name)
        if not is_valid:
            print(f"❌ Skipping {folder.name}:")
            for err in errors:
                print(f"     - {err}")
            continue

        # Read README.md if it exists
        readme_path = folder / "README.md"
        markdown = ""
        if readme_path.exists():
            with open(readme_path, "r") as f:
                markdown = f.read()
        else:
            # Fallback: generate from description
            markdown = f"## {config.get('title')}\n\n{config.get('description', '')}"

        # Generate UUID for the challenge
        challenge_uuid = str(uuid.uuid4())
        symbol = f"[{'#' * (VALID_DIFFICULTIES.index(config['difficulty'].upper()) + 1)}{'-' * (len(VALID_DIFFICULTIES) - (VALID_DIFFICULTIES.index(config['difficulty'].upper()) + 1))}]"

        # Build the challenge entry
        # NOTE: We use 'name' from the config, not 'id'
        # The UUID is the internal identifier
        challenge = {
            "uuid": challenge_uuid,
            "title": config["title"],
            "description": config["description"],
            "difficulty": config["difficulty"].upper() + symbol,
            "category": config["category"],
            "tags": config["tags"],
            "objectives": config["objectives"],
            "image": config["image"],
            "markdown": markdown,
            "challenge_url": f"https://github.com/programming-sai/clice-challenges/tree/main/{folder.name}/",
            "check_url": f"https://raw.githubusercontent.com/programming-sai/clice-challenges/main/{folder.name}/check.py",
        }

        challenges.append(challenge)
        print(f"✓ Added {challenge['title']} ({folder.name})")

    return challenges


def main():
    print("🔍 Scanning for challenges...")
    print(f"   Required fields: {', '.join(REQUIRED_FIELDS)}\n")

    challenges = scan_challenges()

    if not challenges:
        print("❌ No valid challenges found!")
        print("   Make sure each challenge is in a folder with challenge.yaml")
        print("   and has all required fields.")
        sys.exit(1)

    registry = {
        "total": len(challenges),
        "challenges": challenges
    }

    # Write to registry.json
    output_path = Path("registry.json")
    with open(output_path, "w") as f:
        json.dump(registry, f, indent=2)

    print(f"\n✅ Registry generated with {len(challenges)} challenges")
    print(f"📄 Saved to {output_path}")


if __name__ == "__main__":
    main()
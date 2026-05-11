#!/usr/bin/env python3
import os
import sys

def check():
    # Check if file exists and contains "Hello clice"
    try:
        with open("/workspace/output.txt", "r") as f:
            content = f.read().strip()
            if content == "Hello clice":
                return True
    except:
        pass
    return False

if __name__ == "__main__":
    sys.exit(0 if check() else 1)
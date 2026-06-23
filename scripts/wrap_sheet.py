"""
Replace `showModalBottomSheet(...)` with `showGlassModalBottomSheet(...)`,
removing the `shape:` parameter (the helper sets its own) and adding the
required import if missing.

Usage: python wrap_sheet.py <file> [<file> ...]
"""

import re
import sys


def add_import(text: str) -> str:
    if "glass_sheet.dart" in text:
        return text
    m = list(re.finditer(r"^import '[^']+';", text, re.MULTILINE))
    if not m:
        return "import 'package:neroflac/widgets/glass/glass_sheet.dart';\n\n" + text
    last = m[-1]
    return (
        text[: last.end()]
        + "\nimport 'package:neroflac/widgets/glass/glass_sheet.dart';"
        + text[last.end() :]
    )


def remove_shape_param(text: str) -> str:
    """Remove the `shape: ...` parameter block from a showModalBottomSheet call.
    Handles both single-line and multi-line forms:
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    """
    # Use balanced paren matching to handle multi-line shapes.
    idx = 0
    while True:
        m = re.search(r"^[ \t]*shape:\s*", text[idx:], re.MULTILINE)
        if not m:
            break
        start = idx + m.start()
        after = idx + m.end()
        # Expect `RoundedRectangleBorder(` or `const RoundedRectangleBorder(`.
        rb = re.match(r"(?:const\s+)?RoundedRectangleBorder\s*\(", text[after:])
        if not rb:
            idx = after
            continue
        # Balanced paren match (handles multi-line).
        depth = 0
        i = after + rb.end() - 1
        while i < len(text):
            if text[i] == "(":
                depth += 1
            elif text[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        else:
            break
        # After the `)`, expect `,` and trailing whitespace.
        end = i + 1
        if end < len(text) and text[end] == ",":
            end += 1
        while end < len(text) and text[end] in " \t\n":
            end += 1
        text = text[:start] + text[end:]
        idx = start
    return text


def process_file(path: str) -> int:
    with open(path, "r", encoding="utf-8") as f:
        original = f.read()
    if "showModalBottomSheet" not in original:
        return 0

    text = original
    # Always strip `shape:` blocks first (even if already replaced).
    text = remove_shape_param(text)
    text = text.replace("showModalBottomSheet", "showGlassModalBottomSheet")
    text = add_import(text)

    if text != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    return text.count("showGlassModalBottomSheet")


def main():
    if len(sys.argv) < 2:
        print("Usage: wrap_sheet.py <file> [<file> ...]")
        sys.exit(1)
    total = 0
    for p in sys.argv[1:]:
        n = process_file(p)
        if n:
            print(f"{p}: {n} sheet(s) wrapped")
            total += n
    print(f"Total: {total}")


if __name__ == "__main__":
    main()

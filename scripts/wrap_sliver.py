"""
Wrap every SliverAppBar(...) usage with GlassSliverAppBar(child: ...).

For each file:
  1. Add import for glass_sliver_appbar.dart (if not present).
  2. Find each SliverAppBar( occurrence and wrap it with GlassSliverAppBar(child: ).
  3. Add an extra closing paren after the SliverAppBar's matching `);`.

The script uses balanced-paren matching to find the right closing location.
"""

import os
import re
import sys


def find_balanced_paren_end(text: str, start: int) -> int:
    """Given text and an index pointing at the opening `(`, return the index
    of the matching `)`. Counts nested parens, ignoring those inside strings
    and comments (best-effort — strings/comments spanning lines are tricky)."""
    depth = 0
    i = start
    in_string = None  # ', ", or None
    in_line_comment = False
    in_block_comment = False
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ''
        if in_line_comment:
            if ch == '\n':
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if ch == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string is not None:
            if ch == '\\':
                i += 2
                continue
            if ch == in_string:
                in_string = None
            i += 1
            continue
        if ch == '/' and nxt == '/':
            in_line_comment = True
            i += 2
            continue
        if ch == '/' and nxt == '*':
            in_block_comment = True
            i += 2
            continue
        if ch in ('"', "'"):
            in_string = ch
            i += 1
            continue
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("Unbalanced parens starting at %d" % start)


def add_import(text: str) -> str:
    if "glass_sliver_appbar.dart" in text:
        return text
    # Insert after the last existing import.
    import re
    matches = list(re.finditer(r"^import '[^']+';", text, re.MULTILINE))
    if not matches:
        return "import 'package:neroflac/widgets/glass/glass_sliver_appbar.dart';\n\n" + text
    last = matches[-1]
    end = last.end()
    return (
        text[:end]
        + "\nimport 'package:neroflac/widgets/glass/glass_sliver_appbar.dart';"
        + text[end:]
    )


def wrap_sliver_appbar(text: str) -> tuple[str, int]:
    """Wrap every `SliverAppBar(...)` call in the file with
    `GlassSliverAppBar(child: ...)`. Returns (new_text, count_wrapped)."""
    pattern = re.compile(r"\bSliverAppBar\s*\(")
    out = text
    count = 0
    # Find from the end so positions remain valid after edits.
    matches = list(pattern.finditer(out))
    matches.reverse()
    for m in matches:
        paren_start = m.end() - 1
        try:
            paren_end = find_balanced_paren_end(out, paren_start)
        except ValueError:
            continue
        # The matching `)` is at paren_end. After it, there should be `;`.
        # Find that semicolon.
        semi = paren_end + 1
        while semi < len(out) and out[semi] in ' \t':
            semi += 1
        if semi >= len(out) or out[semi] != ';':
            continue
        # The wrap: insert `GlassSliverAppBar(child: ` before `SliverAppBar(`
        # and `,` after the trailing `;`, then a `);` to close the wrapper.
        before = out[:m.start()]
        after = out[m.start():]
        new_block = "GlassSliverAppBar(child: " + after
        # After the semicolon, add the close.
        new_block = new_block[: semi + 1 - m.start()] + ")" + new_block[semi + 1 - m.start():]
        out = before + new_block
        count += 1
    return out, count


def process_file(path: str) -> int:
    with open(path, 'r', encoding='utf-8') as f:
        original = f.read()
    if 'SliverAppBar(' not in original:
        return 0
    new_text, count = wrap_sliver_appbar(original)
    new_text = add_import(new_text)
    if new_text != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_text)
    return count


def main():
    if len(sys.argv) < 2:
        print("Usage: wrap_sliver.py <file> [<file> ...]")
        sys.exit(1)
    total = 0
    for p in sys.argv[1:]:
        n = process_file(p)
        if n:
            print(f"{p}: wrapped {n} SliverAppBar(s)")
            total += n
    print(f"Total wrapped: {total}")


if __name__ == "__main__":
    main()

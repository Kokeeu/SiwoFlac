"""
Wrap a single `return SliverAppBar(...)` with `GlassSliverAppBar(child: ...)`.

This script is careful: it only matches `return SliverAppBar(` and adds ONE
`)` to close the new wrapper. It does NOT touch any other parens in the file.

Usage: python wrap_one.py <file>
"""

import re
import sys


def main(path):
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Add import if not present.
    if "glass_sliver_appbar.dart" not in text:
        # Find last import line.
        m = list(re.finditer(r"^import '[^']+';", text, re.MULTILINE))
        if not m:
            text = (
                "import 'package:neroflac/widgets/glass/glass_sliver_appbar.dart';\n\n"
                + text
            )
        else:
            last = m[-1]
            text = (
                text[: last.end()]
                + "\nimport 'package:neroflac/widgets/glass/glass_sliver_appbar.dart';"
                + text[last.end() :]
            )

    # Check if already wrapped.
    if "GlassSliverAppBar(child:" in text:
        print(f"  already wrapped: {path}")
        return

    # Find the return SliverAppBar(.
    m = re.search(r"^(\s*)return\s+SliverAppBar\s*\(", text, re.MULTILINE)
    if not m:
        print(f"  no return SliverAppBar found: {path}")
        return

    # Find the matching `)` for this `(`.
    paren_start = m.end() - 1
    depth = 0
    in_string = None
    in_line_comment = False
    in_block_comment = False
    i = paren_start
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""
        if in_line_comment:
            if ch == "\n":
                in_line_comment = False
            i += 1
            continue
        if in_block_comment:
            if ch == "*" and nxt == "/":
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string is not None:
            if ch == "\\":
                i += 2
                continue
            if ch == in_string:
                in_string = None
            i += 1
            continue
        if ch == "/" and nxt == "/":
            in_line_comment = True
            i += 2
            continue
        if ch == "/" and nxt == "*":
            in_block_comment = True
            i += 2
            continue
        if ch in ('"', "'"):
            in_string = ch
            i += 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                paren_end = i
                break
        i += 1
    else:
        print(f"  unbalanced parens: {path}")
        return

    # The matching `)` is at paren_end. After it should be `;` (and possibly more
    # whitespace and a newline). We want to insert `)` right before that `;`.
    # Actually, the original is:
    #     return SliverAppBar(
    #       ...
    #     );
    # We want to become:
    #     return GlassSliverAppBar(
    #       child: SliverAppBar(
    #         ...
    #       ),
    #     );
    # So:
    # - Replace "return SliverAppBar(" with "return GlassSliverAppBar(\n<indent>  child: SliverAppBar("
    # - Replace ");" right after the matching ")" with "),\n<indent>);"

    # The whitespace before "return" is the line indent.
    indent = m.group(1)
    child_indent = indent + "  "

    # Step 1: wrap the opening.
    text = (
        text[: m.start()]
        + f"{indent}return GlassSliverAppBar(\n{child_indent}child: SliverAppBar("
        + text[m.end() :]
    )

    # Step 2: find the matching `)` in the NEW text (positions shifted by insertion).
    # The matching `)` is at paren_end + delta, where delta is the number of chars
    # we inserted before paren_end.
    # Easier: find the next `);` after the wrapping point and split.
    # After paren_end in the new text, we look for ");" at line start (with indent).
    # The original ");" is at the line AFTER the matching `)`. The line has
    # indent of `indent` (e.g., "    );").

    # In the new text, find the line that starts with the original indent + ");".
    target = "\n" + indent + ");"
    # paren_end in original → in new text, position is paren_end + delta.
    # delta = len(f"{indent}return GlassSliverAppBar(\n{child_indent}child: SliverAppBar(") - len("return SliverAppBar(")
    delta = (
        len(f"{indent}return GlassSliverAppBar(\n{child_indent}child: SliverAppBar(")
        - len("return SliverAppBar(")
    )
    new_paren_end = paren_end + delta

    # Look for the first occurrence of target AFTER new_paren_end.
    # The target text is "\n<indent>);".
    search_start = new_paren_end
    idx = text.find(target, search_start)
    if idx == -1:
        print(f"  could not find closing ); for {path}")
        return

    # Replace the `);` with `),\n<indent>);` -- so it becomes the closing of
    # the inner SliverAppBar, then the outer GlassSliverAppBar.
    text = text[:idx] + f",\n{indent});" + text[idx + len(target) :]

    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"  wrapped: {path}")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        main(p)

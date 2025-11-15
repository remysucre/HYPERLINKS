# md0 Format Specification

md0 is a plain text format for ORBIT pages, inspired by Markdown.

## Links

**Syntax:** `[word][n]`

- `word`: single word with no spaces
- `n`: number referring to a link definition
- NO space between the two bracket pairs
- Renders with underline, clickable

**Link Definitions:** `[n]: url`

- Must be on its own line
- Space required after colon
- Must appear at the end of the file, after all content

## Text Rendering

- Each line is rendered independently on its own line
- Blank lines create vertical spacing (one line-height)
- Words are wrapped when they exceed the content width

## Example

```
This is the first line with a [link][1] in it.
This is the second line.

This is after a blank line.
It has [another][2] link.

[1]: https://example.com
[2]: https://other.com
```

This renders as four lines with blank space between lines 2 and 3. The words "link" and "another" appear underlined and are clickable.

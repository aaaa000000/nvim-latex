# Code Snippets

This directory contains custom code snippets for various file types to accelerate coding and document preparation.

## File Structure

```
snippets/
├── README.md           # This documentation
├── markdown.snippets  # Markdown document snippets
├── python.snippets    # Python development snippets
└── tex.snippets       # LaTeX document snippets
```

## Files

### markdown.snippets
Snippets for Markdown document creation and formatting.

**Common Snippets:**
- Document structure (headers, tables, lists)
- Academic writing elements (citations, footnotes)
- Code block templates
- Link and image insertion patterns
- LaTeX math notation within Markdown

### python.snippets
Python development snippets for common patterns and structures.

**Common Snippets:**
- Function and class definitions
- Control flow structures (if/else, loops)
- Exception handling patterns
- Testing frameworks (pytest, unittest)
- Documentation strings and type hints
- Import statement templates

### tex.snippets
LaTeX document preparation snippets for academic and professional writing.

#### Homological Algebra — Commutative Diagrams (`tikzcd`)

| Trigger   | Description                          | Placeholders |
|-----------|--------------------------------------|--------------|
| `tikzcd`  | Generic 2×2 commutative square       | A, B, C, D, f, g, h, k |
| `ses`     | Short exact sequence `0→A→B→C→0`     | A, B, C, f, g |
| `les`     | Long exact sequence `···→A→B→C→D→···`| A, B, C, D, ∂, f, g |
| `les0`    | Long exact sequence from 0 `0→A→B→C→D→E→···` | A, B, C, D, E, f, g, h, k |
| `cmap`    | Chain map (two rows + vertical α_n)  | `\partial` (mirrors), `\alpha` (mirrors) |
| `lchain`  | Long chain `0→C₁→⋯→C₅↘C₆→⋯→C₁₀→···` (two-row) | — |
| `snake`   | Snake lemma 3×2 grid                 | A,B,C,A',B',C', α,β,γ, f,g,f',g' |
| `pullback`| Pullback square with `⌟` corner mark | P, A, B, C, p₁, p₂, f, g |
| `pushout` | Pushout square with `⌜` corner mark  | A, B, C, P, f, g, i₁, i₂ |

**Notes on `cmap`:**
- Tab 1 sets the boundary map symbol (default `\partial`) — auto-mirrors to all 4 horizontal arrow labels in both rows
- Tab 2 sets the chain map symbol (default `\alpha`) — auto-mirrors to all 3 vertical arrow labels
- Individual subscripts (`_{n+1}`, `_n`, `_{n-1}`) are hardcoded

**Notes on `lchain`:**
- Splits across two rows at C₅/C₆ with a `dll` diagonal connecting arrow
- Map labels `f_1`…`f_{10}` are hardcoded; edit manually after expansion
- Uses `[column sep=small]` to keep width manageable

#### Theorem Environments

| Trigger      | Description                  |
|--------------|------------------------------|
| `Tthm`       | Theorem + proof block        |
| `Mthm`       | Main theorem + proof block   |
| `Cthm`       | Corollary theorem + proof    |
| `Rthm`       | Remark theorem + proof       |
| `Lthm`       | Lemma theorem + proof        |
| `Pthm`       | Proposition theorem + proof  |
| `Dthm`       | Definition theorem + proof   |
| `customthm`  | Custom named theorem         |
| `thrm`       | `\begin{theorem}` env        |
| `lemma`      | `\begin{Lthm}` env           |
| `prop`       | `\begin{Pthm}` env           |
| `def`        | `\begin{definition}` env     |
| `corl`       | `\begin{corollary}` env      |
| `prob`       | Problem environment          |
| `example`    | Example environment          |
| `prf`        | Proof block (quote style)    |

#### Math Environments

| Trigger | Description                        |
|---------|------------------------------------|
| `eqn`   | `equation` (numbered, with label)  |
| `eqs`   | `equation*` (unnumbered)           |
| `gat`   | `gather` (numbered)                |
| `gats`  | `gather*` (unnumbered)             |
| `align` | `align` / `aligned` env            |
| `dm`    | Display math `\[ … \]`             |
| `im`    | Inline math `$ … $`                |

#### List Environments

| Trigger | Description                          |
|---------|--------------------------------------|
| `enu`   | `enumerate` with `\item`             |
| `enur`  | `enumerate[label=(\roman*)]`         |
| `enua`  | `enumerate[label=(\alph*)]`          |
| `itm`   | `itemize` with `\item`               |

#### Document Structure

| Trigger | Description         |
|---------|---------------------|
| `sec`   | `\section`          |
| `sub`   | `\subsection`       |
| `ssub`  | `\subsubsection`    |
| `hsec`  | `\hypsection`       |
| `hsub`  | `\hypsubsection`    |
| `hssub` | `\hypsubsubsection` |
| `begin` | `\begin{}/\end{}`   |

#### Text & Math Formatting

| Trigger | Description              |
|---------|--------------------------|
| `it`    | `\textit{}`              |
| `bf`    | `\textbf{}`              |
| `tt`    | `\texttt{}`              |
| `sc`    | `\textsc{}`              |
| `mf`    | `\mathfrak{}`            |
| `mc`    | `\mathcal{}`             |
| `ms`    | `\mathscr{}`             |

#### Misc

| Trigger      | Description                    |
|--------------|--------------------------------|
| `nc`         | `\newcommand`                  |
| `up`         | `\usepackage`                  |
| `fig`        | Figure + `\includegraphics`    |
| `tikz`       | Tikzpicture figure environment |
| `fn`         | `\footnote{}`                  |
| `lab`        | `\label{}`                     |
| `textbox`    | `tcolorbox` environment        |
| `frame`      | Beamer frame                   |
| `gloss`      | Glossary entry                 |

## Usage

Snippets are activated through the completion system:
1. Type snippet trigger text
2. Press `<Tab>` to expand
3. Use `<Tab>` and `<Shift-Tab>` to navigate placeholders
4. Press `<Esc>` to exit snippet mode

## Integration

Snippets integrate with:
- **LuaSnip**: Primary snippet engine
- **blink.cmp**: Completion system for snippet discovery
- **which-key**: Snippet-related keybindings under `<leader>s`

## Related Configuration
- [plugins/tools/luasnip.lua](../lua/neotex/plugins/tools/luasnip.lua) - Snippet engine configuration
- [plugins/lsp/blink-cmp.lua](../lua/neotex/plugins/lsp/blink-cmp.lua) - Completion integration
- [templates/](../templates/README.md) - Document templates

## Navigation

- [Templates →](../templates/README.md)
- [LSP Configuration →](../lua/neotex/plugins/lsp/README.md)
- [← Main Configuration](../README.md)
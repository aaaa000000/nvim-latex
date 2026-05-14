## Web Extension

This project includes web development support via the web extension.

### Language Routing

| Language | Research Tools | Implementation Tools |
|----------|----------------|---------------------|
| `web` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash (pnpm build/check) |

### Skill-Agent Mapping

| Skill | Agent | Purpose |
|-------|-------|---------|
| skill-web-research | web-research-agent | Astro/Tailwind/Cloudflare research |
| skill-web-implementation | web-implementation-agent | Web (Astro/Tailwind/TypeScript) implementation |

### Key Technologies

- **Astro**: Static site generator with islands architecture (v5 stable, v6 notes where relevant)
- **Tailwind CSS v4**: CSS-first configuration with @theme directive
- **TypeScript**: Strict mode with Astro type utilities
- **Cloudflare Pages**: Edge deployment with automatic preview deployments

### Build Verification

```bash
# Development server
pnpm dev

# TypeScript + Astro diagnostics
pnpm check

# Production build
pnpm build

# Preview production build
pnpm preview
```

### Context Categories

- **Domain**: Core framework concepts (Astro, Tailwind v4, Cloudflare, TypeScript)
- **Patterns**: Implementation patterns (components, layouts, content collections, accessibility)
- **Standards**: Coding conventions and targets (style guide, performance, accessibility)
- **Tools**: Tool-specific guides (CLI, deployment, debugging)
- **Templates**: Boilerplate templates (pages, components)

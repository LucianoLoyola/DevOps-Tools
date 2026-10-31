---
name: content-studio
description: Generate multi-platform social media content for the dev.luchops brand — TikTok/YouTube Shorts/Instagram Reels video scripts, a Medium technical article, a dev.to article, an AWS Builder Center (builder.aws.com) technical deep-dive, an X thread, and LinkedIn + Instagram slide carousels exported as ready-to-post PNG images (plus a LinkedIn PDF) — from a single topic. Researches official/primary sources, defines the scope and key ideas (or proposes its own if none given), and cross-references every platform in the text posts. Use when the user gives a topic and asks for a script, a post, a thread, a carousel, an article, or "content" for their social channels.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - Artifact
  - Skill
  - Glob
  - Bash(mkdir *)
  - Bash(bash *)
---

# /content-studio — Multi-platform content generator for dev.luchops

Turns one topic into a full content pack across every channel: a short-form
video script, a Medium article, a dev.to article, an AWS Builder Center
article, an X thread, and LinkedIn + Instagram slide carousels.
Language is **Spanish** unless the user explicitly asks for another language
for this run.

**Platform selection:** if the user names specific platforms for this run
(e.g. "dev.to, X e Instagram"), produce **only those** pieces plus
`context.md`, and log in the decision history which ones were skipped.
With no platforms named, produce the full pack. Builder Center only applies
to AWS topics: for a non-AWS topic, skip it and say so.

Arguments passed: `$ARGUMENTS` — treat this as the topic/brief if present.
If empty, ask the user what topic to cover.

---

## Brand reference (always use these, never invent others)

- Marca / handle: **dev.luchops**
- YouTube: https://www.youtube.com/@dev.luchops
- TikTok: https://www.tiktok.com/@dev.luchops
- Instagram: https://www.instagram.com/dev.luchops/
- Medium: https://medium.com/@lucianonicolasloyola
- LinkedIn: https://www.linkedin.com/in/luciano-nicolas-loyola/
- dev.to: perfil **sin confirmar**. Generá el artículo cuando se pida, pero
  no linkees al perfil desde otras piezas hasta que el usuario pase la URL.
- AWS Builder Center (builder.aws.com): perfil **sin confirmar**. Misma
  regla que dev.to.
- X (Twitter): **no existe todavía**. Generá igual el contenido de X cuando
  se pida, pero **no** lo incluyas como link de referencia cruzada desde las
  otras piezas hasta que el usuario confirme que ya tiene cuenta.

### Firma de marca (usar siempre, textual)

Todo posteo de texto termina con esta firma, copiada exactamente — mismos
caracteres, mismos saltos de línea, URLs sin `https://` (LinkedIn las
linkea igual y queda más limpio):

```
━━━━━━━━━━━━━━━━━━━━
🟧 dev.luchops
Cloud & DevOps, explicado sin vueltas.

▸ Medium → medium.com/@lucianonicolasloyola
▸ YouTube → youtube.com/@dev.luchops
▸ TikTok / Instagram → @dev.luchops
━━━━━━━━━━━━━━━━━━━━
```

- No reemplazar el 🟧 por el logo de AWS ni por otro logo de marca de
  terceros (implica respaldo/afiliación).
- No usar "negritas" Unicode (𝗱𝗲𝘃…) en la firma.
- Dónde va en cada pieza está indicado en cada sección (B, C, D).
- Al entregar el artículo de Medium, recordale al usuario que Medium
  auto-linkea "@dev" (de "@dev.luchops") a twitter.com/dev: hay que quitar
  ese link en el editor después de pegar.
- En dev.to y Builder Center la firma va dentro de un bloque de código
  (```` ``` ````): si no, el markdown junta las líneas y dev.to puede
  convertir "@dev" en una mención.

---

## Estilo de redacción (non-negotiable)

- **Nunca uses guiones como puntuación** en ningún texto generado (guion,
  Medium, X, LinkedIn, slides, captions): ni raya `—`, ni `–`, ni ` - `
  intercalado. Al usuario le suena poco natural. Reescribí la frase con
  punto, coma, dos puntos o paréntesis.
- Los guiones que son parte de un nombre técnico sí van tal cual
  (`multi-Region`, `add-region`, `us-east-1`, `break-glass`).
- Nada de corchetes decorativos: ni citas `[1]` en Medium ni
  `[Texto en pantalla]` en el guion (usá `*Texto en pantalla: "..."*`).

---

## Phase 1 — Scope the topic

1. **Research.** Use WebSearch/WebFetch to find official/primary sources on
   the topic: docs, changelogs, spec/RFCs, official blog posts, papers,
   vendor announcements. Collect 3–6 solid **official** sources with URLs —
   you'll cite them in the long-form articles (Medium, dev.to, Builder
   Center), log them in `context.md`, and
   lean on them for every factual claim everywhere else. See the Sourcing
   rule below — it governs everything from here on.
2. **Define ideas to transmit.** From the research, draft:
   - A one-line **angle** (the specific take, not just "explicar X").
   - 3–5 **key ideas/takeaways** the content should land.
   - Target **audience** (e.g., devs junior/senior, curioso general, etc.)
   - If the user already gave an angle/ideas in their brief, use those as
     the backbone instead of inventing new ones — but still fill gaps with
     your own proposals where they left something vague.
3. **Check in before writing everything.** Present the angle + key ideas +
   sources briefly and confirm with the user (a short question, or
   AskUserQuestion if there's a real fork in direction — e.g. two very
   different angles). Don't over-ask: if the brief was already specific and
   unambiguous, a one-line confirmation ("Voy con este ángulo: ... ¿dale?")
   is enough before moving to Phase 2. Skip the check-in entirely if the
   user explicitly said to just go.

---

## Sourcing rule (non-negotiable)

- **No fact in any generated piece may be inferred, assumed, or guessed.**
  Every claim, number, feature name, limit, price, date, or behavior must
  trace back to something explicitly stated in an **official** source —
  the vendor's own docs, announcement/changelog, or press release. Never
  extrapolate ("probably also supports X", "likely priced similarly to Y")
  and never fill a gap with plausible-sounding detail.
- Secondary sources (blogs, Medium/Dev.to recaps, news aggregators, third
  -party comparisons) are fine for *discovery* — they help you find what to
  look for — but no fact used in the content pack may rest on a secondary
  source alone. If a secondary source claims something the official docs
  don't state, either verify it directly against an official source first
  or leave it out.
- If the official documentation doesn't cover something (a number, a
  detail, a "why"), **say so explicitly** in the content or omit it
  entirely. Do not paper over the gap with an assumption.
- `context.md`'s "Fuentes" section is the ledger for this: every source
  listed must be official, and every key idea in "Ideas clave" should be
  traceable to one of those listed sources — note which source backs which
  idea when it isn't obvious. This is what lets the repo's history be
  trusted later without re-verifying everything from scratch.

---

## Phase 2 — Generate the content pack

Once the scope is confirmed, produce every requested piece (video script, Medium, dev.to, Builder Center, X thread, LinkedIn caption, LinkedIn and Instagram carousels with their exported images; see Platform selection) plus the context file
(below). Everything lives under `branding/<topic-slug>/`, **relative to the
git repo root** (not under the skill folder, and not an absolute filesystem
path — if the current working directory isn't the repo root, find it first,
e.g. `git rev-parse --show-toplevel`) — this is the historical archive of
every topic ever covered, committed to git. Create it with `mkdir -p`, and
also show the content inline in the reply so the user doesn't have to open
files to review it.

`<topic-slug>` is one folder **per topic**, no date prefix — if the topic
comes up again later, it's the same folder, updated, not a duplicate.

- Before generating anything, `Glob` for `branding/<topic-slug>/` (or a
  close match — check `branding/*` if the exact slug isn't obvious). If it
  already exists:
  1. Read its `context.md` first and reuse its angle/audience/sources as
     the starting point instead of re-deriving from scratch, so a topic
     doesn't contradict its own history.
  2. Ask the user whether this run should refresh/regenerate the four
     pieces or just add new sources/decisions to the context file (e.g. the
     topic evolved, or they want a follow-up piece). Don't silently
     overwrite prior content without saying so.
  3. Append a new dated entry to `context.md`'s decision log rather than
     erasing the previous one.

### Context file — `context.md` (the historical record)

Write/update `branding/<topic-slug>/context.md`. This is what makes the
folder useful as a repo-tracked history, not just a content dump — capture
*decisions*, not just outputs:

```
# <Topic>

## Ángulo
<one-line angle actually used>

## Audiencia
<target audience>

## Ideas clave
- idea 1 (fuente: <source title>)
- idea 2 (fuente: <source title>)
- ...

## Fuentes (todas oficiales — ver Sourcing rule)
- <source title> — <url>
- ...

## Contenido generado
- Guion video: ./video-script.md
- Medium: ./medium.md
- dev.to: ./devto.md
- AWS Builder Center: ./builder-aws.md
- Hilo X: ./x-thread.md
- LinkedIn (caption): ./linkedin.md
- LinkedIn (carrusel, Artifact): <artifact URL> (fuente: ./carrusel-linkedin.html)
- LinkedIn (imágenes + PDF): ./export/linkedin/
- Instagram (carrusel): ./carrusel-instagram.html
- Instagram (imágenes): ./export/instagram/

## Publicación (completar a mano cuando se publique)
- YouTube/TikTok/Reels: <url o pendiente>
- Medium: <url o pendiente>
- dev.to: <url o pendiente>
- AWS Builder Center: <url o pendiente>
- X: <url o pendiente>
- LinkedIn: <url o pendiente>

## Historial de decisiones
### <YYYY-MM-DD>
<qué se decidió en esta corrida: ángulo elegido, cambios de rumbo pedidos
por el usuario, fuentes descartadas, por qué, etc.>
```

Keep the "Historial de decisiones" section append-only across runs — it's
the audit trail of *why* the content looks the way it does, which is the
whole point of tracking this in git.

### A. Short-form video script — TikTok / YouTube Shorts / Instagram Reels

One script serves all three platforms (same format, same cut). File:
`video-script.md`.

- **Hook (0–3s):** a line or visual that stops the scroll — a bold claim, a
  question, a "no sabías que...". Never start with a slow intro.
  - **Body:** fast beats, timestamped (e.g. `0:03–0:10`), short sentences
  meant to be spoken, one idea per beat. Include on-screen text suggestions
  as `*Texto en pantalla: "..."*` (never in brackets).
- **CTA / cierre:** one clear call to action (seguir, comentar, "el artículo
  completo está en Medium / el hilo en X").
- **Caption** (for the post itself): 1–2 punchy lines + relevant hashtags.
- Keep total spoken duration in the 30–60s range unless the topic clearly
  needs more.

### B. Medium article — technical and developed

File: `medium.md`. This is the deep-dive: assume a reader who wants the
real mechanism, not a surface explainer.

- Hook intro (2–4 sentences) framing why this matters.
- Structured body with `##`/`###` headers, code snippets or diagrams-in-text
  where relevant, and the nuance/edge cases a short-form video can't fit.
- Cite the primary sources found in Phase 1 (linked inline or in a closing
  "Fuentes" section).
- Closing section **"Seguime en más plataformas"** with links to YouTube,
  TikTok, Instagram and LinkedIn (and a mention of the video version of this
  same topic). Omit X unless the user has confirmed an account exists.
- Cierra con la **Firma de marca** (ver Brand reference), como último
  bloque del artículo, después de "Seguime en más plataformas".

### B.1 dev.to article — narrative, conceptual

File: `devto.md`. The **approachable** long-form piece: explains what the
thing is, the concepts involved and *why it matters / how it simplifies the
work*. No step-by-step configuration (no CLI, no JSON); a reader should
finish understanding the model, not knowing how to type it.

- Starts with dev.to front matter:
  ```
  ---
  title: "..."
  published: false
  description: "..."            # 1–2 sentences
  tags: aws, devops, ...        # max 4, lowercase, no spaces or dashes
  cover_image: <official image URL, if there is one>
  ---
  ```
  `published: false` always: the user publishes by hand.
- Body: hook intro, then `##` sections. A short "conceptos que entran en
  juego" glossary is welcome when the topic leans on other services.
  Tables and official images (linked from their original URL, with a short
  italic caption) are encouraged.
- Closing: "Para cerrar" + question to the reader, "Fuentes" section,
  "Seguime en más plataformas" (same rules as Medium; also Medium as a link),
  and the Firma de marca **inside a code block**.

### B.2 AWS Builder Center article (builder.aws.com) — technical deep-dive

File: `builder-aws.md`. Only for AWS topics. This is the **most technical**
piece of the pack, aimed at builders who will implement it: the place for
the real mechanism, CLI/API calls, IAM, configuration fields, quotas,
monitoring and troubleshooting that the other pieces leave out.

- Builder Center's editor has separate fields, so the file starts with a
  block to copy into them, then the body:
  ```
  <!-- CAMPOS DEL EDITOR (no pegar en el cuerpo)
  Título: ...
  Descripción: ...              # 1–2 sentences
  Tags (máx. 5): aws, ...
  Imagen de cabecera: <official image URL or local path to upload>
  -->
  ```
- Builder Center guidelines to respect: headings in logical order (H1 → H2
  → H3), short paragraphs and lists, **alt text on every image**, and **no
  broken or placeholder links** (automated moderation checks links and the
  title/description length). Never leave `<link pendiente>` in this file.
  Its editor markdown support isn't documented: tell the user to check with
  **Preview** after pasting.
- Body structure (adapt to the topic):
  1. TL;DR (3–5 bullets).
  2. Architecture / how it works, with the official diagram.
  3. Prerequisites (IAM roles, policies, network requirements).
  4. Step by step with CLI/API snippets **copied or adapted only from the
     official docs** (placeholders like `123456789012`, `my-cluster`), plus
     IaC where official docs show it.
  5. Configuration reference: tables of settings, defaults, mutable vs
     immutable.
  6. Limits and quotas (table).
  7. Monitoring (metrics, dimensions, statuses) and troubleshooting (error
     message → cause → fix).
  8. Best practices / gotchas, each traceable to the docs.
  9. Fuentes, "Seguime en más plataformas" (mention the simpler dev.to /
     Medium version and the carousel), Firma de marca in a code block.
- Sourcing rule applies with extra weight here: every command, field name,
  default and error string must appear in an official source. If a value
  isn't documented, say so.

### C. X thread — short, char-limited

File: `x-thread.md`. Written as numbered tweets (≤280 chars each, aim for
well under the limit so it reads fast).

- Tweet 1 = the hook, must work as a standalone statement.
- 3–7 follow-up tweets, one idea each, same key ideas as the rest of the
  pack but condensed — no filler.
- Last tweet: CTA + link to the Medium article, and a mention of the video
  (YouTube/TikTok/Reels).
- Después, un tweet extra solo con la **Firma de marca**, pero **sin las
  dos líneas `━━━`** (X cuenta esos caracteres doble y la firma completa
  puede pasarse de 280). El resto de la firma va textual.

### D. Carruseles LinkedIn e Instagram (con imágenes exportadas)

Outputs:

1. **Caption text** (`linkedin.md`): a short professional-toned post (a few
   paragraphs, LinkedIn style — no hashtag stuffing), mentioning the video
   version and inviting people to swipe the carousel, and ending with the
   **Firma de marca** (it already carries the Medium/YouTube/TikTok/
   Instagram links — don't repeat a separate link block above it). Hashtags,
   if any, go between the body and the firma.
2. **The slide deck itself, as a published Artifact.** Load the
   `artifact-design` skill (the Artifact tool requires it), but the visual
   design is **already decided**: follow the dev.luchops design system
   below. Where `artifact-design` suggests inventing a new palette or
   typography, the design system wins (it's the user's explicit choice).
   - 8–12 slides, 4:5 (`1080x1350`), one idea per slide, each legible on
     its own (they get exported as individual images).
   - Slide 1: cover. Last slide: CTA + cross-references (see below).
   - File: `carrusel-linkedin.html`. Publish it with `Artifact`, a
     distinctive title (the topic, not "LinkedIn Carousel").
3. **Instagram carousel** (`carrusel-instagram.html`): same slides and
   same design as LinkedIn, only the last slide changes (see
   "Platform-specific last slide"). Not published as an Artifact unless
   the user asks; its deliverable is the images.
4. **Exported images, always** (part of every run, not optional):
   ```bash
   S=.claude/skills/content-studio/design/export-slides.sh
   bash $S branding/<topic-slug>/carrusel-linkedin.html  branding/<topic-slug>/export/linkedin  carrusel-linkedin.pdf
   bash $S branding/<topic-slug>/carrusel-instagram.html branding/<topic-slug>/export/instagram
   ```
   Result: `export/linkedin/slide-NN.png` + `carrusel-linkedin.pdf`
   (LinkedIn carousels are uploaded as a PDF document) and
   `export/instagram/slide-NN.png` (1080x1350, upload in order). The
   script uses headless Chrome/Edge; if neither is found, say so in the
   wrap-up instead of skipping silently.

### dev.luchops carousel design system (non-negotiable)

Confirmed by the user on 2026-10-05 ("me encanta el estilo y la paleta").
The reference implementation is
**`.claude/skills/content-studio/design/carousel-template.html`**
(relative to the repo root). Applies to **every** carousel (LinkedIn,
Instagram, or any other).

**How to use it:** `Read` the template, then copy its `<link>` tags and
the entire `<style>` block **verbatim** into the new carousel. Only the
`<title>`, the intro line and the content of the `<section class="slide">`
elements change. Reuse the existing components; don't add new colors,
fonts, radii or shadows. If a topic truly needs a new component, build it
only from the existing tokens and add it to the template too, so the
system stays in one place.

**What defines the look (so you can recognize drift):**
- **Palette:** cool slate paper (`--slide #f7f9fb` on `--bg #e7ebf0`),
  navy ink (`--ink #0f1b2d`), a single cobalt accent (`--accent #2346d8`)
  for highlights and the "primary" state, amber (`--warn #a8570a`) only for
  caveats/"no existe", green (`--ok`) only for "todas/soportado". Dark
  theme values are defined in the template; keep them.
- **Type:** Schibsted Grotesk 800 for headlines, IBM Plex Sans for body,
  IBM Plex Mono for labels, footers, region codes, URLs and CLI.
- **Slide anatomy (every slide):** top bar in mono uppercase (section label
  left, counter `NN/TT` right) → headline `h2` where the key phrase goes in
  `<em>` (rendered in cobalt) → body components → footer with a hairline
  rule, `dev.luchops` handle left and the source or a short note right.
- **Components available:** `.rows` (label/value), `.prq` (requirement
  table), `.quote` (verbatim quote with mono attribution), `.choice`/`.opt`
  (console option mock), `.alert` (amber caveat), `.crumb` (console path),
  `.cli` (dark code block), `.steps` (numbered real sequence; `.skip` for
  "no aplica"), `.url.no`/`.url.yes` (wrong vs right), `.bul` (dot list),
  `.api` (capability matrix), `.note`, `.limits`/`.lim` (2x2 big-number
  tiles), `.check` (checklist), `.sig` (firma de marca block), `.regions`
  /`.tag` (region pills: solid = primary, dashed = replica), `.shot`
  (official screenshot or diagram in a bordered frame with a mono caption;
  crop with the frame aspect-ratio and `object-position`, or zoom with
  img width/negative margins), `.hero` (inline SVG flow diagram for the
  cover, drawn only with token classes `.n` node, `.g` accent block, `.w`
  arrow, `.d` dashed, `.h`/`.s` labels).
- **Sizing:** everything inside a slide uses `cqw` units so it scales with
  the slide. Long mono lines (URLs in `.cli`) may need a smaller inline
  `font-size`; never let text clip.
- **Copy rules still apply** (Estilo de redacción: no dashes as
  punctuation, no decorative brackets).

**Platform-specific last slide:**
- LinkedIn: clickable `.links` list (Medium, YouTube, TikTok, Instagram,
  LinkedIn) + big handle.
- Instagram: links aren't clickable, so a `.bio` line ("…está en Medium.
  *Link en la bio.*") + the `.sig` block with the Firma de marca.

**Visual check before delivering:** after exporting, look at the PNGs
once (for example a contact sheet of all slides) and check nothing clips
or wraps badly (hyphenated terms splitting across lines: wrap them in
`white-space:nowrap`; long URLs in `.cli`: smaller inline font-size). If
something needs fixing, fix the HTML, export that carousel again, and
publish the LinkedIn Artifact after the fix.

---

## Cross-referencing rule (non-negotiable)

Every **text** post (Medium, dev.to, Builder Center, X, LinkedIn caption) must reference the other
platforms and the video content, using the brand links above — never
invented URLs, never a bare "sígueme" with no link. Every text post also
ends with the **Firma de marca** (see Brand reference for the exact text). The video script's own
CTA references Medium (and the LinkedIn carousel when relevant). Skip any
platform the user has said doesn't exist yet (currently: X has no account —
don't link to it from other pieces, but still generate the X thread itself
when asked). dev.to and Builder Center profile URLs aren't confirmed yet:
mention those articles by name ("la versión técnica en AWS Builder
Center"), but don't invent profile links. When an article URL isn't known
yet, only X (where the user edits before posting) may carry a
`<link pendiente>` marker; long-form articles must not.

---

## Wrap-up

After generating the pack, give a short summary: the angle used, the pieces
produced (with file paths under `branding/<topic-slug>/`), how the long-form
articles split the depth (dev.to conceptual, Builder Center technical), the Artifact
URL for the LinkedIn carousel, where the exported images are
(`export/linkedin/` with the PDF, `export/instagram/`), and remind the user that
`context.md` in that folder is where they should note the real publish URLs
once each piece goes live — that's what keeps the historical record useful.
Don't re-paste everything you already showed inline. Don't commit the
folder to git yourself unless the user explicitly asks.

---
name: content-studio
description: Generate multi-platform social media content for the dev.luchops brand — TikTok/YouTube Shorts/Instagram Reels video scripts, a Medium technical article, an X thread, and a LinkedIn slide carousel — from a single topic. Researches official/primary sources, defines the scope and key ideas (or proposes its own if none given), and cross-references every platform in the text posts. Use when the user gives a topic and asks for a script, a post, a thread, a carousel, an article, or "content" for their social channels.
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
---

# /content-studio — Multi-platform content generator for dev.luchops

Turns one topic into a full content pack across every channel: a short-form
video script, a Medium article, an X thread, and a LinkedIn slide carousel.
Language is **Spanish** unless the user explicitly asks for another language
for this run.

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
- X (Twitter): **no existe todavía**. Generá igual el contenido de X cuando
  se pida, pero **no** lo incluyas como link de referencia cruzada desde las
  otras piezas hasta que el usuario confirme que ya tiene cuenta.

---

## Phase 1 — Scope the topic

1. **Research.** Use WebSearch/WebFetch to find official/primary sources on
   the topic: docs, changelogs, spec/RFCs, official blog posts, papers,
   vendor announcements. Prefer primary sources over secondary blogs/news
   aggregators. Collect 3–6 solid sources with URLs — you'll cite them in
   the Medium article and lean on them for accuracy everywhere else.
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

## Phase 2 — Generate the content pack

Once the scope is confirmed, produce all four pieces plus the context file
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
- idea 1
- idea 2
- ...

## Fuentes
- <source title> — <url>
- ...

## Contenido generado
- Guion video: ./video-script.md
- Medium: ./medium.md
- Hilo X: ./x-thread.md
- LinkedIn (caption): ./linkedin.md
- LinkedIn (carrusel, Artifact): <artifact URL>

## Publicación (completar a mano cuando se publique)
- YouTube/TikTok/Reels: <url o pendiente>
- Medium: <url o pendiente>
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
  in brackets.
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

### C. X thread — short, char-limited

File: `x-thread.md`. Written as numbered tweets (≤280 chars each, aim for
well under the limit so it reads fast).

- Tweet 1 = the hook, must work as a standalone statement.
- 3–7 follow-up tweets, one idea each, same key ideas as the rest of the
  pack but condensed — no filler.
- Last tweet: CTA + link to the Medium article, and a mention of the video
  (YouTube/TikTok/Reels).

### D. LinkedIn carousel — visual slide deck

Two outputs:

1. **Caption text** (`linkedin.md`): a short professional-toned post (a few
   paragraphs, LinkedIn style — no hashtag stuffing), ending with links to
   the Medium article and the video (YouTube/TikTok), and inviting people to
   swipe the carousel.
2. **The slide deck itself, as a published Artifact.** Before writing the
   HTML, load the `artifact-design` skill to calibrate the visual design —
   this is a real deliverable, not a throwaway. Then build a self-contained
   HTML carousel:
   - 6–10 slides, each `~1080x1350` (LinkedIn portrait ratio) or laid out so
     each slide fills a full viewport-ish block, swipeable/scrollable
     horizontally with clear slide boundaries (LinkedIn carousels are
     screenshotted/exported per slide, so each one must be legible on its
     own — no content bleeding across slide edges).
   - Slide 1: cover — bold title/hook, topic, "dev.luchops" watermark.
   - Slides 2–(n-1): one key idea per slide, short text, generous
     whitespace, consistent type scale — this is read as static images, not
     prose.
   - Last slide: CTA + cross-reference block (Medium article, video on
     YouTube/TikTok/Reels, LinkedIn profile) + dev.luchops handle.
   - Follow `artifact-design` guidance for theme-awareness, typography and
     color; keep the dev.luchops watermark/handle visible on every slide.
   - Publish with `Artifact`, a distinctive title (the topic, not "LinkedIn
     Carousel"), and a fitting favicon emoji.

---

## Cross-referencing rule (non-negotiable)

Every **text** post (Medium, X, LinkedIn caption) must reference the other
platforms and the video content, using the brand links above — never
invented URLs, never a bare "sígueme" with no link. The video script's own
CTA references Medium (and the LinkedIn carousel when relevant). Skip any
platform the user has said doesn't exist yet (currently: X has no account —
don't link to it from other pieces, but still generate the X thread itself
when asked).

---

## Wrap-up

After generating the pack, give a short summary: the angle used, the four
pieces produced (with file paths under `branding/<topic-slug>/`), the
Artifact URL for the LinkedIn carousel, and remind the user that
`context.md` in that folder is where they should note the real publish URLs
once each piece goes live — that's what keeps the historical record useful.
Don't re-paste everything you already showed inline. Don't commit the
folder to git yourself unless the user explicitly asks.

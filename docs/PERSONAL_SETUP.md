# Personal setup (English)

1. `cp jarvis.toml.example jarvis.toml` — already set to English
   (profile, speech recognition, replies, speech output).
2. `cp .env.example .env` and add **only the provider key you choose**.
   Hosted providers bill you per use; a local model (Ollama) costs nothing.
   Nothing here spends money until you add your own key.
3. `pip install -e .` then `jarvis serve` and open http://localhost:47821.
4. In the app: pick a wake phrase (or a keyboard shortcut), connect a model
   under Settings › API Keys, and say or type your first request.

Code defaults changed from upstream: only the profile language (`en`) and
speech output language (`en-US`). Replies and speech recognition keep upstream's
`auto` in code (existing tests rely on it) and are pinned to `en` in
`jarvis.toml.example` — so copy that file as in step 1.

<div align="center">
  <img src="assets/images/logo.png" width="150" alt="Locstep Logo">
  <h1>Locstep</h1>
</div>

Indoor navigation from a graph: define nodes and edges, get step-by-step routes.

## Demo

- [Download demo video](./docs/demo.mp4)
- [Download example graph](./docs/demo_university_graph.json) for testing or as a reference template

## Adding languages

1. Add `lib/l10n/app_<code>.arb` (see [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)).
2. Copy keys from `app_en.arb`, translate.
3. Run `flutter gen-l10n`.

---
name: rust
description: >-
  Use when writing, editing, reviewing, debugging, or testing Rust code.
---

# Rust 🦀

## References

- When exact standard library behavior matters, consult source under
  `~/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library`
- When exact third-party crate behavior matters, inspect crate source under
  `~/.cargo/registry` and `~/.cargo/git`

<!-- TODO: Link (local or remote) to Rust Reference, Rustonomicon, etc -->

## Formatting

- Format Rust code with `cargo +nightly fmt`
- Follow local `rustfmt.toml` or `.rustfmt.toml`

## Validation

- Run tests with `cargo nextest run`

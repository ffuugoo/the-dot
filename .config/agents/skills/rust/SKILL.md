---
name: rust
description: >-
  Use when writing, editing, reviewing, testing, or debugging Rust code
---

# Rust 🦀

## Documentation

When exact standard library behavior matters, consult source under
`~/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library`.

When exact third-party crate behavior matters, inspect crate source under
`~/.cargo/registry` and `~/.cargo/git`.

For Rust Reference and Rustonomicon use [`Docs`](../docs/SKILL.md) skill.

## Formatting

Follow style of existing code and `rustfmt.toml`.
Format Rust code with `cargo +nightly fmt`.

## Validation

Run tests with `cargo nextest run`.

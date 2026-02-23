# Contributing to SSH Multi Manage

Thanks for your interest in contributing! Here are a few guidelines.

## Reporting bugs

Open a [GitHub issue](https://github.com/DanielElgh/ssh-multi-manage/issues) with:

- A clear title and description
- Steps to reproduce the problem
- Expected vs. actual behaviour
- Your Perl version (`perl -v`) and OS

## Suggesting features

Open an issue describing the use-case and what you'd like to see.

## Submitting changes

1. Fork the repository and create a feature branch from `develop`.
2. Keep commits focused - one logical change per commit.
3. Add or update tests in `t/` for any new functionality.
4. Make sure all tests pass:
   ```bash
   make test
   ```
5. Open a pull request against `develop`.

## Coding style

- `use strict; use warnings;` in every file.
- 4-space indentation (no tabs).
- Keep lines under 120 characters where practical.
- Follow existing naming conventions (`snake_case` for subs and variables).

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).

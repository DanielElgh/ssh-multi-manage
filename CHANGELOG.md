# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project follow [Semantic Versioning](https://semver.org/) for stable releases. Developer releases use Perl's underscore convention.

## [1.0.1] - 2026-02-24

### Changed
- `configdump` outputs configuration as JSON instead of Perl `Data::Dumper`

### Fixed
- `get_hosts_enriched()` correctly returns custom data defined in `get_hosts()`

## [1.0.0] - 2026-02-23

### Added
- `connect` - interactive TUI SSH connection manager
- `lssrv` - list servers with live OS and uptime info
- `hostcheck` - parallel SSH port availability checker
- `vihosts` - safe SSH config editor with syntax validation
- `configdump` - parsed SSH config dumper
- `s2a` / `a2s` - SSH config ↔ Ansible inventory converters
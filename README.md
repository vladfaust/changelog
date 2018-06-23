# Changelog

Create beautiful GitHub Markdown changelogs from AngularJS-style commits.

## Installation

TODO: Write installation instructions here

## Usage

```shell
crystal ../changelog/src/changelog.cr -- v0.2.0...v0.2.1
```

Will put changelog to `STDOUT`:

```
### Bug Fixes

* c154205c update `Prism::Server` to work with new `HTTP::Server`

### Chores

* 97a832b remove `Prism::VERSION`
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/vladfaust/changelog/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [@vladfaust](https://github.com/vladfaust) Vlad Faust - creator, maintainer

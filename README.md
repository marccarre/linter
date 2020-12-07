# linter

An unopinionated<sup>1</sup>, lightweight<sup>2</sup> Docker image to lint
**all-the-things**<sup>3</sup>!

![All-the-things meme](img/all-the-things.png)

1. No specific style enforced, this can be configured in _your_ project.
2. Well ~145 MB, because some linters need [node.js][node], which is ~100 MB.
3. That is, things...
    - common to most software projects
    - not language-specific -- this is better done in either a language-specific
      linter image, or directly in your project's build image, which typically
      already has the targeted language's toolchain.

## Supported linters

| _Language_ | _Linter_                                                     |
| -----------| ------------------------------------------------------------ |
| Dockerfile | [`hadolint`][hadolint]                                       |
| English    | [`misspell`][misspell]                                       |
| Makefile   | [`checkmake`][checkmake]                                     |
| Markdown   | [`markdownlint`][markdownlint]                               |
| Shell      | [`shellcheck`][shellcheck], [`shfmt`][shfmt], `+x` bit check |

## Usage

### Lint all-the-things

The following command will lint all files in the mounted directory using
`bin/lint`:

```console
docker run -v $(pwd):/mnt/lint marccarre/linter:latest
```

### Lint just one thing

You can also directly run a specific sub-linter:

```console
docker run -v $(pwd):/mnt/lint marccarre/linter:latest hadolint Dockerfile
```

## Inspirations

- [GitHub' `super-linter`][superlinter], which I found good, but unwieldy and
  bloated.

[checkmake]: https://github.com/mrtazz/checkmake#readme
[hadolint]: https://github.com/hadolint/hadolint#readme
[markdownlint]: https://github.com/igorshubovych/markdownlint-cli#readme
[misspell]: https://github.com/client9/misspell#readme
[node]: https://nodejs.org/
[shellcheck]: https://github.com/koalaman/shellcheck#readme
[shfmt]: https://github.com/mvdan/sh#readme
[superlinter]: https://github.com/github/super-linter

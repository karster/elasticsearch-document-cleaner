# ElasticSearch Document Cleaner

> Simple script to remove documents from ElasticSearch older than specific day count

## Installation

```bash
$ git clone https://github.com/karster/elasticsearch-document-cleaner.git && cd elasticsearch-document-cleaner
$ sudo make install
```

For uninstalling, open up the cloned directory and run

```bash
$ sudo make uninstall
```

For update/reinstall

```bash
$ sudo make reinstall
```

## Usage

```bash
$ elasticsearch-document-cleaner [ -f | -h | -p | -d | -i ]

-d <number>, --days <number>
Defines days, default 14.

-p <number>, --port <number>
Port, default 9200.

-h <string>, --host <string>
Host name, default "localhost".

-i <string>, --index <string>
Index name. If empty get list all indices.

-f, --force
Don't ask for confirm to delete indexes.

--help
Print this help.
```

## Contribution
Have an idea? Found a bug? See [how to contribute][contributing].

## License
MIT see [LICENSE][] for the full license text.


[license]: LICENSE.md
[contributing]: CONTRIBUTING.md
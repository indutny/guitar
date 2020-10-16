# Guitar

Manage your guitar practice routine with an Elixir CLI tool.

## Installation

```sh
mix escript.build
mix escript.install
```

## Running

```sh
Usage:

  Display past logs:
  $ guitar [list] [--full] [--count <num>]

  Start daily routine:
  $ guitar play

  Add a new exercise to today's log:
  $ guitar add --name <str> --bpm <num> [--slowdown <num>]       [--notes <str>] [--strings <even|odd>]

  For any command:
  [--today <yyyy-mm-dd>] can be used to interact with past entries.
  [--file <log.json>] can be used to override default log location.
```

#### LICENSE

This software is licensed under the MIT License.

Copyright Fedor Indutny, 2020.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.

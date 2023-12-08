namespace AOC\Day81;

use HH\Lib\{C, Dict, Keyset, Math, Regex, Str, Vec};

const string FILE_NAME = 'input.txt';

<<__EntryPoint>>
async function main(): Awaitable<void> {
  list($instructions, $nodes_raw) =
    \file_get_contents(FILE_NAME) |> Str\split($$, "\n\n");

  $instructions = Str\trim($instructions);
  $graph = parse_nodes($nodes_raw);

  $current_node = 'AAA';

  $counter = 0;
  $instruction_generator = instruction_generator($instructions);
  while ($current_node !== 'ZZZ') {
    $instruction_generator->next();
    $current_instruction = $instruction_generator->current();
    if ($current_instruction === 'L') {
      $current_node = $graph[$current_node][0];
    } else {
      $current_node = $graph[$current_node][1];
    }
    $counter++;
  }
  echo "$counter\n";
}

function parse_nodes(string $input): dict<string, (string, string)> {
  $result = dict[];

  $lines = Str\split($input, "\n");
  foreach ($lines as $line) {
    list($node, $left, $right) = Regex\every_match($line, re"/\w+/");
    $result[$node[0]] = tuple($left[0], $right[0]);
  }
  return $result;
}

function instruction_generator(
  string $instructions,
): \Generator<int, string, void> {
  $index = 0;
  while (true) {
    if ($index === Str\length($instructions)) {
      $index = 0;
    }
    yield $instructions[$index];
    $index++;
  }
}

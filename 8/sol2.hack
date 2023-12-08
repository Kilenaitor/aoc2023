namespace AOC\Day82;

use HH\Lib\{C, Dict, Keyset, Math, Regex, Str, Vec};

const string FILE_NAME = 'input.txt';

<<__EntryPoint>>
async function main(): Awaitable<void> {
  list($instructions, $nodes_raw) =
    \file_get_contents(FILE_NAME) |> Str\split($$, "\n\n");

  $instructions = Str\trim($instructions);
  $graph = parse_nodes($nodes_raw);

  $current_nodes = vec[];
  foreach ($graph as $node => $_) {
    if (Str\ends_with($node, 'A')) {
      $current_nodes[] = $node;
    }
  }

  $lengths = vec[];
  for ($i = 0; $i < C\count($current_nodes); $i++) {
    $current_node = $current_nodes[$i];

    $step_counter = 0;
    $instruction_generator = instruction_generator($instructions);
    while (!Str\ends_with($current_node, 'Z')) {
      $instruction_generator->next();
      $current_instruction = $instruction_generator->current();
      if ($current_instruction === 'L') {
        $current_node = $graph[$current_node][0];
      } else {
        $current_node = $graph[$current_node][1];
      }
      $step_counter++;
    }
    $lengths[] = $step_counter;
  }

  // Curse you, Hack, for not having this in the STL ;-;
  $answer = lcms($lengths);
  echo "$answer\n";
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

// https://stackoverflow.com/a/147523
function lcms(vec<int> $numbers): int {
  $answer = $numbers[0];
  for ($i = 1; $i < C\count($numbers); $i++) {
    $answer =
      Math\int_div(($numbers[$i] * $answer), gcd($numbers[$i], $answer));
  }
  return $answer;
}

// Euclidean algorithm
function gcd(int $a, int $b): int {
  if ($b === 0) {
    return $a;
  }
  return gcd($b, $a % $b);
}
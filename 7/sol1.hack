namespace AOC\Day71;

use HH\Lib\{C, Dict, Keyset, Math, Regex, Str, Vec};

const string FILE_NAME = 'input.txt';

const vec<string> CARDS = vec[
  'A',
  'K',
  'Q',
  'J',
  'T',
  '9',
  '8',
  '7',
  '6',
  '5',
  '4',
  '3',
  '2',
];

enum HandType: int as int {
  FIVE_OF_A_KIND = 0;
  FOUR_OF_A_KIND = 1;
  FULL_HOUSE = 2;
  THREE_OF_A_KIND = 3;
  TWO_PAIR = 4;
  ONE_PAIR = 5;
  HIGH_CARD = 6;
}

<<__EntryPoint>>
async function main(): Awaitable<void> {
  $hands_and_bids =
    \file_get_contents(FILE_NAME) |> Str\split($$, "\n");

  $hand_and_bids = vec<(string, int)>[];
  foreach ($hands_and_bids as $hand_and_bid) {
    list($hand, $bid) = Str\trim($hand_and_bid) |> Str\split($$, ' ');
    $hand_and_bids[] = tuple(Str\trim($hand), (int)(Str\trim($bid)));
  }

  $sorted_hands =
    Vec\sort($hand_and_bids, ($h1, $h2) ==> compare_hands($h2[0], $h1[0]));

  $result = 0;
  foreach ($sorted_hands as $rank => list($_hand, $bid)) {
    $result += $bid * ($rank + 1);
  }
  echo "$result\n";
}

function compare_hands(string $hand1, string $hand2): int {
  if ($hand1 === $hand2) {
    return 0;
  }

  $h1_type = get_hand_type($hand1);
  $h2_type = get_hand_type($hand2);
  $type_comparison = $h1_type <=> $h2_type;
  if ($type_comparison !== 0) {
    return $type_comparison;
  }

  for ($i = 0; $i < 5; $i++) {
    $c1 = $hand1[$i];
    $c2 = $hand2[$i];
    $cmp = C\find_key(CARDS, $card ==> $card === $c1) as nonnull <=>
      C\find_key(CARDS, $card ==> $card === $c2) as nonnull;
    if ($cmp !== 0) {
      return $cmp;
    }
  }

  invariant_violation('Impossible to get here');
}

function get_hand_type(string $hand): HandType {
  $cards_map = dict[];
  foreach (Str\split($hand, '') as $card) {
    if (!C\contains_key($cards_map, $card)) {
      $cards_map[$card] = 0;
    }
    $cards_map[$card]++;
  }

  if (C\contains($cards_map, 5)) {
    return HandType::FIVE_OF_A_KIND;
  }
  if (C\contains($cards_map, 4)) {
    return HandType::FOUR_OF_A_KIND;
  }
  if (C\contains($cards_map, 3)) {
    if (C\contains($cards_map, 2)) {
      return HandType::FULL_HOUSE;
    }
    return HandType::THREE_OF_A_KIND;
  }
  if (C\count(Keyset\keys($cards_map)) === 3) {
    return HandType::TWO_PAIR;
  }
  if (C\count(Keyset\keys($cards_map)) === 4) {
    return HandType::ONE_PAIR;
  }
  if (C\count(Keyset\keys($cards_map)) === 5) {
    return HandType::HIGH_CARD;
  }

  invariant_violation('Unknown hand');
}
namespace AOC\Day72;

use HH\Lib\{C, Dict, Keyset, Math, Regex, Str, Vec};

const string FILE_NAME = 'input.txt';

const vec<string> CARDS = vec[
  'A',
  'K',
  'Q',
  'T',
  '9',
  '8',
  '7',
  '6',
  '5',
  '4',
  '3',
  '2',
  'J',
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
  $hands_and_bids = \file_get_contents(FILE_NAME) |> Str\split($$, "\n");

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
  $cards_map = get_card_map($hand);

  $counts = num_of_each_card($cards_map);
  if (!C\contains_key($cards_map, 'J')) {
    return get_type_from_counts($counts);
  }
  if ($hand === 'JJJJJ') {
    return HandType::FIVE_OF_A_KIND;
  }

  $cards_map_without_j = get_card_map(Str\replace($hand, 'J', ''));
  $ordered_cards_without_j =
    Dict\sort($cards_map_without_j, ($c1, $c2) ==> $c2 <=> $c1);

  $highest_count = C\first_key($ordered_cards_without_j) as nonnull;
  $cards_map_without_j[$highest_count] += $cards_map['J'];
  return get_type_from_counts(num_of_each_card($cards_map_without_j));
}

function get_card_map(string $hand): dict<string, int> {
  $cards_map = dict[];
  foreach (Str\split($hand, '') as $card) {
    if (!C\contains_key($cards_map, $card)) {
      $cards_map[$card] = 0;
    }
    $cards_map[$card]++;
  }
  return $cards_map;
}

function get_type_from_counts(dict<int, int> $counts): HandType {
  if ($counts[5] !== 0) {
    return HandType::FIVE_OF_A_KIND;
  }
  if ($counts[4] !== 0) {
    return HandType::FOUR_OF_A_KIND;
  }
  if ($counts[3] === 1) {
    if ($counts[2] === 1) {
      return HandType::FULL_HOUSE;
    }
    return HandType::THREE_OF_A_KIND;
  }
  if ($counts[2] === 2) {
    return HandType::TWO_PAIR;
  }
  if ($counts[2] === 1) {
    return HandType::ONE_PAIR;
  }
  return HandType::HIGH_CARD;
}

function num_of_each_card(dict<string, int> $cards_map): dict<int, int> {
  $result = dict[
    1 => 0,
    2 => 0,
    3 => 0,
    4 => 0,
    5 => 0,
  ];
  foreach ($cards_map as $count) {
    $result[$count]++;
  }
  return $result;
}

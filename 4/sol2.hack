use HH\Lib\{C, Dict, Keyset, Str, Vec};

<<__EntryPoint>>
async function main(): Awaitable<void> {
    $file = file_get_contents('input.txt');

    $cards = Str\split($file, "\n")
        |> Vec\filter($$, $line ==> !Str\is_empty($line))
        |> Vec\map(
            $$,
            $line ==> {
                list($_prefix, $contents) = Str\split($line, ':');
                return trim($contents);
            },
        );

    $copies_per_card = dict[];
    foreach ($cards as $card_id => $_) {
        $copies_per_card[$card_id] = 1;
    }
    foreach ($cards as $card_id => $card) {
        list($numbers_have, $winning_numbers) = Str\split($card, '|');
        $numbers_have = trim($numbers_have)
            |> Str\split($$, ' ')
            |> Keyset\filter($$, $number ==> !Str\is_empty($number))
            |> Keyset\map($$, $number ==> (int)$number);
        $winning_numbers = trim($winning_numbers)
            |> Str\split($$, ' ')
            |> Keyset\filter($$, $number ==> !Str\is_empty($number))
            |> Keyset\map($$, $number ==> (int)$number);

        $matching_numbers = Keyset\intersect($numbers_have, $winning_numbers);
        if (C\is_empty($matching_numbers)) {
            continue;
        }

        for ($i = 1; $i <= C\count($matching_numbers); $i++) {
            $copies_per_card[$card_id + $i] += $copies_per_card[$card_id];
        }
    }

    $total_num_cards = 0;
    foreach ($copies_per_card as $card_count) {
        $total_num_cards += $card_count;
    }
    echo "$total_num_cards\n";
}

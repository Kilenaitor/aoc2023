use HH\Lib\{C, Keyset, Str, Vec};

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

    $points_total = 0;
    foreach ($cards as $card) {
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

        $points_total += 2**(C\count($matching_numbers) - 1);
    }
    echo "$points_total\n";
}

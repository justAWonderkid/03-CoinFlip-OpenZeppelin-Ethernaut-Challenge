
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {CoinFlip} from "../src/CoinFlip.sol";


contract DeployCoinFlip is Script {

    CoinFlip coinflip;

    function run() external returns(CoinFlip) {
        vm.startBroadcast();
        coinflip = new CoinFlip();
        vm.stopBroadcast();
        return coinflip;
    }

}
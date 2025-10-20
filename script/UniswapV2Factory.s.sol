// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/v2Factory.sol";

contract UniswapV2FactoryScript is Script {
    UniswapV2Factory public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        factory = new UniswapV2Factory();

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IUniswapV2Pair} from "./interfaces/Iv2Pair.sol";
import {UniswapV2ERC20} from "./v2ERC20.sol";

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    uint public constant MINIMUM_LIQUIDITY = 1000;
    address public override factory;
    address public override token0;
    address public override token1;
    uint public override price0CumulativeLast;
    uint public override price1CumulativeLast;
    uint public override kLast;

    function getReserves() external pure override returns (uint112, uint112, uint32) {
        return (0, 0, 0);
    }

    function mint(address) external pure override returns (uint) {
        return 0;
    }

    function burn(address) external pure override returns (uint, uint) {
        return (0, 0);
    }

    function swap(uint, uint, address, bytes calldata) external pure override {}

    function skim(address) external pure override {}

    function sync() external pure override {}

    function initialize(address, address) external pure override {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin-contracts-4.7.3/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin-contracts-4.7.3/token/ERC20/extensions/draft-ERC20Permit.sol";

contract UniswapV2ERC20 is ERC20, ERC20Permit {
    constructor() ERC20("Uniswap V2", "UNI-V2") ERC20Permit("Uniswap V2") {}
}
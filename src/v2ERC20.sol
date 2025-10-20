// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV2ERC20} from "./interfaces/Iv2ERC20.sol";
import {ERC20} from "@openzeppelin-contracts-4.7.3/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin-contracts-4.7.3/token/ERC20/extensions/draft-ERC20Permit.sol";

contract UniswapV2ERC20 is ERC20, ERC20Permit {
    string public constant override name = "Uniswap V2";
    string public constant override symbol = "UNI-V2";
    uint8 public constant override decimals = 18;

    bytes32 public immutable DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    constructor() ERC20(name, symbol) ERC20Permit(name) {
        uint chainId;
        assembly {
            chainId := chainId
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'UniswapV2: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'UniswapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}
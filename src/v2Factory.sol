// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV2Factory} from "./interfaces/Iv2Factory.sol";
import {UniswapV2Pair} from "./v2Pair.sol";
import {IUniswapV2Pair} from "./interfaces/Iv2Pair.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    modifier onlyFeeToSetter() {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        _;
    }

    function allPairsLength() external view returns (uint256 length) {
        length = allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO ADDRESS");
        require(getPair[token0][token1] == address(0), "UniswapV2: PAIR EXISTS");

        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, token0)
            mstore(add(ptr, 32), token1)
            salt := keccak256(ptr, 64)
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external onlyFeeToSetter {
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external onlyFeeToSetter {
        feeToSetter = _feeToSetter;
    }
}

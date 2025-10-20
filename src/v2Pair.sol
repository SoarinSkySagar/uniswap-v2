// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IUniswapV2Pair} from "./interfaces/Iv2Pair.sol";
import {IUniswapV2Factory} from "./interfaces/Iv2Factory.sol";
import {UniswapV2ERC20} from "./v2ERC20.sol";
import {IERC20} from "@openzeppelin-contracts-4.7.3/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts-4.7.3/security/ReentrancyGuard.sol";
import {Math} from "./utils/math.sol";
import {UQ112x112} from "./utils/uq112x112.sol";

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20, ReentrancyGuard {
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external override {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves()
        external
        view
        override
        returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "UniswapV2: TRANSFER FAILED");
    }

    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, "UniswapV2: Overflow");

        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            price0CumulativeLast = uint256(UQ112x112.encode(_reserve1) / uint224(_reserve0)) * timeElapsed;
            price1CumulativeLast = uint256(UQ112x112.encode(_reserve0) / uint224(_reserve1)) * timeElapsed;
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;

        emit Sync(uint112(balance0), uint112(balance1));
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast;

        if (feeOn && _kLast != 0) {
            uint256 rootK = Math.sqrt(uint256(_reserve0) * uint256(_reserve1));
            uint256 rootKLast = Math.sqrt(_kLast);

            if (rootK > rootKLast) {
                uint256 numerator = totalSupply() * (rootK - rootKLast);
                uint256 denominator = (rootK * 5) + rootKLast;
                uint256 liquidity = numerator / denominator;
                if (liquidity > 0) _mint(feeTo, liquidity);
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address) external pure override returns (uint256) {
        return 0;
    }

    function burn(address) external pure override returns (uint256, uint256) {
        return (0, 0);
    }

    function swap(uint256, uint256, address, bytes calldata) external pure override {}

    function skim(address) external pure override {}

    function sync() external override {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

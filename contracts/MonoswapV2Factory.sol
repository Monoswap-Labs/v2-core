pragma solidity =0.5.16;

import "./interfaces/IMonoswapV2Factory.sol";
import "./MonoswapV2Pair.sol";

contract MonoswapV2Factory is IMonoswapV2Factory {
    bytes32 public constant INIT_CODE_POOL_HASH =
        keccak256(abi.encodePacked(type(MonoswapV2Pair).creationCode));
    address public feeTo;
    address public feeToSetter;

    address public constant USDB = 0x4200000000000000000000000000000000000022;
    address public constant WETH = 0x4200000000000000000000000000000000000023;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address[] public rebasingPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        require(tokenA != tokenB, "MONOSWAPV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "MONOSWAPV2: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "MONOSWAPV2: PAIR_EXISTS"
        ); // single check is sufficient
        bytes memory bytecode = type(MonoswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMonoswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        if (token0 == USDB || token1 == USDB) {
            rebasingPairs.push(pair);
        }

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "MONOSWAPV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "MONOSWAPV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    function claimYield(uint256 offset, uint256 length) external {
        if (offset > rebasingPairs.length) {
            return;
        }
        uint256 end = offset + length;
        if (end > rebasingPairs.length) {
            end = rebasingPairs.length;
        }
        for (uint256 i = offset; i < end; i++) {
            IMonoswapV2Pair(rebasingPairs[i]).claimYield();
        }
    }

    function getPairs(
        uint256 offset,
        uint256 length
    ) external view returns (address[] memory) {
        if (offset > allPairs.length) {
            return new address[](0);
        }
        uint256 end = offset + length;
        if (end > allPairs.length) {
            end = allPairs.length;
        }
        address[] memory pairs = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            pairs[i - offset] = allPairs[i];
        }
        return pairs;
    }

    function getRebasingPairs(
        uint256 offset,
        uint256 length
    ) external view returns (address[] memory) {
        if (offset > rebasingPairs.length) {
            return new address[](0);
        }
        uint256 end = offset + length;
        if (end > rebasingPairs.length) {
            end = rebasingPairs.length;
        }
        address[] memory pairs = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            pairs[i - offset] = rebasingPairs[i];
        }
        return pairs;
    }
}

pragma solidity =0.5.16;

import "./interfaces/IMonoswapV2Factory.sol";
import "./MonoswapV2Pair.sol";
import "./abstract/BlastConfigure.sol";
import "./interfaces/IBlast.sol";

contract MonoswapV2Factory is IMonoswapV2Factory, BlastConfigure {
    bytes32 public constant INIT_CODE_POOL_HASH =
        keccak256(abi.encodePacked(type(MonoswapV2Pair).creationCode));
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address[] public rebasingPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    constructor(
        address _feeToSetter,         
        address _blast,
        address _blastPoints,
        address _usdb,
        address _weth,
        address _operator)public {
        feeToSetter = _feeToSetter;
        initializeBlastConfig(_blast, _blastPoints, _usdb, _weth, _operator);
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
        IMonoswapV2Pair(pair).initialize(
            token0, 
            token1,
            blast,
            blastPoints,
            usdb,
            weth,
            operator
            );
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        if (token0 == address(usdb) || token1 == address(usdb) || token0 == address(weth) || token1 == address(weth)) {
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

    function claimGas(uint256 offset, uint256 length, address receipient) external {
        if (offset > allPairs.length) {
            return;
        }
        uint256 end = offset + length;
        if (end > allPairs.length) {
            end = allPairs.length;
        }
        for (uint256 i = offset; i < end; i++) {
            IBlast(blast).claimMaxGas(allPairs[i], receipient);
        }
    }

    function claimPairsYield(
        uint256 offset,
        uint256 length,
        address receipient
    ) external {
        if (offset > allPairs.length) {
            return;
        }
        uint256 end = offset + length;
        if (end > allPairs.length) {
            end = allPairs.length;
        }
        for (uint256 i = offset; i < end; i++) {
            IMonoswapV2Pair(allPairs[i]).claimYield(receipient);
        }
    
    }
}

pragma solidity >=0.5.0;

import "./IBlast.sol";
import "./IBlastPoints.sol";
import "./IERC20Rebasing.sol";

interface IBlastConfigure {
    function blast() external view returns (address);
    function blastPoints() external view returns (address);
    function usdb() external view returns (address);
    function weth() external view returns (address);
    function operator() external view returns (address);
    function initializeBlastConfig(address _blast, address _blastPoints, address _usdb, address _weth, address _operator) external;
    function claimYield(address recipientOfYield) external;
    function setOperator(address _operator) external;
}
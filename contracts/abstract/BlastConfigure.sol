/// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "../interfaces/IBlast.sol";
import "../interfaces/IBlastPoints.sol";
import "../interfaces/IERC20Rebasing.sol";
import "../interfaces/IBlastConfigure.sol";

contract BlastConfigure is IBlastConfigure {
    address public blast;
    address public blastPoints;
    address public usdb;
    address public weth;
    address public operator;

    modifier onlyOperator() {
        require(msg.sender == operator, "BlastConfigure: not operator");
        _;
    }

    constructor() public {}


    function initializeBlastConfig(
        address _blast,
        address _blastPoints,
        address _usdb,
        address _weth,
        address _operator
    ) public {
        require(address(blast) == address(0), "BlastConfigure: already initialized");
        blast = (_blast);
        blastPoints = (_blastPoints);
        usdb = (_usdb);
        weth = (_weth);
        

        IBlast(blast).configureClaimableYield();
        IBlast(blast).configureClaimableGas();
        
        IERC20Rebasing(usdb).configure(IERC20Rebasing.YieldMode.CLAIMABLE);
        IERC20Rebasing(weth).configure(IERC20Rebasing.YieldMode.CLAIMABLE);

        IBlastPoints(blastPoints).configurePointsOperator(_operator);
        IBlast(blast).configureGovernor(_operator);
        
    }

    function claimYield(address recipientOfYield) external onlyOperator {
        IERC20Rebasing(usdb).claim(recipientOfYield, IERC20Rebasing(usdb).getClaimableAmount(address(this)));
        IERC20Rebasing(weth).claim(recipientOfYield, IERC20Rebasing(weth).getClaimableAmount(address(this)));
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

}
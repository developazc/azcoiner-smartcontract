// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

interface ITreasury {
    function mintToken(address recipient, uint256 amount) external;
}

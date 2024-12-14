// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

interface IToken {
    function mint(address recipient, uint256 amount) external;
}
